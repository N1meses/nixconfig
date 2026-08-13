_: {
  aspects.desktop.apps.nh = {
    description = "nh, the nix helper CLI for rebuilds and garbage collection.";
    nixos = _: {
      programs.nh = {
        enable = true;
      };
    };
  };
}
