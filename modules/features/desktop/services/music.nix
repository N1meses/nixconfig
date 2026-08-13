_: {
  aspects.music.description = "MPD music daemon.";
  aspects.music.nixos = _: {
    services.mpd = {
      enable = true;
    };
  };
}
