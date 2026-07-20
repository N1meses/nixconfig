{ config, lib, ... }:
{
  registry.users.hephaistos = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      cliEnv
      network
      nix
      fastfetch
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
      ];
    };
  };
}
