{lib, ...}: let
  t = lib.types;
in {
  options.registry.hosts = lib.mkOption {
    type = t.attrsOf (t.submodule ({config, ...}: {
      options = {
        username = lib.mkOption {
          type = t.str;
          description = "primary user for this host";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Additional groups for this user";
        };

        system = lib.mkOption {
          type = t.enum [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ];
          default = "x86_64-linux";
          description = "system architecture";
        };

        stateVersion = lib.mkOption {
          type = t.str;
          description = "NixOS/Home Manager state version";
        };

        homeDirectory = lib.mkOption {
          type = t.str;
          default = "/home/${config.username}";
          description = "path to home directory";
        };

        hostname = lib.mkOption {
          type = t.str;
          default = config.username;
          description = "Network hostname";
        };

        hostId = lib.mkOption {
          type = t.str;
          default = "";
          description = "8-digit hex host ID (required for ZFS)";
        };

        gitName = lib.mkOption {
          type = t.str;
          default = "N1meses";
          description = "Git commit author name";
        };

        gitEmail = lib.mkOption {
          type = t.str;
          default = "nilshasenthal@gmail.com";
          description = "Git commit author email";
        };
      };
    }));
    default = {};
    description = "Registry of all hosts in this configuration";
  };
}
