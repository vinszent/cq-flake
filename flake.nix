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
      url = "github:llvm/llvm-project/llvmorg-10.0.1";
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
          pkgs = nixpkgs.legacyPackages.${system};
          # keep gcc, llvm and stdenv versions in sync
          gccSet = rec {
            # have to use gcc9 because freeimage complains with gcc8, could probably build freeimage with gcc8 if I have to, but this is easier.
            gcc = pkgs.gcc9;
            llvmPackages = pkgs.llvmPackages_10; # canonical now builds with llvm10: https://github.com/CadQuery/OCP/commit/2ecc243e2011e1ea5c57023dee22e562dacefcdd
            stdenv = pkgs.gcc9Stdenv;
          };
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
            inherit (gccSet) stdenv;
            vtk_9 = pkgs.python38.pkgs.vtk_9;  # awkward, py-vtk-9 -> not-py occt -> py-cadquery, not sure how to close the python package set.
          };
          py-overrides = import expressions/py-overrides.nix {
            inherit gccSet;
            inherit (inputs) llvm-src pywrap-src ocp-src ocp-stubs-src cadquery-src;
            inherit (pkgs) fetchFromGitHub;
            occt = opencascade-occt;
          };
          python = pkgs.python38.override {
            packageOverrides = py-overrides;
            self = python;
          };

        in rec {
          packages = {
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs;
              src = inputs.cq-editor-src;
            };
            cq-docs = python.pkgs.callPackage ./expressions/cq-docs.nix {
              src = inputs.cadquery-src;
            };
            cadquery-env = python.withPackages (
              ps: with ps; [ cadquery python-language-server black mypy ocp-stubs pytest pytest-xdist pytest-cov pytest-flakefinder ]
            );
            # cadquery-dev-shell = packages.python38.withPackages (
            #   ps: with ps; ([ black mypy ocp-stubs ] 
            #   ++ cadquery.propagatedBuildInputs 
            #   # I have no idea why, but I can't access checkInputs
            #   # ++ cadquery.checkInputs
            #   ++ [ pytest ]
            #   ++ cadquery.nativeBuildInputs
            # ));
            inherit python;
          };

          defaultPackage = packages.cq-editor;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/cq-editor";
          };
          overlays = { inherit py-overrides; };
          # TODO: add dev env for cadquery
          # devShell = packages.cadquery-dev-shell;
          # TODO: add dev env for cq-editor, with hopefully working pyqt5
        }
      );
}
