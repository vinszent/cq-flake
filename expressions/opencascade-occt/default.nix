{
 fetchpatch
, opencascade-occt
, tbb_2021
, vtk
}:

opencascade-occt.overrideAttrs (o: rec {
  buildInputs = o.buildInputs ++ [
    tbb_2021
    vtk
  ];

  # I've removed the 3RDPARTY_DIR flag, not really sure if it's needed or not
  cmakeFlags = o.cmakeFlags ++ [
    # "-D BUILD_MODULE_Draw:BOOL=OFF"
    "-D USE_TBB:BOOL=ON"
    "-D USE_VTK:BOOL=ON"
    "-D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH=${vtk}/lib"
    "-D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH=${vtk}/include/vtk"

    "-D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF"
    # "-D VTK_RENDERING_BACKEND:STRING=\"OpenGL2\""

    # freeimage is broken in upstream nixpkgs:
    # https://github.com/NixOS/nixpkgs/issues/420975
    # "-D USE_FREEIMAGE:BOOL=ON"
  ];

  patches = o.patches ++ [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/b0960c3ec14c6213fbaef5f1c5d9d8f1d8e7c1ba/recipe/patches/blobfish.patch";
      sha256 = "sha256-wbBPJLO4amPXsIk8Nn9NQv8aypq0ndv/A7OcAfnYqfk=";
    })
  ];

  separateDebugInfo = true;
})
