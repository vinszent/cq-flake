{
  fetchzip,
  writeShellScriptBin,
  python3,
}:
let
  frontend = fetchzip {
    url = "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v0.10.10/frontend.zip";
    hash = "sha256-+6LkNdf5+ThojdMdBBiBU2IhAw2GbWv3vVpMqjthGuI=";
  };
in
  writeShellScriptBin "yacv-frontend" "${python3}/bin/python -m http.server --directory ${frontend}"
