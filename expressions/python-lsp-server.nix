{ lib, buildPythonPackage, fetchFromGitHub, pythonOlder
, future, jedi, pluggy, python-jsonrpc-server, flake8
, numpy, pyqt5, pandas, matplotlib
, pytestCheckHook, mock, pytest-cov, coverage, setuptools, ujson, flaky, python-lsp-jsonrpc
, # Allow building a limited set of providers, e.g. ["pycodestyle"].
  providers ? ["*"]
  # The following packages are optional and
  # can be overwritten with null as your liking.
, autopep8 ? null
, mccabe ? null
, pycodestyle ? null
, pydocstyle ? null
, pyflakes ? null
, pylint ? null
, rope ? null
, yapf ? null
}:

let
  withProvider = p: builtins.elem "*" providers || builtins.elem p providers;
in

buildPythonPackage rec {
  pname = "python-lsp-server";
  version = "v1.3.3";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-server";
    rev = version;
    sha256 = "sha256-F8f9NAjPWkm01D/KwFH0oA6nQ3EF4ZVCCckZTL4A35Y=";
  };

  propagatedBuildInputs = [ setuptools jedi pluggy future python-jsonrpc-server ujson python-lsp-jsonrpc ]
    ++ lib.optional (withProvider "autopep8") autopep8
    ++ lib.optional (withProvider "mccabe") mccabe
    ++ lib.optional (withProvider "pycodestyle") pycodestyle
    ++ lib.optional (withProvider "pydocstyle") pydocstyle
    ++ lib.optional (withProvider "pyflakes") pyflakes
    ++ lib.optional (withProvider "pylint") pylint
    ++ lib.optional (withProvider "rope") rope
    ++ lib.optional (withProvider "yapf") yapf;

  # The tests require all the providers, disable otherwise.
  doCheck = providers == ["*"];

  checkInputs = [
    pytestCheckHook mock pytest-cov coverage flaky
    numpy pyqt5 pandas matplotlib
    # Do not propagate flake8 or it will enable pyflakes implicitly
    flake8
    # rope is technically a dependency, but we don't add it by default since we
    # already have jedi, which is the preferred option
    rope
  ];

  dontUseSetuptoolsCheck = true;

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  meta = with lib; {
    homepage = "https://github.com/python-lsp/python-language-server";
    description = "Fork of the python-language-server project, maintained by the Spyder IDE team and the community.";
    license = licenses.mit;
    maintainers = [ ];
  };
}
