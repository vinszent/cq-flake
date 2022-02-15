{
  stdenv
  , lib
  , fetchurl
  , cmake
  , libGLU
  , libGL
  , libX11
  , xorgproto
  , libXt
  , libpng
  , libtiff
  , fetchpatch
  , enableQt ? false
  , wrapQtAppsHook
  , qtbase
  , qtx11extras
  , qttools
  , enablePython ? false
  , pythonInterpreter ? throw "vtk: Python support requested, but no python interpreter was given."
  # cq-specific
  , tk
  , tcl
  , utf8cpp
  , double-conversion
  , lz4
  , lzma
  , libjpeg
  , pugixml
  , expat
  , jsoncpp
  , glew
  , eigen
  , hdf5
  , libogg
  , libtheora
  , netcdf
  , libxml2
  , ffmpeg
  , gl2ps
  , sqlite
  , proj
}:

let
  majorVersion = "9.1";
  minorVersion = "0";
  sourceSha256 = "sha256-j+1C9Pjx64CDEHto6qmtcdoHEQFhoxFq2Af0PlylzpY=";
  patchesToFetch = [];
  inherit (lib) optionalString optionals optional;

  pythonMajor = lib.substring 0 1 pythonInterpreter.pythonVersion;

in stdenv.mkDerivation rec {
  pname = "vtk${optionalString enableQt "-qvtk"}";
  version = "${majorVersion}.${minorVersion}";

  src = fetchurl {
    url = "https://www.vtk.org/files/release/${majorVersion}/VTK-${version}.tar.gz";
    sha256 = sourceSha256;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libpng libtiff ]
    ++ optionals enableQt [ qtbase qtx11extras qttools ]
    ++ optionals stdenv.isLinux [
      libGLU
      libGL
      libX11
      xorgproto
      libXt
    ] ++ optional enablePython [
      pythonInterpreter
    ]
    # extra cq-specific build inputs:
    ++ [
      tk
      tk.dev
      tcl
      utf8cpp
      double-conversion
      lz4
      lzma
      libjpeg
      pugixml
      libtiff
      expat
      jsoncpp
      glew
      eigen
      hdf5
      libogg
      libtheora
      netcdf
      libxml2
      ffmpeg
      gl2ps
      sqlite
      proj.dev
    ];

  patches = map fetchpatch patchesToFetch;

  preBuild = ''
    export LD_LIBRARY_PATH="$(pwd)/lib";
  '';

  dontWrapQtApps = true;

  # Shared libraries don't work, because of rpath troubles with the current
  # nixpkgs cmake approach. It wants to call a binary at build time, just
  # built and requiring one of the shared objects.
  # At least, we use -fPIC for other packages to be able to use this in shared
  # objects.
  cmakeFlags = [
    "-DCMAKE_C_FLAGS=-fPIC"
    "-DCMAKE_CXX_FLAGS=-fPIC"
    "-D${if lib.versionOlder version "9.0" then "VTK_USE_SYSTEM_PNG" else "VTK_MODULE_USE_EXTERNAL_vtkpng"}=ON"
    "-D${if lib.versionOlder version "9.0" then "VTK_USE_SYSTEM_TIFF" else "VTK_MODULE_USE_EXTERNAL_vtktiff"}=1"
    "-DOPENGL_INCLUDE_DIR=${libGL}/include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_BINDIR=bin"
  ] ++ optionals enableQt [
    "-D${if lib.versionOlder version "9.0" then "VTK_Group_Qt:BOOL=ON" else "VTK_GROUP_ENABLE_Qt:STRING=YES"}"
  ] ++ optionals (enableQt && lib.versionOlder version "8.0") [
    "-DVTK_QT_VERSION=5"
  ]
    ++ optionals enablePython [
      "-DVTK_WRAP_PYTHON:BOOL=ON"
      "-DVTK_PYTHON_VERSION:STRING=${pythonMajor}"
  ]
  # cq-specific flags:
  ++ [
    "-DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=OFF"
    "-DVTK_OPENGL_HAS_OSMESA:BOOL=OFF"
    "-DVTK_USE_TK:BOOL=ON"
    "-DTCL_INCLUDE_PATH=${tcl}/include"
    "-DTK_INCLUDE_PATH=${tk.dev}/include"
    "-DTCL_LIBRARY:FILEPATH=${tcl}/lib/libtcl.so"
    "-DTK_LIBRARY:FILEPATH=${tk}/lib/libtk.so"
    "-DVTK_USE_X:BOOL=ON"
    "-DBUILD_SHARED_LIBS:BOOL=ON"
    "-DVTK_LEGACY_SILENT:BOOL=OFF"
    "-DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO"
    "-DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_ViewsContext2D:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_PythonContext2D:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_RenderingContext2D:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_RenderingCore:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES"
    "-DVTK_MODULE_ENABLE_VTK_WebGLExporter:STRING=YES"
    "-DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON"
    # "-DVTK_USE_EXTERNAL:BOOL=ON"
    "-DVTK_MODULE_USE_EXTERNAL_VTK_libharu:BOOL=OFF"
    "-DVTK_MODULE_USE_EXTERNAL_VTK_pegtl:BOOL=OFF"
  ];

  postInstall = ''
    cp -r ../ThirdParty $out/include/
  '';

  meta = with lib; {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ knedlsepp tfmoraes lheckemann ];
    platforms = with platforms; unix;
  };
}
