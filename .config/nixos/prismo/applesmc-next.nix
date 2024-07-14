{ stdenv, lib, fetchFromGitHub, kernel, kmod, pkgs ? import <nixpkgs> }:
let
  kernelPrefix = "lib/modules/${kernel.modDirVersion}";
in
stdenv.mkDerivation rec {
  version = "0.1.5";
  name = "applesmc-${version}-${kernel.version}";

  src =
    fetchFromGitHub {
      owner = "c---";
      repo = "applesmc-next";
      rev = "${version}";
      sha256 = "sha256-Kh34suuoCLSBZH64EzqgIMJHjRVowmL94MEhHgx4GNg=";
    };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KVER=${kernel.modDirVersion}"
    "KBUILD_DIR=${kernel.dev}/${kernelPrefix}/build"
  ];

  preInstall =
    # https://docs.kernel.org/staging/xz.html#notes-on-compression-options
    ''
      xz --check=crc32 --lzma2=dict=512KiB applesmc/applesmc.ko
      xz --check=crc32 --lzma2=dict=512KiB sbs/sbs.ko
    '';

  installPhase =
    ''
      runHook preInstall

      install -D applesmc/applesmc.ko.xz -m 444 -t $out/${kernelPrefix}/kernel/drivers/hwmon
      install -D sbs/sbs.ko.xz           -m 444 -t $out/${kernelPrefix}/kernel/drivers/acpi

      runHook postInstall
    '';

  meta = with lib; {
    description = "Patches to Linux kernel to allow setting battery charge thresholds on Apple devices.";
    homepage = "https://github.com/c---/applesmc-next";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
