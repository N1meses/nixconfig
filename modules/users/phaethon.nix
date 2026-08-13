{ config, lib, ... }:
{
  registry.users.phaethon = {
    uid = 1000;
    hashedPassword = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    extraGroups = [ "docker" ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      dev.tools.network
      dev.languages.nix
      desktop.apps.fastfetch
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
