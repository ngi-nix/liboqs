let

  pkgs = import <nixpkgs> {};

  inherit (pkgs) stdenv fetchgit lib cmake ninja doxygen graphviz unzip openssl gcc astyle python39Packages python39 ;

  liboqs = stdenv.mkDerivation rec {
    pname = "liboqs";
    version = "0.7.0";
    src = fetchgit {
      sha256 = "149zvpg26lvqry98xk95dfdnb36fwd9s9jh2xyxy7fl2gcjg2c1k";
      url = "https://github.com/open-quantum-safe/liboqs.git";
    };
  
    phases = [ "installPhase" ];

    buildInputs = [ cmake ninja gcc openssl doxygen python39Packages.pytest-xdist python39Packages.pytest ];

    buildShareLib = false;
    debug = false;
    buildOnlyLib = false;
    distBuild = false;
    useOpenSSL = false;
    generic = false;

    cmakeFlags = [    
      "-DBUILD_SHARED_LIBS=${if buildShareLib then "ON" else "OFF"}"
      "-DCMAKE_BUILD_TYPE=${if debug then "Debug" else "Release"}"
      "-DOQS_BUILD_ONLY_LIB=${if buildOnlyLib then "ON" else "OFF"}"
      "-DOQS_DIST_BUILD=${if distBuild then "ON" else "OFF"}"
      "-DOQS_USE_OPENSSL=${if useOpenSSL then "ON" else "OFF"}"
      "-DOQS_OPT_TARGET=${if generic then "generic" else "auto"}"
      "-GNinja"
      ];

    installPhase = ''
      mkdir -p $out/build/
      cp -r $src/. $out/
      cd $out/build
      cmake ${toString cmakeFlags} ..
      ninja
      ninja gen_docs
      ninja install
    '';

    meta = {
      homepage = "https://openquantumsafe.org/";
      description = "C library for prototyping and experimenting with quantum-resistant cryptography";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  
};
in liboqs
