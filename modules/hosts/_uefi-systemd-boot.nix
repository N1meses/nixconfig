{ lib, ... }:
{
  boot.loader = {
    grub.enable = lib.mkDefault false;
    systemd-boot = {
      enable = lib.mkDefault true;
      editor = lib.mkDefault false;
      configurationLimit = lib.mkDefault 10;
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
