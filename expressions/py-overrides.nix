{
  llvmPackages
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , occt
  , fetchFromGitHub
  , casadi_nonpython
  , pybind11-stubgen-src
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

  nlopt = self.callPackage ./nlopt.nix { };

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };
}
