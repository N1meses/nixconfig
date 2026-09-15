{ config, lib, ... }:
{
  users.icarus = {
    description = "Daily account on icarus and bellerophon.";
    uid = 1000;
    hashedPassword = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    extraGroups = [
      "seat"
      "video"
      "input"
      "audio"
      "yubikey"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      desktop.compositors.niri
      bundle.desktop
      dev.languages.nix
      shell.ssh
      desktop.apps.term.foot
      dev.editors.zed
    ];
    home = { pkgs, ... }: {
      packages = with pkgs; [
        btop
        yubikey-manager
        claude-code
      ];
    };
  };
}
