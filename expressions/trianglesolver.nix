{
  buildPythonPackage,
  fetchPypi,
}:
let
  pname = "trianglesolver";
  version = "1.2";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SvGKreV51cDWQ4mz5lrq8Gz/JjGXYszYWeMmhVmnauo=";
  };
in
buildPythonPackage {
  inherit src pname version;
  format = "setuptools";

  checkPhase = ''
    python -c 'import trianglesolver; trianglesolver.run_lots_of_tests()'
  '';
}

