{
  description = "CQ-editor and CadQuery";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery/471ab6fcc79b6ce64b857d33d06202c030cf5459";
      flake = false;
    };
    cq-editor-src = {
      url = "github:CadQuery/CQ-editor/0.4.0";
      flake = false;
    };
    ocp-src = {
      url = "github:cadquery/ocp/7.8.1.2";
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
    pybind11-stubgen-src = {
      url = "github:CadQuery/pybind11-stubgen";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      # someone else who can do the testing might want to extend this to other systems
      systems = [ "aarch64-linux" "x86_64-linux" ];
      overlay = final: prev: {
        # TODO: This was here but not actually referenced by anything.
        # scotch = prev.scotch.overrideAttrs (oldAttrs: {
        #   buildFlags = ["scotch ptscotch esmumps ptesmumps"];
        #   installFlags = ["prefix=\${out} scotch ptscotch esmumps ptesmumps" ];
        # } );
        opencascade-occt = final.callPackage ./expressions/opencascade-occt { };
        lib3mf-231 = final.callPackage ./expressions/lib3mf.nix {};
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(
          import expressions/py-overrides.nix {
            inherit (inputs) pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (final) fetchFromGitHub;
            # NOTE(vinszent): Latest dev env uses LLVM 15 (https://github.com/CadQuery/OCP/blob/master/environment.devenv.yml)
            llvmPackages = final.llvmPackages_15;
            occt = final.opencascade-occt;
            casadi = prev.casadi.override { pythonSupport=true; };
            lib3mf = final.lib3mf-231;
          }
        )];
        cq-editor = final.libsForQt5.callPackage ./expressions/cq-editor.nix {
          src = inputs.cq-editor-src;
        };
        yacv-env = final.python3.withPackages (pkgs: [pkgs.yacv-server]);
        yacv-frontend = final.callPackage ./expressions/yacv/frontend.nix {};
      };
    in {
      overlays.default = overlay;
    } // flake-utils.lib.eachSystem systems ( system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [overlay];
            config.permittedInsecurePackages = [
              "freeimage-3.18.0-unstable-2024-04-18"
            ];
          };
        in rec {
          packages = {
            inherit (pkgs.python3.pkgs) cadquery cq-kit cq-warehouse build123d;
            inherit (pkgs) python3 cq-editor yacv-env yacv-frontend;
            python = pkgs.python3;
          };

          legacyPackages = pkgs;

          defaultPackage = packages.cq-editor;
          apps.default = flake-utils.lib.mkApp { drv = defaultPackage; };
        }
      );
}
