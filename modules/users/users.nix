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
              }
              // lib.optionalAttrs (u.uid != null) { uid = u.uid; }
              // lib.optionalAttrs (u.hashedPassword != null) { hashedPassword = u.hashedPassword; }
              // lib.optionalAttrs (u.hashedPasswordFile != null) { hashedPasswordFile = u.hashedPasswordFile; };
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
              }
              // lib.optionalAttrs (u.uid != null) { uid = u.uid; }
              // lib.optionalAttrs (u.hashedPassword != null) { password = u.hashedPassword; }
              // lib.optionalAttrs (u.hashedPasswordFile != null) { passwordFile = u.hashedPasswordFile; };
          in
          lib.mkIf (host != null) (lib.genAttrs host.users mkUser);
      };
  };
}
