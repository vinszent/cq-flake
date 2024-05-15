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
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "v${version}";
    deepClone = true;
    hash = "sha256-N+WQcBP1NauCsNVNwumIOA3ARw24guf3LGktFWQdVD8=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    format = "pyproject";

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
  }
