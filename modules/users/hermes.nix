{ config, lib, ... }:
{
  registry.users.hermes = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      cliEnv
      services
      niri
      noctalia
      foot
      yazi
      browser
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
