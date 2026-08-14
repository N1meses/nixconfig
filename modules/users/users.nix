{ config, lib, ... }:
let
  flakeConfig = config;

  mkUsers =
    {
      passwordAttr,
      passwordFileAttr,
      authorizedKeys,
    }:
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
                ++ hostEntry.extraGroups
                ++ u.extraGroups
              );
            }
            // lib.optionalAttrs authorizedKeys { openssh.authorizedKeys.keys = u.keys; }
            // lib.optionalAttrs (u.uid != null) { uid = u.uid; }
            // lib.optionalAttrs (u.hashedPassword != null) { ${passwordAttr} = u.hashedPassword; }
            // lib.optionalAttrs (u.hashedPasswordFile != null) {
              ${passwordFileAttr} = u.hashedPasswordFile;
            };
        in
        lib.genAttrs hostEntry.users mkUser;
    };
in
{
  aspects.core.users = {
    nixos = {
      imports = [
        (mkUsers {
          passwordAttr = "hashedPassword";
          passwordFileAttr = "hashedPasswordFile";
          authorizedKeys = true;
        })
      ];
      users.mutableUsers = lib.mkDefault true;
    };

    finix = mkUsers {
      passwordAttr = "password";
      passwordFileAttr = "passwordFile";
      authorizedKeys = false;
    };

    description = "Materialises registry.users into real accounts on whichever layer the host builds in.";
  };
}
