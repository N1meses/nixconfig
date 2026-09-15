{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.halley;

  udevApi =
    if config.services.gardendevd.enable then
      pkgs.libudev-garden
    else if config.services.mdevd.enable || config.services.keventd.enable then
      pkgs.libudev-zero
    else
      null;

  packageOverride = lib.optionalAttrs (udevApi != null) {
    withSystemd = false;
    eudev = udevApi;
    libinput = pkgs.libinput.override {
      udev = udevApi;
      wacomSupport = false;
    };
  };

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/halley.desktop" ''
    [Desktop Entry]
    Comment=Spatial Wayland compositor built around infinite workspace navigation
    DesktopNames=halley
    Exec=${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe cfg.package} --session
    Name=Halley
    Type=Application
  '';
in
{
  options.programs.halley = {
    enable = lib.mkEnableOption "the Halley spatial Wayland compositor";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.halley.override packageOverride;
      defaultText = lib.literalExpression "pkgs.halley";
      description = "The Halley package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package

      (lib.hiPrio sessionFile)
    ];
  };
}
