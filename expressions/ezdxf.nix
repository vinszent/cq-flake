{ stdenv, lib, buildPythonPackage, pythonOlder, fetchFromGitHub, pyparsing, pytest, geomdl }:

buildPythonPackage rec {
  # somehow Conda & Pypi have 0.12.5, despite commit: https://github.com/mozman/ezdxf/commit/799adffe172491741bf956e151560839f30b3fca#diff-3d0319a79bc9efbe982a594984ad1564
  # taking ezdxf from 0.12.4 to 0.13b0.
  version = "0.13.1";
  pname = "ezdxf";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "mozman";
    repo = "ezdxf";
    rev = "d0b12ed8ddfa2225d11e61120d1f3ef24e4abb9c";
    sha256 = "1d4k8dnm8lcy7p8gy3yy1igiqrcyvh94kq85l8kqzy5fzp3fidjf";
  };

  checkInputs = [ pytest geomdl ];
  checkPhase = "pytest tests integration_tests";

  propagatedBuildInputs = [ pyparsing ];

  meta = with lib; {
    description = "Python package to read and write DXF drawings (interface to the DXF file format)";
    homepage = "https://github.com/mozman/ezdxf/";
    license = licenses.mit;
    maintainers = with maintainers; [ hodapp ];
    platforms = platforms.unix;
  };
}
