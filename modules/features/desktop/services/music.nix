_: {
  aspects.desktop.services.music = {
    description = "MPD music daemon.";
    nixos = _: {
      services.mpd = {
        enable = true;
      };
    };
  };
}
