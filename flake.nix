{
  description = "CQ-editor and CadQuery";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery/803a05e78c233fdb537a8604c3f2b56a52179bbe";
      flake = false;
    };
    cq-editor-src = {
      url = "github:CadQuery/CQ-editor/4b461fe195d0a4e99b9a6c43b7e1fe0cb4c5e77d";
      flake = false;
    };
    ocp-src = {
      url = "github:cadquery/ocp";
      flake = false;
    };
    ocp-stubs-src = {
      url = "github:cadquery/ocp-stubs";
      flake = false;
    };
    pywrap-src = {
      url = "github:CadQuery/pywrap";
      flake = false;
    };
    llvm-src = {
      url = "github:llvm/llvm-project/llvmorg-10.0.1";
      flake = false;
    };
    pybind11-stubgen-src = {
      url = "github:CadQuery/pybind11-stubgen";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      # someone else who can do the testing might want to extend this to other systems
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems ( system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          # keep gcc, llvm and stdenv versions in sync
          gccSet = {
            # have to use gcc9 because freeimage complains with gcc8, could probably build freeimage with gcc8 if I have to, but this is easier.
            llvmPackages = pkgs.llvmPackages_10; # canonical now builds with llvm10: https://github.com/CadQuery/OCP/commit/2ecc243e2011e1ea5c57023dee22e562dacefcdd
            stdenv = pkgs.stdenv; # not currently used, can probably be removed unless I have to control GCC version again in the future
          };
          # I'm quite worried about how I handle this VTK. Python -> VTK (for Python bindings) -> OCCT -> Python(OCP)
          new_vtk_9 = pkgs.libsForQt5.callPackage ./expressions/VTK { enablePython = true; pythonInterpreter = python; };
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
            inherit (gccSet) stdenv;
            vtk_9 = new_vtk_9;
          };
          nlopt = pkgs.callPackage ./expressions/nlopt.nix {
            inherit python;
            pythonPackages = python.pkgs;
          };
          py-overrides = import expressions/py-overrides.nix {
            inherit gccSet;
            inherit (inputs) llvm-src pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (pkgs) fetchFromGitHub;
            vtk_9_nonpython = new_vtk_9;
            occt = opencascade-occt;
            nlopt_nonpython = nlopt;
          };
          # python = pkgs.enableDebugging ((pkgs.python38.override {
          #   packageOverrides = py-overrides;
          #   self = python;
          # }).overrideAttrs (oldAttrs: { disallowedReferences = []; }));
          python = pkgs.python38.override {
            packageOverrides = py-overrides;
            self = python;
          };
          cq-kit = python.pkgs.callPackage ./expressions/cq-kit.nix {};

        in rec {
          packages = {
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs // { inherit cq-kit; };
              src = inputs.cq-editor-src;
            };
            cq-docs = python.pkgs.callPackage ./expressions/cq-docs.nix {
              src = inputs.cadquery-src;
            };
            cadquery-env = python.withPackages (
              ps: with ps; [ cadquery cq-kit python-language-server black mypy ocp-stubs pytest pytest-xdist pytest-cov pytest-flakefinder pybind11-stubgen ]
            );
            just-ocp = python.withPackages ( ps: with ps; [ ocp ] );
            # cadquery-dev-shell = packages.python38.withPackages (
            #   ps: with ps; ([ black mypy ocp-stubs ]
            #   ++ cadquery.propagatedBuildInputs
            #   # I have no idea why, but I can't access checkInputs
            #   # ++ cadquery.checkInputs
            #   ++ [ pytest ]
            #   ++ cadquery.nativeBuildInputs
            # ));
            inherit python opencascade-occt;
          };

          defaultPackage = packages.cq-editor;
          apps.default = flake-utils.lib.mkApp { drv = defaultPackage; }; 
          overlays = { inherit py-overrides; };
          # TODO: add dev env for cadquery
          # devShell = packages.cadquery-dev-shell;
          # TODO: add dev env for cq-editor, with hopefully working pyqt5
        }
      );
}
