{ config, lib, ... }:
{
  registry.users.athena = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      dev.tools.network
      desktop.apps.fastfetch
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
        ani-cli
      ];
    };
  };
}
