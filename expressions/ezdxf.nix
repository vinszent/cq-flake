{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  pytestCheckHook,
  # Buildtime deps
  setuptools,
  wheel,
  cython,
  # Runtime deps
  pyparsing,
  typing-extensions,
  numpy,
  fonttools,
}:
buildPythonPackage rec {
  version = "1.1.4";
  pname = "ezdxf";
  format = "pyproject";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "mozman";
    repo = "ezdxf";
    rev = "refs/tags/v${version}";
    hash = "sha256-1dwVAZg76QAyCsEZ/lodNwAZqSF7hv0cOby413ETtdw=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
    cython
  ];

  propagatedBuildInputs = [
    pyparsing
    typing-extensions
    fonttools
    numpy
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "ezdxf"
    "ezdxf.addons"
  ];

  meta = with lib; {
    description = "Python package to read and write DXF drawings (interface to the DXF file format)";
    mainProgram = "ezdxf";
    homepage = "https://github.com/mozman/ezdxf/";
    license = licenses.mit;
    maintainers = with maintainers; [hodapp];
    platforms = platforms.unix;
  };
}
