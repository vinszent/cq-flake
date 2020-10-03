{
  description = "CQ-editor and CadQuery from submodules";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery = {
      url = "github:cadquery/cadquery/master";
      flake = false;
    };
    cq-editor = {
      url = "github:cadquery/cq-editor";
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
            python37 = pkgs.python37.override {
              packageOverrides = python-self : python-super: {
                cadquery = python-super.callPackage ./cadquery.nix { documentation = false; src = inputs.cadquery; };
                cadquery_w_docs = python-super.callPackage ./cadquery.nix { documentation = true; src = inputs.cadquery; };
                ocp = python-super.callPackage ./OCP {
                  opencascade-occt = packages.opencascade-occt; 
                };
                clang = python-super.callPackage ./clang.nix { };
                cymbal = python-super.callPackage ./cymbal.nix { };
                geomdl = python-super.callPackage ./geomdl.nix { };
                ezdxf = python-super.callPackage ./ezdxf.nix { };
                sphinx = python-super.callPackage ./sphinx.nix { };
                nptyping = python-super.callPackage ./nptyping.nix { };
                typish = python-super.callPackage ./typish.nix { };
              };
            };
            cq-editor = pkgs.libsForQt5.callPackage ./cq-editor.nix {
              python3Packages = packages.python37.pkgs;
              src = inputs.cq-editor;
            };
            # looks like the current release of OCP uses 7.4.0, not the most recent 7.4.0p1 release
            opencascade-occt = pkgs.callPackage ./opencascade-occt/7_4_0.nix { };
            cadquery-docs = packages.python37.pkgs.cadquery_w_docs.doc;
            cadquery-env = packages.python37.withPackages (ps: with ps; [ cadquery python-language-server ] );
          };

          defaultPackage = packages.cq-editor;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/cq-editor";
          };
        }
      );

}
