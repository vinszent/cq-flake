{
  description = "CQ-editor and CadQuery";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery = {
      url = "/home/marcus/tempbuild/cadquery";
      flake = false;
    };
    cq-editor = {
      url = "/home/marcus/tempbuild/CQ-editor";
      flake = false;
    };
    # OCP uses submodules, flake inputs don't support submodules
    # ocp = {
    #   url = "github:cadquery/ocp";
    #   flake = false;
    #   rev = "0059e425875fb6fa3e8b3f0335c9d08924e6726c";
    #   sha256 = "1h4m3y5k4chl1cdd0gy9vw0saf5vfwik0djgs64y1hfic9b4dgw1";
    #   fetchSubmodules = true;
    # };
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
                cadquery = python-super.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                };
                cadquery-debug = python-super.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                  ocp = packages.python38.pkgs.ocp-debug;
                };
                cadquery_w_docs = python-super.callPackage ./expressions/cadquery.nix {
                  documentation = true;
                  src = inputs.cadquery;
                };
                ocp = python-super.callPackage ./expressions/OCP {
                  opencascade-occt = packages.opencascade-occt; 
                };
                ocp-debug = python-super.callPackage ./expressions/OCP {
                  opencascade-occt = packages.opencascade-occt-debug; 
                  debug = true;
                };
                clang = python-super.callPackage ./expressions/clang.nix { };
                cymbal = python-super.callPackage ./expressions/cymbal.nix { };
                geomdl = python-super.callPackage ./expressions/geomdl.nix { };
                ezdxf = python-super.callPackage ./expressions/ezdxf.nix { };
                sphinx = python-super.callPackage ./expressions/sphinx.nix { };
                nptyping = python-super.callPackage ./expressions/nptyping.nix { };
                typish = python-super.callPackage ./expressions/typish.nix { };
                sphinx-autodoc-typehints = python-super.callPackage ./expressions/sphinx-autodoc-typehints.nix { };
                sphobjinv = python-super.callPackage ./expressions/sphobjinv.nix { };
                stdio-mgr = python-super.callPackage ./expressions/stdio-mgr.nix { };
                sphinx-issues = python-super.callPackage ./expressions/sphinx-issues.nix { };
                pytest-subtests = python-super.callPackage ./expressions/pytest-subtests.nix { };
                sphinxcadquery = python-super.callPackage ./expressions/sphinxcadquery.nix { };
                cq-kit = python-super.callPackage ./expressions/cq-kit.nix { };
              };
            };
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = packages.python38.pkgs;
              src = inputs.cq-editor;
            };
            opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt { };
            opencascade-occt-debug = packages.opencascade-occt.overrideAttrs (
              oldAttrs: rec {separateDebugInfo = true;}
            );
            cadquery-docs = packages.python38.pkgs.cadquery_w_docs.doc;
            cadquery-env = packages.python38.withPackages (
              ps: with ps; [ cadquery python-language-server cq-kit ]
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
