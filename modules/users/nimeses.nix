{
  config,
  lib,
  inputs,
  ...
}:
{
  registry.users.nimeses = {
    extraGroups = [
      "libvirtd"
      "kvm"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      cliEnv
      desktop
      niri
      nix
      zed
      kitty
      python
      c
      rust
      markdown
      direnv
      music
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        antigravity-cli
        claude-code
        vesktop
        element-desktop
        sops
        obsidian
        tor-browser
        mpv
        nicotine-plus
        rmpc
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
