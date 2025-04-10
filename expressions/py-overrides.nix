{
  pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , pybind11-stubgen-src
}: self: super: {

  # NOTE(vinszent): Latest dev env uses LLVM 15 (https://github.com/CadQuery/OCP/blob/master/environment.devenv.yml)

  cqLlvmPackages = self.pkgs.llvmPackages_15;

  opencascade-occt = self.callPackage ./opencascade-occt { };

  casadi = super.casadi.override {
    pythonSupport = true;
  };

  clang = self.callPackage ./clang.nix {
    llvmPackages = self.cqLlvmPackages;
  };

  pywrap = self.callPackage ./pywrap {
    llvmPackages = self.cqLlvmPackages;
    src = pywrap-src;
  };

  ocp = self.callPackage ./OCP {
    llvmPackages = self.cqLlvmPackages;
    src = ocp-src;
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

  lib3mf = self.callPackage ./lib3mf.nix {};

  py-lib3mf = self.callPackage ./py-lib3mf.nix {
    inherit (self) lib3mf;
  };

  trianglesolver = self.callPackage ./trianglesolver.nix {};

  build123d = self.callPackage ./build123d.nix {};

  yacv-server = self.callPackage ./yacv/server.nix {};
}
