{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  git,
  pytestCheckHook,
  setuptools-scm,
  # Runtime dependencies
  anytree,
  ezdxf,
  ipython,
  numpy,
  ocp,
  ocpsvg,
  py-lib3mf,
  scipy,
  svgpathtools,
  trianglesolver,
  vtk,
}: let
  pname = "build123d";
  version = "0.9.1";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "v${version}";
    deepClone = true;
    hash = "sha256-A4XgB10QVU/zv6TXILIQ73FyZ/msb7vDss3vXAEaJiA=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    format = "pyproject";

    patchPhase = ''
      substituteInPlace pyproject.toml \
        --replace "cadquery-ocp" "ocp"
    '';

    nativeBuildInputs = [
      git
      pytestCheckHook
      setuptools-scm
    ];

    propagatedBuildInputs = [
      anytree
      ezdxf
      ipython
      numpy
      ocp
      ocpsvg
      py-lib3mf
      scipy
      svgpathtools
      trianglesolver
      vtk
    ];

    disabledTests = [
      # These attempt to access the network
      "test_assembly_with_oriented_parts"
      "test_move_single_object"
      "test_single_label_color"
      "test_single_object"
    ];

  }
