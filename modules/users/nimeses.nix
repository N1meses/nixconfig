{
  config,
  lib,
  inputs,
  ...
}:
{
  registry.users.nimeses = {
    uid = 1000;
    hashedPasswordFile = "/var/lib/nimeses/user.passwd";
    extraGroups = [
      "incus-admin"
      "kvm"
      "video"
      "input"
      "audio"
      "yubikey"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      bundle.desktop
      desktop.compositors.niri
      desktop.compositors.halley
      desktop.services.music
      dev.languages.nix
      dev.editors.zed
      desktop.apps.term.kitty
      dev.languages.python
      dev.languages.c
      dev.languages.rust
      dev.languages.markdown
      dev.tools.direnv
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
        nh
        steam
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
        ffmpeg
        ytmdesktop
      ];
    };
  };
}
