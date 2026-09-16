{
  config,
  lib,
  inputs,
  ...
}:
{
  users.nimeses = {
    description = "user for daily";
    uid = 1000;
    hashedPasswordFile = "/var/lib/nimeses/user.passwd";
    extraGroups = [
      "kvm"
      "video"
      "input"
      "audio"
      "yubikey"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      bundle.desktop
      desktop.compositors.umbriel
      dev.languages.nix
      dev.editors.zed
      desktop.apps.term.kitty
      desktop.apps.browser.glide
      dev.languages.python
      dev.languages.rust
      dev.languages.markdown
      dev.tools.direnv
    ];
    home = { pkgs, ... }: {
      packages = with pkgs; [
        antigravity-cli
        claude-code
        vesktop
        element-desktop
        mpv
        nh
        steam
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
        ffmpeg
      ];
    };
  };
}
