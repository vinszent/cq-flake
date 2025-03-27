{
  buildPythonPackage,
  fetchPypi,
  # Buildtime dependencies
  git,
  pytestCheckHook,
  setuptools-scm,
  # Runtime dependencies
  ocp,
  svgpathtools,
  svgelements,
}:
let
  pname = "ocpsvg";
  version = "0.5.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XNjb7Iv1kNNzqCquvqskGDgYWqsE7ihZ8zudeVa7+6Y=";
  };
in
buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  patchPhase = ''
    substituteInPlace pyproject.toml \
      --replace "cadquery-ocp" "ocp"
  '';

  build-system = [ setuptools-scm git ];

  nativeCheckInputs = [ pytestCheckHook ];

  dependencies = [ocp svgpathtools svgelements ];

}

