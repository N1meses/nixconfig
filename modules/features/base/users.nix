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
          in
          lib.mkIf (host != null) {
            ${host.username} = {
              isNormalUser = true;
              shell = pkgs.zsh;
              extraGroups = ifTheyExist (
                [
                  "wheel"
                  "networkmanager"
                ]
                ++ host.extraGroups
              );
              openssh.authorizedKeys.keys = map builtins.readFile (
                lib.filesystem.listFilesRecursive ./super/keys
              );
            };
          };
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
          in
          lib.mkIf (host != null) {
            ${host.username} = {
              isNormalUser = true;
              shell = pkgs.zsh;
              extraGroups = ifTheyExist (
                [
                  "wheel"
                  "networkmanager"
                ]
                ++ host.extraGroups
              );
            };
          };
      };
  };
}
