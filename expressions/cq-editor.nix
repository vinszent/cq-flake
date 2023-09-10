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
    #broken with CQ 0.5.2: cq-warehouse
    build123d
    # spyder_3
    spyder
    pathpy
    qtconsole
    requests

    hy
    hyrule
  ];

  postPatch = ''
    # "fa." icons were removed from qtawesome
    substituteInPlace cq_editor/widgets/viewer.py \
      --replace-fail "fa.square-o" "fa5.square" \
      --replace-fail "fa.square" "fa5s.square" \
      --replace-fail "fa.arrows-alt" "fa5s.arrows-alt"
    substituteInPlace cq_editor/icons.py \
      --replace-fail "fa.clock-o" "fa5.clock" \
      --replace-fail "fa.file-o" "fa5.file" \
      --replace-fail "fa.folder-open-o" "fa5.folder-open" \
      --replace-fail "fa.pencil" "fa5s.pencil-alt" \
      --replace-fail "fa.repeat" "fa6s.repeat" \
      --replace-fail "fa." "fa5s."
    # spyder no longer registers run cell actions
    sed -i '/removeAction/d' cq_editor/widgets/editor.py
  '';

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

    mv $out/bin/CQ-editor $out/bin/cq-editor
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
