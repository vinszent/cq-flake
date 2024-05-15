{
  llvmPackages
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , occt
  , fetchFromGitHub
  , nlopt_nonpython
  , casadi_nonpython
  , pybind11-stubgen-src
  , lib3mf
}: self: super: rec {

  clang = self.callPackage ./clang.nix {
    inherit llvmPackages;
  };

  casadi = self.toPythonModule casadi_nonpython;

  pywrap = self.callPackage ./pywrap {
    inherit llvmPackages;
    src = pywrap-src;
  };

  ocp = self.callPackage ./OCP {
    llvmPackages = llvmPackages;
    src = ocp-src;
    opencascade-occt = occt;
  };

  ocp-stubs = self.callPackage ./OCP/stubs.nix {
    src = ocp-stubs-src;
  };

  cadquery = self.callPackage ./cadquery.nix {
    src = cadquery-src;
  };

  nlopt = self.toPythonModule nlopt_nonpython;

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  svgpathtools = self.callPackage ./svgpathtools.nix {};

  ocpsvg = self.callPackage ./ocpsvg.nix {};

  py-lib3mf = self.callPackage ./py-lib3mf.nix {inherit lib3mf;};

  trianglesolver = self.callPackage ./trianglesolver.nix {};

  ezdxf = self.callPackage ./ezdxf.nix {};

  build123d = self.callPackage ./build123d.nix {};
}
