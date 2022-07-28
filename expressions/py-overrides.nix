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

  nptyping = self.callPackage ./nptyping { };

  typish = self.callPackage ./typish.nix { };

  sphinx-autodoc-typehints = self.callPackage ./sphinx-autodoc-typehints.nix { };

  sphobjinv = self.callPackage ./sphobjinv.nix { };

  stdio-mgr = self.callPackage ./stdio-mgr.nix { };

  sphinx-issues = self.callPackage ./sphinx-issues.nix { };

  sphinxcadquery = self.callPackage ./sphinxcadquery.nix { };

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

  vtk_9 = self.toPythonModule vtk_9_nonpython;

  nlopt = self.toPythonModule nlopt_nonpython;

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };

  qdarkstyle = (super.qdarkstyle.overrideAttrs (oldAttrs: rec {
    version = "3.0.2";
    src = self.fetchPypi {
      inherit version;
      pname = "QDarkStyle";
      sha256 = "sha256-VdFJz19A7ilzl/GBjgkRGM77hVpKnFw4VmxHrNLYx64=";
    };
  }));

  spyder = (super.spyder.overrideAttrs (oldAttrs: {
    propagatedBuildInputs = with self; oldAttrs.propagatedBuildInputs ++ [
      cookiecutter Rtree qstylizer jellyfish
    ];
  }));

  qstylizer = self.callPackage ./qstylizer.nix { };

  python-language-server = super.python-language-server.overrideAttrs (oldAttrs: { 
    # TODO: diagnose what's going on here and if I can replace python-language-server since:
    # https://github.com/palantir/python-language-server/pull/918#issuecomment-817361554
    meta.broken = false;
    disabledTests = oldAttrs.disabledTests ++ [
      "test_lint_free_pylint"
      "test_per_file_caching"
      "test_multistatement_snippet"
      "test_jedi_completion_with_fuzzy_enabled"
      "test_jedi_completion"
    ];
  });

  multimethod = super.multimethod.overrideAttrs (oldAttrs: rec {
    version = "1.8";
    src = oldAttrs.src // {
      rev = "v${version}";
      sha256 = "sha256-JuP1qGlrSffoQ6rRnf896K8PwqHEHiskmH8rd53qcdc=";
    };
  });

  numpydoc = super.numpydoc.overridePythonAttrs (oldAttrs: rec {
  #   # doCheck = false;
  #   # dontUsePytestCheck = true;
    version = "1.4.0";
    src = self.fetchPypi {
      inherit version;
      inherit (oldAttrs) pname;
      sha256 = "sha256-lJTa8cdhL1mQX6CeZcm4qQu6yzgE2R96lOd4gx5vz6U=";
    };
  });

  # joblib = super.joblib.overridePythonAttrs (oldAttrs: {
  #   checkInputs = [];
  #   doCheck = false;
  # });

  jinja2 = super.jinja2.overridePythonAttrs (oldAttrs: rec {
    version = "3.0.3";
    src = self.fetchPypi {
      inherit (oldAttrs) pname;
      inherit version;
      sha256 = "611bb273cd68f3b993fabdc4064fc858c5b47a973cb5aa7999ec1ba405c87cd7";
    };
  });
}
