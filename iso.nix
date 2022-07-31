{ pkgs, ... }: 
{
  boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.kernelPatches = [
    {
      name = "keyboard";
      patch = ./keyboard.patch;
    }
  ];
  imports = [ ./nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix ./nixpkgs/nixos/modules/installer/cd-dvd/channel.nix ];
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true; 
}
