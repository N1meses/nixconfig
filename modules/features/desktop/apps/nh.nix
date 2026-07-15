_: {
  aspects.nh.nixos = {config, ...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "all --keep-since 7d --keep 5";
      };
      flake = "${config.directory}/nixconfig";
    };
  };
}
