{
  llvmPackages
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , occt
  , fetchFromGitHub
  , casadi
  , pybind11-stubgen-src
  , lib3mf
}: self: super: rec {

  clang = self.callPackage ./clang.nix {
    inherit llvmPackages;
  };

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

  nlopt = self.callPackage ./nlopt.nix { };

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  cq-kit = self.callPackage ./cq-kit {};

  cq-warehouse = self.callPackage ./cq-warehouse.nix { };

  qtconsole = self.callPackage ./qtconsole.nix {};

  spyder-kernels = self.callPackage ./spyder-kernels.nix {};

  spyder = self.callPackage ./spyder {};

  svgpathtools = self.callPackage ./svgpathtools.nix {};

  ocpsvg = self.callPackage ./ocpsvg.nix {};

  py-lib3mf = self.callPackage ./py-lib3mf.nix {inherit lib3mf;};

  trianglesolver = self.callPackage ./trianglesolver.nix {};

  build123d = self.callPackage ./build123d.nix {};

  yacv-server = self.callPackage ./yacv/server.nix {};
}
