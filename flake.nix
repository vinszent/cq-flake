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
          # keep gcc, llvm and stdenv versions in sync
          gccSet = {
            # have to use gcc9 because freeimage complains with gcc8, could probably build freeimage with gcc8 if I have to, but this is easier.
            llvmPackages = pkgs.llvmPackages_10; # canonical now builds with llvm10: https://github.com/CadQuery/OCP/commit/2ecc243e2011e1ea5c57023dee22e562dacefcdd
            stdenv = pkgs.gcc9Stdenv;
          };
          # I'm quite worried about how I handle this VTK. Python -> VTK (for Python bindings) -> OCCT -> Python(OCP)
          new_vtk_9 = (pkgs.vtk_9.overrideAttrs ( oldAttrs: rec {
            patches = [
              # ./expressions/VTK/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
              ./expressions/VTK/64265c5fd1a8e26a6a81241284dea6b3272f6db6.patch
              (pkgs.fetchpatch {
                url = "https://gitlab.kitware.com/vtk/vtk/-/commit/711f57f811c6ffad2a09b0fb67276bcc68703013.patch";
                sha256 = "sha256-QuMwQVPP/+OauBX4VpqH+uVStfMixTvf6WF7C8nxvPs=";
              })
            ];
            # conda installation does not have OSMesa, so don't use it here
            cmakeFlags = oldAttrs.cmakeFlags ++ [
              "-DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=OFF"
              "-DVTK_OPENGL_HAS_OSMESA:BOOL=OFF"
              "-DVTK_USE_TK:BOOL=ON"
              "-DTCL_INCLUDE_PATH=${pkgs.tcl}/include"
              "-DTK_INCLUDE_PATH=${pkgs.tk.dev}/include"
              "-DTCL_LIBRARY:FILEPATH=${pkgs.tcl}/lib/libtcl.so"
              "-DTK_LIBRARY:FILEPATH=${pkgs.tk}/lib/libtk.so"
              "-DVTK_USE_X:BOOL=ON"
              "-DBUILD_SHARED_LIBS:BOOL=ON"
              "-DVTK_LEGACY_SILENT:BOOL=OFF"
              "-DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO"
              "-DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_ViewsContext2D:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_PythonContext2D:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_RenderingContext2D:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_RenderingCore:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES"
              "-DVTK_MODULE_ENABLE_VTK_WebGLExporter:STRING=YES"
              "-DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON"
              "-DVTK_USE_EXTERNAL:BOOL=ON"
              "-DVTK_MODULE_USE_EXTERNAL_VTK_libharu:BOOL=OFF"
              "-DVTK_MODULE_USE_EXTERNAL_VTK_pegtl:BOOL=OFF"
            ];
            buildInputs = with pkgs; oldAttrs.buildInputs ++ [
              tk
              tk.dev
              tcl
              utf8cpp
              double-conversion
              lz4
              lzma
              libjpeg
              pugixml
              libtiff
              expat
              jsoncpp
              glew
              eigen
              hdf5
              libogg
              libtheora
              netcdf
              libxml2
              ffmpeg
              gl2ps
              sqlite
              proj_7
            ];
          })).override {
            pythonInterpreter = python;
            enablePython = true;
            stdenv = pkgs.stdenvAdapters.keepDebugInfo gccSet.stdenv;
          };
          opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
            inherit (gccSet) stdenv;
            vtk_9 = new_vtk_9;
          };
          nlopt = pkgs.callPackage ./expressions/nlopt.nix {
            inherit python;
            pythonPackages = python.pkgs;
          };
          py-overrides = import expressions/py-overrides.nix {
            inherit gccSet;
            inherit (inputs) llvm-src pywrap-src ocp-src ocp-stubs-src cadquery-src pybind11-stubgen-src;
            inherit (pkgs) fetchFromGitHub;
            vtk_9_nonpython = new_vtk_9;
            occt = opencascade-occt;
            nlopt_nonpython = nlopt;
          };
          # python = pkgs.enableDebugging ((pkgs.python38.override {
          #   packageOverrides = py-overrides;
          #   self = python;
          # }).overrideAttrs (oldAttrs: { disallowedReferences = []; }));
          python = pkgs.python38.override {
            packageOverrides = py-overrides;
            self = python;
          };
          cq-kit = python.pkgs.callPackage ./expressions/cq-kit.nix {};

        in rec {
          packages = {
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = python.pkgs // { inherit cq-kit; };
              src = inputs.cq-editor-src;
            };
            cq-docs = python.pkgs.callPackage ./expressions/cq-docs.nix {
              src = inputs.cadquery-src;
            };
            cadquery-env = python.withPackages (
              ps: with ps; [ cadquery cq-kit python-language-server black mypy ocp-stubs pytest pytest-xdist pytest-cov pytest-flakefinder pybind11-stubgen ]
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
