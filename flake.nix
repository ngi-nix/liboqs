{
  description = "C library for prototyping and experimenting with quantum-resistant cryptography";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.liboqs = {
    url = "github:open-quantum-safe/liboqs";
    flake = false;
  };

  outputs = { self, nixpkgs, liboqs, ... }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
    let
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
    in
      stdenv.mkDerivation {
        name = "liboqs";
        src = liboqs;
        homepage = "https://openquantumsafe.org/";
        buildInputs = [ cmake ninja gcc openssl doxygen python39Packages.pytest-xdist python39Packages.pytest ];
        dontFixCmake = true;

        installPhase = ''
          mkdir -p $out/build
          cp -r $src/. $out/
          cd $out/build
          cmake ${toString cmakeFlags} ..
          ninja
          ninja gen_docs 
          ninja install
        '';
      };
    };
}
