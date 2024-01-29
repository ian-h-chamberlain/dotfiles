{ stdenv, lib, fetchFromGitHub, kernel, kmod }:
let 
  src = 
    fetchFromGitHub {
      owner = "c---";
      repo = "applesmc-next";
      rev = "${version}";
      sha256 = "sha256-Kh34suuoCLSBZH64EzqgIMJHjRVowmL94MEhHgx4GNg=";
    };

  version = "0.1.5";

  hardeningDisable = [ "pic" ];                      
  nativeBuildInputs = kernel.moduleBuildDependencies;        

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KBUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with lib; {
    description = "Patches to Linux kernel to allow setting battery charge thresholds on Apple devices.";
    homepage = "https://github.com/c---/applesmc-next";
    license = licenses.gpl2;
    maintainers = [];
    platforms = platforms.linux;
  };
 in 
{ 
  applesmc = 
    stdenv.mkDerivation rec {
      inherit src version hardeningDisable nativeBuildInputs makeFlags meta;

      name = "applesmc-${version}-${kernel.version}";
      installPhase = "mv applesmc/applesmc.ko $out";
    };

  sbs = 
    stdenv.mkDerivation rec {
      inherit src version hardeningDisable nativeBuildInputs makeFlags meta;

      name = "sbs-${version}-${kernel.version}";
      installPhase = "mv sbs/sbs.ko $out";
    };
}
