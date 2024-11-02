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
  version = "0.2.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-61ZLN/Yk0ncPNtiSkE4V9mG+iqhEjzth19ceBHKyl60=";
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

