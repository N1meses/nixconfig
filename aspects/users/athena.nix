{ config, lib, ... }:
{
  users.athena = {
    description = "Admin account on athena.";
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      dev.tools.network
      desktop.apps.fastfetch
    ];
    home = { pkgs, ... }: {
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
