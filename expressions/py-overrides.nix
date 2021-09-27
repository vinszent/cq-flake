{
  gccSet
  , llvm-src
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , occt
  , fetchFromGitHub
  , vtk_9_nonpython
  , nlopt_nonpython
  , pybind11-stubgen-src
}: self: super: rec {

  clang = self.callPackage ./clang.nix {
    src = llvm-src;
    llvmPackages = gccSet.llvmPackages;
  };

  cymbal = self.callPackage ./cymbal.nix { };

  dictdiffer = self.callPackage ./dictdiffer.nix { };

  geomdl = self.callPackage ./geomdl.nix { };

  ezdxf = self.callPackage ./ezdxf.nix { };

  sphinx = self.callPackage ./sphinx.nix { };

  nptyping = self.callPackage ./nptyping.nix { };

  typish = self.callPackage ./typish.nix { };

  sphinx-autodoc-typehints = self.callPackage ./sphinx-autodoc-typehints.nix { };

  sphobjinv = self.callPackage ./sphobjinv.nix { };

  stdio-mgr = self.callPackage ./stdio-mgr.nix { };

  sphinx-issues = self.callPackage ./sphinx-issues.nix { };

  sphinxcadquery = self.callPackage ./sphinxcadquery.nix { };

  black = self.callPackage ./black.nix { };

  # pybind11 = self.callPackage ./pybind11 { };

  pywrap = self.callPackage ./pywrap {
    src = pywrap-src;
    inherit (gccSet) llvmPackages;
  };

  pytest-flakefinder = self.callPackage ./pytest-flakefinder.nix { };

  ocp = self.callPackage ./OCP {
    src = ocp-src;
    inherit (gccSet) stdenv llvmPackages;
    opencascade-occt = occt; 
  };

  ocp-stubs = self.callPackage ./OCP/stubs.nix {
    src = ocp-stubs-src;
  };

  cadquery = self.callPackage ./cadquery.nix {
    src = cadquery-src;
  };

  cadquery_w_docs = self.callPackage ./cadquery.nix {
    documentation = true;
    src = cadquery-src;
  };

  pyls-black = super.pyls-black.overridePythonAttrs (old: rec {
    version = "0.4.6";
    src = fetchFromGitHub {
      owner = "rupert";
      repo = "pyls-black";
      rev = "v${version}";
      sha256 = "0cjf0mjn156qp0x6md6mncs31hdpzfim769c2lixaczhyzwywqnj";
    };
  });

  vtk_9 = self.toPythonModule vtk_9_nonpython;

  nlopt = self.toPythonModule nlopt_nonpython;

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  multimethod = self.callPackage ./multimethod.nix { };

}
