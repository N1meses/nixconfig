{...}: {
  flake.modules.nixos.portals = {
    pkgs,
    lib,
    ...
  }: {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    };
    services.dbus.enable = lib.mkDefault true;
    services.udisks2.enable = lib.mkDefault true;
  };
}
