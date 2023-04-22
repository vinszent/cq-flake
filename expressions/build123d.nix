{ buildPythonPackage, src, ocp, ocp-stubs, setuptools, typing-extensions, svgpathtools, numpy, anytree, ezdxf }:

buildPythonPackage rec {
  pname = "build123d";
  version = if (builtins.hasAttr "rev" src) then src.shortRev else "local-dev";
  format = "pyproject";
  inherit src;

  patches = [ ./no-git-dep.diff ];
  propagatedBuildInputs = [ ocp ocp-stubs setuptools typing-extensions svgpathtools numpy anytree ezdxf ];
}
