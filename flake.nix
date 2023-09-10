{
  description = "CQ-editor and CadQuery";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = "https://marcus7070.cachix.org";
    extra-trusted-public-keys = "marcus7070.cachix.org-1:JawxHSgnYsgNYJmNqZwvLjI4NcOwrcEZDToWlT3WwXw=";
  };

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery/63afebea5fdea9d0faab3d0f7150285da417eca9";
      flake = false;
    };
    cq-editor-src = {
      url = "github:CadQuery/CQ-editor/adf11592c96c2d8490e1e8d332d1a9bb63f5c112";
      flake = false;
    };
    ocp-src = {
      url = "github:cadquery/ocp/546add850be61e3d8efaaddc9a1d0fa1bb8564c1";
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
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems ( system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          nlopt = pkgs.callPackage ./expressions/nlopt.nix { python = pkgs.python310; };
          scotch = pkgs.scotch.overrideAttrs (oldAttrs: {
            buildFlags = ["scotch ptscotch esmumps ptesmumps"];
            installFlags = ["prefix=\${out} scotch ptscotch esmumps ptesmumps" ];
          } );
          mumps = pkgs.callPackage ./expressions/mumps.nix { inherit scotch; };
          casadi = pkgs.callPackage ./expressions/casadi.nix {
            inherit mumps scotch;
            python = pkgs.python310;
          };
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt { };
          py-overrides = import expressions/py-overrides.nix {
            inherit (inputs) pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (pkgs) fetchFromGitHub;
            # NOTE(vinszent): Latest dev env uses LLVM 14.0.6 (https://github.com/CadQuery/OCP/blob/master/environment.devenv.yml)
            llvmPackages = pkgs.llvmPackages_14;
            occt = opencascade-occt;
            nlopt_nonpython = nlopt;
            casadi_nonpython = casadi;
          };
          python = pkgs.python310.override {
            packageOverrides = py-overrides;
            self = python;
          };
          cq-kit = python.pkgs.callPackage ./expressions/cq-kit {};
          cq-warehouse = python.pkgs.callPackage ./expressions/cq-warehouse.nix { };
        in rec {
          packages = {
            inherit (python.pkgs) cadquery;
            inherit cq-kit cq-warehouse;

            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs // { inherit cq-kit cq-warehouse; };
              src = inputs.cq-editor-src;
            };
          };

          defaultPackage = packages.cq-editor;
          apps.default = flake-utils.lib.mkApp { drv = defaultPackage; };
        }
      );
}
