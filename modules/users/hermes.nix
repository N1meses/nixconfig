{ config, lib, ... }:
{
  registry.users.hermes = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      bundle.services
      desktop.compositors.niri
      desktop.noctalia
      desktop.apps.term.foot
      desktop.apps.yaziFilechooser
      desktop.apps.browser
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        btop
        claude-code
        sops
      ];
    };
  };
}
