{ config, lib, ... }:
{
  users.phaethon = {
    description = "Admin account on phaethon.";
    uid = 1000;
    hashedPassword = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    extraGroups = [ "docker" ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      dev.tools.network
      dev.languages.nix
      desktop.apps.fastfetch
    ];
    home = { pkgs, ... }: {
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
