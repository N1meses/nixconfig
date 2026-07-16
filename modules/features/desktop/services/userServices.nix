_: {
  aspects.userServices.home = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.features.services.user;
    udiskieArgs = lib.concatStringsSep " " [
      (
        if cfg.storage.udiskie.automount
        then "-a"
        else "-A"
      )
      (
        if cfg.storage.udiskie.notify
        then "-n"
        else "-N"
      )
      "-T"
    ];
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

    config = {
      packages = with pkgs; [gnome-keyring udiskie wl-clip-persist];

      features.compositors.autoStart = [
        "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets,pkcs11"
        "${pkgs.udiskie}/bin/udiskie ${udiskieArgs}"
        "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular"
      ];
    };
  };
}
