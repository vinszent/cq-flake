{
  description = "CQ-editor and CadQuery";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery";
      flake = false;
    };
    cq-editor-src = {
      url = "github:CadQuery/CQ-editor";
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
      url = "github:llvm/llvm-project/llvmorg-11.1.0";
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
          # I'm quite worried about how I handle this VTK. Python -> VTK (for Python bindings) -> OCCT -> Python(OCP)
          new_vtk_9 = pkgs.libsForQt5.callPackage ./expressions/VTK { enablePython = true; pythonInterpreter = python; };
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
            vtk_9 = new_vtk_9;
          };
          nlopt = pkgs.callPackage ./expressions/nlopt.nix {
            inherit python;
            pythonPackages = python.pkgs;
          };
          py-overrides = import expressions/py-overrides.nix {
            inherit (inputs) llvm-src pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (pkgs) fetchFromGitHub;
            vtk_9_nonpython = new_vtk_9;
            occt = opencascade-occt;
            nlopt_nonpython = nlopt;
            llvmPackages = pkgs.llvmPackages;
            pkg-config_nonpython = pkgs.pkg-config;
          };
          # python = pkgs.enableDebugging ((pkgs.python38.override {
          #   packageOverrides = py-overrides;
          #   self = python;
          # }).overrideAttrs (oldAttrs: { disallowedReferences = []; }));
          python = pkgs.python3.override {
            packageOverrides = py-overrides;
            self = python;
          };
          cq-kit = python.pkgs.callPackage ./expressions/cq-kit.nix {};
          pathpy = python.pkgs.callPackage ./expressions/pathpy.nix {};

        in rec {
          packages = {
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs // { inherit cq-kit; };
              src = inputs.cq-editor-src;
            };
            # cq-docs = python.pkgs.callPackage ./expressions/cq-docs.nix {
            #   src = inputs.cadquery-src;
            # };
            cadquery-env = python.withPackages (
              ps: with ps; [ cadquery cq-kit black mypy ocp-stubs pytest pytest-xdist pytest-cov pytest-flakefinder pybind11-stubgen ]
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
