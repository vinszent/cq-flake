{
  fetchzip,
  writeShellScriptBin,
  python3,
}:
let
  frontend = fetchzip {
    url = "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v0.9.2/frontend.zip";
    hash = "sha256-d5qKs9h4q9/hquVgWFb10KSE2gWTSAZQgYo9l0bzdVM=";
  };
in
  writeShellScriptBin "yacv-frontend" "${python3}/bin/python -m http.server --directory ${frontend}"
