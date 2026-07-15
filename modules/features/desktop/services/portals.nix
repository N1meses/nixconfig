_: {
  aspects.portals.nixos = {lib, ...}: {
    services.dbus.enable = lib.mkDefault true;
    services.udisks2.enable = lib.mkDefault true;
  };
}
