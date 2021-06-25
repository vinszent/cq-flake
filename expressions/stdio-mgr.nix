{ 
  stdenv
  , lib
  , buildPythonPackage
  , fetchFromGitHub
  , pytestCheckHook
  , attrs
}:

buildPythonPackage rec {
  version = "1.0.1";
  pname = "stdio-mgr";

  src = fetchFromGitHub {
    owner = "bskinn";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-LLp4AmUfuYUX/gHK7Qwge1ib3DBsmxdhFybIo9M5ZnU=";
    fetchSubmodules = true;
  };

  # propagatedBuildInputs = [
  #   attrs
  # ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    # stdout gets a bit garbled somewhere, might have to do with it usually being run by tox? Just skip.
    "README.rst"
  ];

  pythonImportsCheck = [ "stdio_mgr" ];

  meta = with lib; {
    description = "Context manager for mocking/wrapping stdin/stdout/stderr";
    homepage = "https://github.com/bskinn/stdio-mgr/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
