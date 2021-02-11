{ lib
, mkDerivationWith
, python3Packages
# , fetchFromGitHub
, src
}:

mkDerivationWith python3Packages.buildPythonApplication {
  pname = "cq-editor";
  version = "local";

  # src = ./CQ-editor;
  inherit src;

  propagatedBuildInputs = with python3Packages; [
    cadquery
    Logbook
    pyqt5
    pyparsing
    pyqtgraph
    # spyder_3
    spyder
    pathpy
    qtconsole
    requests
  ];

  # cq-editor crashes when trying to use Wayland, so force xcb
  qtWrapperArgs = [ "--set QT_QPA_PLATFORM xcb" ];

  postFixup = ''
    wrapQtApp "$out/bin/cq-editor"
  '';

  checkInputs = with python3Packages; [
    pytest
    pytest-xvfb
    pytest-mock
    pytestcov
    pytest-repeat
    pytest-qt
  ];

  checkPhase = ''
    pytest --no-xvfb
  '';

  # requires X server
  doCheck = false;

  meta = with lib; {
    description = "CadQuery GUI editor based on PyQT";
    homepage = "https://github.com/CadQuery/CQ-editor";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };

}
