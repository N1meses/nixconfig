{ config, lib, ... }:
{
  users.hermes = {
    description = "acc for hermes";
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      shell.zsh
      bundle.services
      server.files.sync.client
      dev.editors.emacs
      desktop.compositors.niri
      desktop.noctalia
      desktop.apps.term.foot
      desktop.apps.yaziFilechooser
      desktop.apps.browser.glide
    ];
    home = { pkgs, ... }: {
      packages = with pkgs; [
        btop
        claude-code
        sops
      ];
    };
  };
}
