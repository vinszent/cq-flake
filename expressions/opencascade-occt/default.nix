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
  , vtk_9
  , xorg
  , freetype
  , freeimage
  , fontconfig
  , tbb
  , rapidjson
  , glew
}:
let
  vtk_version = lib.versions.majorMinor vtk_9.version;
in
  stdenv.mkDerivation rec {
  pname = "opencascade-occt";
  version = "7.5.2";
  commit = "V${builtins.replaceStrings ["."] ["_"] version}";

  src = fetchurl {
    name = "occt-${commit}.tar.gz";
    url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
    sha256 = "sha256-NHEbCuyEoNzfZQ7ZD98fi5O0FBxhu22YVolUU23VTn0=";
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
    glew
  ] ++ vtk_9.buildInputs;

  patches = [
  #   (fetchpatch {
  #     url = "https://github.com/conda-forge/occt-feedstock/raw/429f53c9bcc1fc8c1ef00d31875d284b6b6b692f/recipe/fix-brepblend.patch";
  #     sha256 = "sha256-Lfip+LseXmYlXbpoS6/HwqahjmrBHEoUbOD8V13G8cE=";
  #   })
  #   (fetchpatch {
  #     url = "https://github.com/conda-forge/occt-feedstock/raw/429f53c9bcc1fc8c1ef00d31875d284b6b6b692f/recipe/vtk.patch";
  #     sha256 = "sha256-/ph8ijQEjqV/wPwqrzmNtmn/T59AB2omGHH64F67xbY=";
  #   })
  #   (fetchpatch {
  #     url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/4c0508cf97179058e9ddc6bd9e8693c29537cd20/recipe/fix-private-linking.patch";
  #     sha256 = "sha256-+2ejlbSnmoP52+O8aiJE3915vYk6FhRd+8uUJAovssI=";
  #   })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/4febc64557e813d4f1dbae34ca38468308cb0efb/recipe/ShapeUpgrade.patch";
      sha256 = "sha256-fBgkNjP3cuXOtwfIHwiSMfvMYNdog1Oz/aiRVh/PAvE=";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/4febc64557e813d4f1dbae34ca38468308cb0efb/recipe/no-xmu.patch";
      sha256 = "sha256-YRNZbkFuqIoKm73Y7zx+X4PKO1Ba0mAl7YzjOkvWc+M=";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/4febc64557e813d4f1dbae34ca38468308cb0efb/recipe/error-checking.patch";
      sha256 = "sha256-5D9P9QaZDllzcnRJQvE+YECSeMyNC9yYyLAsoeE6Dyc=";
    })
  ];

  # I've removed the 3RDPARTY_DIR flag, not really sure if it's needed or not
  cmakeFlags = [
    "-D BUILD_MODULE_Draw:BOOL=OFF"
    "-D USE_TBB:BOOL=ON"
    "-D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF"
    "-D USE_VTK:BOOL=ON"
    "-D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH=${vtk_9}/lib"
    "-D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH=${vtk_9}/include/vtk-${vtk_version}"
    "-D VTK_RENDERING_BACKEND:STRING=\"OpenGL2\""
    "-D USE_FREEIMAGE:BOOL=ON"
    "-D USE_RAPIDJSON:BOOL=ON"
    "-DBUILD_LIBRARY_TYPE:STRING=Shared"
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
