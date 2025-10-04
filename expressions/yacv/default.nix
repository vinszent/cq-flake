{
  buildPythonPackage,
  python3,
  fetchFromGitHub,
  fetchzip,
  writeShellScript,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  build123d,
  pygltflib,
  pillow,
}:
let
  pname = "yacv-server";
  version = "0.10.11";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-u9StuQqfyf3NCSbdh4obDcLJbjS9wfCNNpfd8nuaK/E=";
  };

  frontend = fetchzip {
    url = "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v${version}/frontend.zip";
    hash = "sha256-yogt3MQ2lNR5bG1USF9teRbH+Zn7Hyq7ptTtTtBHKWI=";
  };

  serve-frontend = writeShellScript "yacv-frontend" "${python3}/bin/python -m http.server --directory ${frontend}";
in
buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  patches = [ ./pyproject.toml.patch ];

  postInstall = ''
    cp -r ${frontend} $out/${python3.sitePackages}/yacv_server/frontend
    mkdir -p $out/bin
    cp ${serve-frontend} $out/bin/yacv-frontend
  '';

  nativeBuildInputs = [
    poetry-core
  ];

  dependencies = [
    build123d
    pygltflib
    pillow
  ];
}
