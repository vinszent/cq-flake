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
}: self: super: rec {

  clang = self.callPackage ./clang.nix {
    inherit llvmPackages;
  };

  cymbal = self.callPackage ./cymbal.nix { };

  casadi = self.toPythonModule casadi_nonpython;

  geomdl = self.callPackage ./geomdl.nix { };

  nptyping = super.nptyping.overridePythonAttrs (old: rec {
    version = "2.0.1";
    src = fetchFromGitHub {
      owner = "ramonhagenaars";
      repo = old.pname;
      rev = "refs/tags/v${version}";
      sha256 = "sha256-f4T2HpPb+Z+r0rjhh9sdDhVe8jnelHzPrA0axEuRckY=";
    };
    disabledTestPaths = [ "tests/test_wheel.py" "tests/test_mypy.py" ];
  });

  stdio-mgr = self.callPackage ./stdio-mgr.nix { };

  sphinxcadquery = self.callPackage ./sphinxcadquery.nix { };

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

  nlopt = self.toPythonModule nlopt_nonpython;

  pybind11-stubgen = self.callPackage ./OCP/pybind11-stubgen.nix {
    src = pybind11-stubgen-src;
  };
}
