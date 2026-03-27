{config, lib, ...}: let
  cfg = config.features.services.user;
in {
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

  config.flake.modules.homeManager.userServices = {pkgs, lib, ...}: {
    services = {
      gnome-keyring.enable = lib.mkDefault cfg.gnomeKeyring.enable;

      gpg-agent = lib.mkIf cfg.security.gpg-agent.enable {
        enable = true;
        enableSshSupport = cfg.security.gpg-agent.enableSshSupport;
        pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;
      };

      ssh-agent.enable = cfg.security.ssh-agent.enable;

      udiskie = lib.mkIf cfg.storage.udiskie.enable {
        enable = true;
        notify = cfg.storage.udiskie.notify;
        automount = cfg.storage.udiskie.automount;
        tray = "never";
      };
    };
  };
}
