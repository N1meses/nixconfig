_: {
  aspects.nh.description = "nh, the nix helper CLI for rebuilds and garbage collection.";
  aspects.nh.nixos = _: {
    programs.nh = {
      enable = true;
    };
  };
}
