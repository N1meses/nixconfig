_: {
  flake.modules.homeManager.userServices = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.services.user;
  in {
    options.features.services.user.storage.udiskie = {
      notify = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      automount = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };

    config.services = {
      gnome-keyring.enable = true;

      udiskie = {
        enable = true;
        notify = cfg.storage.udiskie.notify;
        automount = cfg.storage.udiskie.automount;
        tray = "never";
      };

      wl-clip-persist.enable = true;
    };
  };
}
