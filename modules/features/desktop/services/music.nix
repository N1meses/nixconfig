{...}: {
  flake.modules.nixos.music = {...}: {
    services.mpd = {
      enable = true;
    };
  };
}
