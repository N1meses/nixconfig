_: {
  flake.modules.nixos.music = _: {
    services.mpd = {
      enable = true;
    };
  };
}
