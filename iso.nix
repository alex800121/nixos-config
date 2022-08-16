{ pkgs, ... }: 
{
  boot.kernelPackages = let
    linux_sgx_pkg = { fetchurl, buildLinux, ... } @ args:

      buildLinux (args // rec {
        version = "6.0-rc1";
        modDirVersion = version;

        src = fetchurl {
          url = "https://git.kernel.org/torvalds/t/linux-6.0-rc1.tar.gz";
          sha256 = "451787a0461abe26fce8af5740ac20b81610bf241ba1197be77ee9ebd3fc71ad";
        };
        kernelPatches = [];

        # extraConfig = ''
        #   INTEL_SGX y
        # '';

        extraMeta.branch = "6.0";
      } // (args.argsOverride or {}));
    linux_sgx = pkgs.callPackage linux_sgx_pkg{};
  in 
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_sgx);
  # boot.kernelPackages = pkgs.linuxPackages_5_18;
  # boot.kernelPatches = [
  #   {
  #     name = "keyboard";
  #     patch = ./keyboard.patch;
  #   }
  # ];
  imports = [ ./nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix ./nixpkgs/nixos/modules/installer/cd-dvd/channel.nix ];
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true; 
}
