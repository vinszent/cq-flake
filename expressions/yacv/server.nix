{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  build123d,
  pygltflib,
  pillow,
  taskipy,

  yacv-frontend,
}: let
  pname = "yacv-server";
  version = "0.10.10";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-NELVfi9NI2ovyb5G03Z81htnyY8p6SaGtje7IQaljDM=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    pyproject = true;

    build-system = [
      poetry-core
      taskipy
    ];

    dependencies = [
      build123d
      pygltflib
      pillow
    ];

    preBuild = ''
    cp -r ${yacv-frontend} frontend
    '';
  }
