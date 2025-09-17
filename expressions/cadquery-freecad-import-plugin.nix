{
  lib,
  buildPythonPackage,
  hatchling,
  cadquery,
  src,
}:

buildPythonPackage rec {
  pname = "cadquery-freecad-import-plugin";
  version = "1.0.0";
  format = "pyproject";

  inherit src;

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    cadquery
  ];

  pythonImportsCheck = [ "cadquery_freecad_import_plugin" ];

  meta = with lib; {
    description = "A plugin for importing FreeCAD models into CadQuery";
    homepage = "https://github.com/jmwright/cadquery-freecad-import-plugin";
    license = licenses.asl20;
  };
}
