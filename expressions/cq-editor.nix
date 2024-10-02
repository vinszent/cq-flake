{ lib
, mkDerivationWith
, python3Packages
  # , fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, src
}:

mkDerivationWith python3Packages.buildPythonApplication {
  pname = "cq-editor";
  version = "local";

  # src = ./CQ-editor;
  inherit src;

  propagatedBuildInputs = with python3Packages; [
    cadquery
    logbook
    nlopt
    pyqt5
    pyparsing
    pyqtgraph
    cq-kit
    cq-warehouse
    build123d
    # spyder_3
    spyder
    pathpy
    qtconsole
    requests
  ];

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  # cq-editor crashes when trying to use Wayland, so force xcb
  qtWrapperArgs = [ "--set QT_QPA_PLATFORM xcb" ];

  postFixup = ''
    wrapQtApp "$out/bin/cq-editor"
  '';

  postInstall = ''
    install -Dm644 icons/cadquery_logo_dark.svg $out/share/icons/hicolor/scalable/apps/cadquery.svg

    rm $out/bin/CQ-editor
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

  desktopItems = [
    (makeDesktopItem {
      name = "com.cadquery.CadQuery";
      desktopName = "CadQuery";
      icon = "cadquery";
      exec = "cq-editor %f";
      categories = [ "Graphics" "3DGraphics" "Engineering" ];
      type = "Application";
      comment = "CadQuery GUI editor based on PyQT";
    })
  ];

  meta = with lib; {
    description = "CadQuery GUI editor based on PyQT";
    homepage = "https://github.com/CadQuery/CQ-editor";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };

}
