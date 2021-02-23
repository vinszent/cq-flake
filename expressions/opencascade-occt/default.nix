# adapted from github:conda-forge/occt-feedstock which is the canonical cadquery source.
{ 
  stdenv
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
  , vtk_9
  , xorg
  , freetype
  , freeimage
  , fontconfig
  , tbb
  , rapidjson
}:
stdenv.mkDerivation rec {
  pname = "opencascade-occt";
  version = "7.4.0";
  commit = "V${builtins.replaceStrings ["."] ["_"] version}";

  src = fetchurl {
    name = "occt-${commit}.tar.gz";
    url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
    sha256 = "0n6p9bjxi7j6aqf2wmhx31lhmmkizgychzri4l5y6lzgbh3w454n";
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
    vtk_9
    xorg.libXt
    freetype
    freeimage
    fontconfig
    tbb
    rapidjson
  ];

  # there are two more patches that I haven't bothered to apply, they don't seem important for a flake.
  patches = [
    (fetchpatch {
      url = "https://github.com/conda-forge/occt-feedstock/raw/429f53c9bcc1fc8c1ef00d31875d284b6b6b692f/recipe/fix-brepblend.patch";
      sha256 = "sha256-Lfip+LseXmYlXbpoS6/HwqahjmrBHEoUbOD8V13G8cE=";
    })
    (fetchpatch {
      url = "https://github.com/conda-forge/occt-feedstock/raw/429f53c9bcc1fc8c1ef00d31875d284b6b6b692f/recipe/vtk.patch";
      sha256 = "sha256-/ph8ijQEjqV/wPwqrzmNtmn/T59AB2omGHH64F67xbY=";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/4c0508cf97179058e9ddc6bd9e8693c29537cd20/recipe/fix-private-linking.patch";
      sha256 = "0x2h5wkrjicbamv87hyr56xmzr7j5pxl2170sg29hhxpl7bqzryv";
    })
  ];

  # I've removed the 3RDPARTY_DIR flag, not really sure if it's needed or not
  cmakeFlags = [
    "-D BUILD_MODULE_Draw:BOOL=OFF"
    "-D USE_TBB:BOOL=ON"
    "-D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF"
    "-D USE_VTK:BOOL=ON"
    "-D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH=${vtk_9}/lib"
    "-D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH=${vtk_9}/include/vtk-9.0"
    "-D VTK_RENDERING_BACKEND:STRING=\"OpenGL2\""
    "-D USE_FREEIMAGE:BOOL=ON"
    "-D USE_RAPIDJSON:BOOL=ON"
  ];

  meta = with stdenv.lib; {
    description = "Open CASCADE Technology, libraries for 3D modeling and numerical simulation";
    homepage = "https://www.opencascade.org/";
    license = licenses.lgpl21;  # essentially...
    # The special exception defined in the file OCCT_LGPL_EXCEPTION.txt
    # are basically about making the license a little less share-alike.
    maintainers = with maintainers; [ amiloradovsky ];
    platforms = platforms.all;
  };

}
