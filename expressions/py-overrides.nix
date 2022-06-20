{
  llvmPackages
  , llvm-src
  , pywrap-src
  , ocp-src
  , ocp-stubs-src
  , cadquery-src
  , occt
  , fetchFromGitHub
  , vtk_9_nonpython
  , nlopt_nonpython
  , pkg-config_nonpython
  , pybind11-stubgen-src
}: self: super: rec {

  clang = self.callPackage ./clang.nix {
    src = llvm-src;
    llvmPackages = llvmPackages;
  };

  casadi = self.callPackage ./casadi/casadi.nix {
    pkg-config = pkg-config_nonpython;
  };

  mumps = self.callPackage ./mumps.nix {
  };

  cymbal = self.callPackage ./cymbal.nix { };

  dictdiffer = self.callPackage ./dictdiffer.nix { };

  geomdl = self.callPackage ./geomdl.nix { };

  ezdxf = self.callPackage ./ezdxf.nix { };

  # sphinx = self.callPackage ./sphinx.nix { };

  typing = self.callPackage ./nptyping.nix { };

  nptyping = self.callPackage ./nptyping.nix { };

  typish = self.callPackage ./typish.nix { };

  sphinx-autodoc-typehints = self.callPackage ./sphinx-autodoc-typehints.nix { };

  sphobjinv = self.callPackage ./sphobjinv.nix { };

  stdio-mgr = self.callPackage ./stdio-mgr.nix { };

  sphinx-issues = self.callPackage ./sphinx-issues.nix { };

  sphinxcadquery = self.callPackage ./sphinxcadquery.nix { };

  path = self.callPackage ./path.nix { };

  pathpy = self.callPackage ./pathpy.nix { };

  # black = self.callPackage ./black.nix { };

  # pybind11 = self.callPackage ./pybind11 { };

  pywrap = self.callPackage ./pywrap {
    src = pywrap-src;
  };

  pytest-flakefinder = self.callPackage ./pytest-flakefinder.nix { };

  ocp = self.callPackage ./OCP {
    src = ocp-src;
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

  vtk_9 = self.toPythonModule vtk_9_nonpython;

  nlopt = self.toPythonModule nlopt_nonpython;

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  python-lsp-black = self.callPackage ./python-lsp-black.nix { };

  python-lsp-server = self.callPackage ./python-lsp-server.nix { };

  python-lsp-jsonrpc = self.callPackage ./python-lsp-jsonrpc.nix { };

  qdarkstyle = (super.qdarkstyle.overrideAttrs (oldAttrs: rec {
    version = "3.0.2";
    src = self.fetchPypi {
      inherit version;
      pname = "QDarkStyle";
      sha256 = "sha256-VdFJz19A7ilzl/GBjgkRGM77hVpKnFw4VmxHrNLYx64=";
    };
  }));

  rtree = self.callPackage ./rtree.nix { };

  qstylizer = self.callPackage ./qstylizer.nix { };

}
