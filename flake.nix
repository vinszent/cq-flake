{
  description = "CQ-editor and CadQuery";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery = {
      url = "github:CadQuery/cadquery";
      flake = false;
    };
    cq-editor = {
      url = "github:CadQuery/CQ-editor";
      flake = false;
    };
    ocp = {
      url = "github:cadquery/ocp";
      flake = false;
    };
    ocp-stubs = {
      url = "github:cadquery/ocp-stubs";
      flake = false;
    };
    pywrap = {
      url = "github:CadQuery/pywrap";
      flake = false;
    };
    llvm_src = {
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
          python = pkgs.python38;
        in rec {
          packages = {
            python38 = pkgs.python38.override {
              packageOverrides = python-self : python-super: {
                cadquery = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                };
                cadquery_w_docs = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = true;
                  src = inputs.cadquery;
                };
                ocp = python-self.callPackage ./expressions/OCP {
                  src = inputs.ocp;
                  inherit (gccSet) stdenv gcc llvmPackages;
                  opencascade-occt = packages.opencascade-occt; 
                };
                sphinx = python-self.callPackage ./expressions/sphinx.nix { };
                sphinxcadquery = python-self.callPackage ./expressions/sphinxcadquery.nix { };
              };
            };
            clang = python.pkgs.callPackage ./expressions/clang.nix {
              src = inputs.llvm_src;
              llvmPackages = gccSet.llvmPackages;
            };
            pybind11 = python.pkgs.callPackage ./expressions/pybind11 { };
            cymbal = python.pkgs.callPackage ./expressions/cymbal.nix {
              clang = packages.clang;
            };
            pywrap = python.pkgs.callPackage ./expressions/pywrap {
              src = inputs.pywrap;
              inherit (gccSet) stdenv gcc llvmPackages;
              inherit (packages) clang pybind11 cymbal;
            };
            geomdl = python.pkgs.callPackage ./expressions/geomdl.nix { };
            ezdxf = python.pkgs.callPackage ./expressions/ezdxf.nix {
              inherit (packages) geomdl;
            };
            stdio-mgr = python.pkgs.callPackage ./expressions/stdio-mgr.nix { };
            sphinx-issues = python.pkgs.callPackage ./expressions/sphinx-issues.nix { };
            dictdiffer = python.pkgs.callPackage ./expressions/dictdiffer.nix { };
            sphobjinv = python.pkgs.callPackage ./expressions/sphobjinv.nix {
              inherit (packages) stdio-mgr dictdiffer;
            };
            typish = python.pkgs.callPackage ./expressions/typish.nix { };
            nptyping = python.pkgs.callPackage ./expressions/nptyping.nix {
              inherit (packages) typish;
            };
            sphinx-autodoc-typehints = python.pkgs.callPackage ./expressions/sphinx-autodoc-typehints.nix {
              inherit (packages) sphobjinv;
            };
            black = python.pkgs.callPackage ./expressions/black.nix { };
            pytest-flakefinder = pkgs.python38.pkgs.callPackage ./expressions/pytest-flakefinder.nix { };
            ocp-stubs = python.pkgs.callPackage ./expressions/OCP/stubs.nix {
              src = inputs.ocp-stubs;
            };
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = packages.python38.pkgs;
              src = inputs.cq-editor;
            };
            opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
              inherit (gccSet) stdenv;
              vtk_9 = packages.python38.pkgs.vtk_9;
            };
            cadquery-docs = packages.python38.pkgs.cadquery_w_docs.doc;
            cadquery-env = packages.python38.withPackages (
              ps: with ps; [ cadquery python-language-server black mypy ocp-stubs pytest pytest-xdist pytest-cov packages.pytest-flakefinder ]
            );
            # cadquery-dev-shell = packages.python38.withPackages (
            #   ps: with ps; ([ black mypy ocp-stubs ] 
            #   ++ cadquery.propagatedBuildInputs 
            #   # I have no idea why, but I can't access checkInputs
            #   # ++ cadquery.checkInputs
            #   ++ [ pytest ]
            #   ++ cadquery.nativeBuildInputs
            # ));
            # useful for debugging:
            nixpkgs-in = pkgs;
          };

          defaultPackage = packages.cq-editor;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/cq-editor";
          };
          # TODO: add dev env for cadquery
          # devShell = packages.cadquery-dev-shell;
          # TODO: add dev env for cq-editor, with hopefully working pyqt5
        }
      );
}
