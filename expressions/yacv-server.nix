{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  build123d,
  pygltflib,
  pillow,
}: let
  pname = "yacv-server";
  version = "0.8.10";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-IA6BtTD1vpbVj8GpLA24tYUr0wVdOSCgCsjgthK/oTE=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    format = "pyproject";

    SKIP_BUILD_FRONTEND = "1";

    nativeBuildInputs = [
      poetry-core
    ];

    propagatedBuildInputs = [
      build123d
      pygltflib
      pillow
    ];
  }
