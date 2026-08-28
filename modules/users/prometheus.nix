{ config, lib, ... }:
{
  registry.users.prometheus = {
    extraGroups = [
      "gamemode"
      "libvirtd"
      "kvm"
    ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
      bundle.desktop
      desktop.compositors.niri
      desktop.compositors.umbriel
      dev.languages.nix
      dev.editors.zed
      desktop.apps.term.kitty
      desktop.apps.browser.glide
      dev.languages.c
      dev.languages.python
      dev.languages.rust
      dev.languages.markdown
      dev.tools.build
      dev.tools.direnv
    ];
    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        btop
        croc
        trash-cli
        grim
        nom
        nvd
        nix-tree
        adw-gtk3
        nwg-look
        gnome-themes-extra
        file-roller
        claude-code
        ckb-next
        element-desktop
        jellyfin-mpv-shim
        gparted
      ];
    };
  };
}
