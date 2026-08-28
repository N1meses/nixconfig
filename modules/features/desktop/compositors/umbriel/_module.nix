{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.umbriel;

  udevApi =
    if config.services.gardendevd.enable then
      pkgs.libudev-garden
    else if config.services.mdevd.enable || config.services.keventd.enable then
      pkgs.libudev-zero
    else
      null;

  libinput = pkgs.libinput.override (
    lib.optionalAttrs (udevApi != null) {
      udev = udevApi;
      wacomSupport = false;
    }
  );

  packageOverride = lib.optionalAttrs (udevApi != null) {
    inherit libinput;

    wlroots_0_20 = pkgs.wlroots_0_20.override {
      inherit libinput;

      enableXWayland = !config.services.mdevd.enable;
    };
  };

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/umbriel.desktop" ''
    [Desktop Entry]
    Comment=A Wayland compositor built on wlroots and SceneFX
    DesktopNames=umbriel
    Exec=${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe cfg.package}
    Name=Umbriel
    Type=Application
  '';
in
{
  options.programs.umbriel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable [umbriel](${pkgs.umbriel.meta.homepage}).
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.umbriel.override packageOverride;
      defaultText = lib.literalExpression "pkgs.umbriel";
      description = ''
        The package to use for `umbriel`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package

      (lib.hiPrio sessionFile)
    ];
  };
}
