{ config, lib, ... }:
{
  registry.users.icarus = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      cliEnv
      niri
      desktop
      nix
      ssh
      foot
      zed
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
