{ config, ... }:
let
  flakeConfig = config;
in
{
  aspects.core.users = {
    nixos =
      {
        config,
        hostEntry,
        lib,
        pkgs,
        ...
      }:
      {
        users.mutableUsers = lib.mkDefault true;
        users.users =
          let
            host = hostEntry;
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
          lib.genAttrs host.users mkUser;
      };

    finix =
      {
        config,
        hostEntry,
        lib,
        pkgs,
        ...
      }:
      {
        users.users =
          let
            host = hostEntry;
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
          lib.genAttrs host.users mkUser;
      };
    description = "Materialises registry.users into real accounts on whichever layer the host builds in.";
  };
}
