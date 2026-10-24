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
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/core/super/keys);
    includes = with config.aspectLib.aspectNames; [
      bundle.cliEnv
      bundle.desktop
      desktop.compositors.umbriel
      server.sync.client
      dev.editors.emacs
      desktop.apps.term.kitty
      desktop.apps.browser.glide
      dev.tools.direnv
      shell.nushell
    ];
    home = { pkgs, ... }: {
      packages = with pkgs; [
        antigravity-cli
        claude-code
        python3
        mpv
        nh
        steam
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
