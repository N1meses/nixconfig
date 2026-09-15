{ config, lib, ... }:
{
  users.hermes = {
    description = "Recovery account; carries a graphical session so the stick is usable by hand.";
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      bundle.services
      desktop.compositors.umbriel
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
