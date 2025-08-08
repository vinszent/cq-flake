{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  tomli,
  psutil,
  mslex,
  colorama
}: let
  pname = "taskipy";
  version = "1.14.1";
  src = fetchFromGitHub {
    owner = "taskipy";
    repo = "taskipy";
    rev = version;
    hash = "sha256-fiY0rlOmkBtrxGxXcjGcDz2JoiOHY+NyWAoF1Od+dbI=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    pyproject = true;

    build-system = [
      poetry-core
    ];

    patchPhase = ''
      substituteInPlace pyproject.toml \
        --replace-fail "poetry>=0.12" "poetry-core" \
        --replace-fail "poetry.masonry.api" "poetry.core.masonry.api" \
        --replace-fail ">=5.7.2,<7" ">=5.7.2,<8"
    '';

    dependencies = [
      tomli
      psutil
      mslex
      colorama
    ];
  }
