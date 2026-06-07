{
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
  flake.modules.nixos.users = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [flakeConfig.flake.modules.nixos.overlays];
    users.mutableUsers = false;
    users.users = let
      hostname = config.networking.hostName;
      host = flakeConfig.registry.hosts.${hostname} or null;
      ifTheyExist = gs:
        builtins.filter
        (g: builtins.hasAttr g config.users.groups)
        gs;
    in
      lib.mkIf (host != null) {
        ${host.username} = {
          isNormalUser = true;
          shell = pkgs.zsh;
          extraGroups = ifTheyExist (["wheel" "networkmanager"] ++ host.extraGroups);
          openssh.authorizedKeys.keys =
            map builtins.readFile (lib.filesystem.listFilesRecursive ./super/keys);
        };
      };
  };
}
