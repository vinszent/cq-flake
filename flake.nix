{
  description = "CQ-editor and CadQuery";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery/2.4.0";
      flake = false;
    };
    cq-editor-src = {
      url = "github:CadQuery/CQ-editor/4ef178af06d24a53fee87d576f8cada14c0111a3";
      flake = false;
    };
    ocp-src = {
      url = "github:cadquery/ocp/4b98a5dc79fa900f7429975708f6a8c2e41cecd1";
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
          python3Packages = final.python311.pkgs;
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
              "freeimage-unstable-2021-11-01"
            ];
          };
        in rec {
          packages = {
            inherit (pkgs.python311.pkgs) cadquery cq-kit cq-warehouse build123d;
            inherit (pkgs) python3 cq-editor yacv-env yacv-frontend;
            python = pkgs.python3;
          };

          defaultPackage = packages.cq-editor;
          apps.default = flake-utils.lib.mkApp { drv = defaultPackage; };
        }
      );
}
