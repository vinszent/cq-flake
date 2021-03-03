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
      url = "github:cadquery/ocp/7.4.0";
      flake = false;
    };
    pywrap = {
      url = "github:CadQuery/pywrap";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      # someone else who can do the testing might want to extend this to other systems
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems ( system:
        let pkgs = nixpkgs.legacyPackages.${system}; in rec {
          packages = {
            python38 = pkgs.python38.override {
              packageOverrides = python-self : python-super: {
                cadquery = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                };
                cadquery-debug = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                  ocp = packages.python38.pkgs.ocp-debug;
                };
                cadquery_w_docs = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = true;
                  src = inputs.cadquery;
                };
                ocp = python-self.callPackage ./expressions/OCP {
                  stdenv = pkgs.gcc9Stdenv;
                  src = inputs.ocp;
                  opencascade-occt = packages.opencascade-occt; 
                };
                ocp-debug = python-self.callPackage ./expressions/OCP {
                  opencascade-occt = packages.opencascade-occt-debug; 
                  debug = true;
                };
                clang = python-self.callPackage ./expressions/clang.nix { };
                cymbal = python-self.callPackage ./expressions/cymbal.nix { };
                geomdl = python-self.callPackage ./expressions/geomdl.nix { };
                ezdxf = python-self.callPackage ./expressions/ezdxf.nix { };
                sphinx = python-self.callPackage ./expressions/sphinx.nix { };
                nptyping = python-self.callPackage ./expressions/nptyping.nix { };
                typish = python-self.callPackage ./expressions/typish.nix { };
                sphinx-autodoc-typehints = python-self.callPackage ./expressions/sphinx-autodoc-typehints.nix { };
                sphobjinv = python-self.callPackage ./expressions/sphobjinv.nix { };
                stdio-mgr = python-self.callPackage ./expressions/stdio-mgr.nix { };
                sphinx-issues = python-self.callPackage ./expressions/sphinx-issues.nix { };
                pytest-subtests = python-self.callPackage ./expressions/pytest-subtests.nix { };
                sphinxcadquery = python-self.callPackage ./expressions/sphinxcadquery.nix { };
                black = python-self.callPackage ./expressions/black.nix { };
                pybind11 = python-self.callPackage ./expressions/pybind11 { };
                pywrap = python-self.callPackage ./expressions/pywrap.nix {
                  src = inputs.pywrap;
                  stdenv = pkgs.gcc6Stdenv;
                  gcc = pkgs.gcc6;
                  llvmPackages = pkgs.llvmPackages_6;
                  # clang is also pinned to 6.0.1 in the clang expression
                };
              };
            };
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = packages.python38.pkgs;
              src = inputs.cq-editor;
            };
            opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
              stdenv = pkgs.gcc9Stdenv;
            };
            opencascade-occt-debug = packages.opencascade-occt.overrideAttrs (
              oldAttrs: rec {separateDebugInfo = true;}
            );
            cadquery-docs = packages.python38.pkgs.cadquery_w_docs.doc;
            cadquery-env = packages.python38.withPackages (
              ps: with ps; [ cadquery python-language-server ]
            );
            cadquery-env-debug = (let
                py = pkgs.enableDebugging packages.python38; 
                debug_dirs = pkgs.lib.strings.makeSearchPath "lib/debug" [
                  py.pkgs.ocp.debug
                  packages.opencascade-occt-debug.debug
                  py.debug
                ];
              in pkgs.mkShell {
                buildInputs = [
                  (py.withPackages (ps: with ps; [ cadquery-debug python-language-server ] ))
                  packages.nixpkgs-in.gdb
                ];
                shellHook = ''
                  export NIX_DEBUG_INFO_DIRS=${debug_dirs}
                '';
              });
            # useful for debugging:
            nixpkgs-in = pkgs;
          };

          defaultPackage = packages.cq-editor;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/cq-editor";
          };
        }
      );
}
