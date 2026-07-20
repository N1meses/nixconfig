{ config, lib, ... }:
{
  registry.users.atlas = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      cliEnv
      network
      fastfetch
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
        ani-cli
        btop
        zellij
        speedtest-cli
      ];
    };
  };
}
