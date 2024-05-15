{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  setuptools,
  lib3mf,
}:
let
  pname = "py-lib3mf";
  version = "2.3.1";
  src = fetchFromGitHub {
    owner = "jdegenstein";
    repo = pname;
    rev = "44411b9120f789676a6289dc9ae045741a011a3f";
    hash = "sha256-WovqHQiv2dymd8kxfIRsTJifD2AaDOoaaA8uxiq6nME=";
  };
in
buildPythonPackage {
  inherit src pname version;
  format = "pyproject";

  nativeBuildInputs = [ setuptools ];

  patchPhase = ''
    cp ${lib3mf}/lib/lib3mf.so.${version}.0 py_lib3mf/lib3mf.so
  '';

}

