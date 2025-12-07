{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
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
    hash = "sha256-pOYK6zXC5z0JohL4k/NMI/ALfHVKSJM5eM2bLcyKhpQ=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    format = "pyproject";

    env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

    patchPhase = ''
      substituteInPlace pyproject.toml \
        --replace "cadquery-ocp" "ocp"
    '';

    nativeBuildInputs = [
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
