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
      cliEnv
      desktop
      niri
      hyprland
      nix
      zed
      kitty
      c
      python
      rust
      markdown
      build
      direnv
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
