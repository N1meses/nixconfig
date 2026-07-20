{ config, ... }:
let
  flakeConfig = config;
in
{
  aspects.users = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        users.mutableUsers = lib.mkDefault true;
        users.users =
          let
            hostname = config.networking.hostName;
            host = flakeConfig.registry.hosts.${hostname} or null;
            ifTheyExist = gs: builtins.filter (g: builtins.hasAttr g config.users.groups) gs;
            mkUser =
              uname:
              let
                u = flakeConfig.registry.users.${uname};
              in
              {
                isNormalUser = true;
                shell = pkgs.zsh;
                extraGroups = ifTheyExist (
                  [
                    "wheel"
                    "networkmanager"
                  ]
                  ++ host.extraGroups
                  ++ u.extraGroups
                );
                openssh.authorizedKeys.keys = u.keys;
              };
          in
          lib.mkIf (host != null) (lib.genAttrs host.users mkUser);
      };

    finix =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        users.users =
          let
            hostname = config.networking.hostName;
            host = flakeConfig.registry.hosts.${hostname} or null;
            ifTheyExist = gs: builtins.filter (g: builtins.hasAttr g config.users.groups) gs;
            mkUser =
              uname:
              let
                u = flakeConfig.registry.users.${uname};
              in
              {
                isNormalUser = true;
                shell = pkgs.zsh;
                extraGroups = ifTheyExist (
                  [
                    "wheel"
                    "networkmanager"
                  ]
                  ++ host.extraGroups
                  ++ u.extraGroups
                );
              };
          in
          lib.mkIf (host != null) (lib.genAttrs host.users mkUser);
      };
  };
}
