{
  llvmPackages
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  # , opencascade-occt
  , casadi
  , pybind11-stubgen-src
  , lib3mf
  , vtk
  , yacv-frontend
}: self: super: let
  vtkModule = self.toPythonModule (vtk.override {
    python3Packages = self;
    pythonSupport = true;
  });
in rec {
  pywrap = self.callPackage ./pywrap {
    inherit llvmPackages;
    src = pywrap-src;
  };

  ocp = self.callPackage ./OCP {
    inherit llvmPackages;
    src = ocp-src;
    vtk = vtkModule;
    # inherit opencascade-occt;
  };

  ocp-stubs = self.callPackage ./OCP/stubs.nix {
    src = ocp-stubs-src;
  };

  cadquery = self.callPackage ./cadquery.nix {
    src = cadquery-src;
    vtk = vtkModule;
  };

  taskipy = self.callPackage ./taskipy.nix {};

  # nlopt = self.callPackage ./nlopt.nix { };

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  cq-kit = self.callPackage ./cq-kit {};

  cq-warehouse = self.callPackage ./cq-warehouse.nix { };

  svgpathtools = self.callPackage ./svgpathtools.nix {};

  ocpsvg = self.callPackage ./ocpsvg.nix {};

  py-lib3mf = self.callPackage ./py-lib3mf.nix {inherit lib3mf;};

  trianglesolver = self.callPackage ./trianglesolver.nix {};

  build123d = self.callPackage ./build123d.nix {
    vtk = vtkModule;
  };

  bd_warehouse = self.callPackage ./bd-warehouse.nix {};

  yacv-server = self.callPackage ./yacv/server.nix {
    inherit yacv-frontend;
  };
}
