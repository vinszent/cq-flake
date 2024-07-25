# adapted from github:conda-forge/occt-feedstock which is the canonical cadquery source.
{
  stdenv
  , lib
  , fetchurl
  , fetchpatch
  , cmake
  , ninja
  , tcl
  , tk
  , libGL
  , libGLU
  , libXext
  , libXmu
  , libXi
  , vtk
  , xorg
  , freetype
  , freeimage
  , fontconfig
  , tbb_2021_11
  , rapidjson
  , glew
}:
let
  vtk_version = lib.versions.majorMinor vtk.version;
in
  stdenv.mkDerivation rec {
  pname = "opencascade-occt";
  version = "7.7.2";
  commit = "V${builtins.replaceStrings ["."] ["_"] version}";

  src = fetchurl {
    name = "occt-${commit}.tar.gz";
    url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
    sha256 = "sha256-M0G/pJuxsJu5gRk0rIgC173/XxI1ERpmCtWjgr/0dyY=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    tcl
    tk
    libGL
    libGLU
    libXext
    libXmu
    libXi
    vtk
    xorg.libXt
    freetype
    freeimage
    fontconfig
    tbb_2021_11
    rapidjson
    glew
  ] ++ vtk.buildInputs;

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/00ff0f68644d9582a4c30c01220e7de0f934d427/recipe/patches/blobfish.patch";
      sha256 = "sha256-5tqkx7W7VBw7qaseFgwBENKbGQ0iUYEL6SJHwGI9L/g=";
    })
  ];

  # I've removed the 3RDPARTY_DIR flag, not really sure if it's needed or not
  cmakeFlags = [
    "-D BUILD_MODULE_Draw:BOOL=OFF"
    "-D USE_TBB:BOOL=ON"
    "-D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF"
    "-D USE_VTK:BOOL=ON"
    "-D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH=${vtk}/lib"
    "-D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH=${vtk}/include/vtk"
    "-D VTK_RENDERING_BACKEND:STRING=\"OpenGL2\""
    "-D USE_FREEIMAGE:BOOL=ON"
    "-D USE_RAPIDJSON:BOOL=ON"
  ];

  seperateDebugInfo = true;

  meta = with lib; {
    description = "Open CASCADE Technology, libraries for 3D modeling and numerical simulation";
    homepage = "https://www.opencascade.org/";
    license = licenses.lgpl21;  # essentially...
    # The special exception defined in the file OCCT_LGPL_EXCEPTION.txt
    # are basically about making the license a little less share-alike.
    maintainers = with maintainers; [ marcus7070 ];
    platforms = platforms.all;
  };

}
