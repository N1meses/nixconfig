{ config, lib, ... }:
{
  registry.users.icarus = {
    uid = 1000;
    hashedPassword = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    extraGroups = [
      "seat"
      "video"
      "input"
      "audio"
      "yubikey"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      desktop.compositors.niri
      bundle.desktop
      dev.languages.nix
      shell.ssh
      desktop.apps.term.foot
      dev.editors.zed
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        btop
        yubikey-manager
        claude-code
      ];
    };
  };
}
