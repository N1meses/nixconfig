{...}: {
  flake.modules.homeManager.userServices = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.features.services.user = {
      gnomeKeyring.enable = lib.mkEnableOption "GNOME Keyring";

      security = {
        gpg-agent = {
          enable = lib.mkEnableOption "GPG agent";
          enableSshSupport = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
        ssh-agent.enable = lib.mkEnableOption "SSH agent";
      };

      storage.udiskie = {
        enable = lib.mkEnableOption "udiskie automount";
        notify = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        automount = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };

    config = {
      services = {
        gnome-keyring.enable = lib.mkDefault config.features.services.user.gnomeKeyring.enable;

        gpg-agent = lib.mkIf config.features.services.user.security.gpg-agent.enable {
          enable = true;
          enableSshSupport = config.features.services.user.security.gpg-agent.enableSshSupport;
          pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;
        };

        ssh-agent.enable = config.features.services.user.security.ssh-agent.enable;

        udiskie = lib.mkIf config.features.services.user.storage.udiskie.enable {
          enable = true;
          notify = config.features.services.user.storage.udiskie.notify;
          automount = config.features.services.user.storage.udiskie.automount;
          tray = "never";
        };
      };
    };
  };
}
