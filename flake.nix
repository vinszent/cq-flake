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
    in
      flake-utils.lib.eachSystem systems ( system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
          };

          scotch = pkgs.scotch.overrideAttrs (oldAttrs: {
            buildFlags = ["scotch ptscotch esmumps ptesmumps"];
            installFlags = ["prefix=\${out} scotch ptscotch esmumps ptesmumps" ];
          } );
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt { };
          lib3mf-231 = pkgs.callPackage ./expressions/lib3mf.nix {};
          py-overrides = import expressions/py-overrides.nix {
            inherit (inputs) pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (pkgs) fetchFromGitHub;
            # NOTE(vinszent): Latest dev env uses LLVM 15 (https://github.com/CadQuery/OCP/blob/master/environment.devenv.yml)
            llvmPackages = pkgs.llvmPackages_15;
            occt = opencascade-occt;
            casadi = pkgs.casadi.override { pythonSupport=true; };
            lib3mf = lib3mf-231;
          };
          python = pkgs.python311.override {
            packageOverrides = py-overrides;
            self = python;
          };
        in rec {
          packages = {
            inherit (python.pkgs) cadquery cq-kit cq-warehouse build123d;
            inherit python;

            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs;
              src = inputs.cq-editor-src;
            };
            yacv-env = python.withPackages (pkgs: [pkgs.yacv-server]);
            yacv-frontend = pkgs.callPackage ./expressions/yacv/frontend.nix {};
          };

          defaultPackage = packages.cq-editor;
          apps.default = flake-utils.lib.mkApp { drv = defaultPackage; };
        }
      );
}
