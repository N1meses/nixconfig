{...}: {
  flake.modules.homeManager.nh = {config, ...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "all --keep-since 7d --keep 5";
      };
      flake = "${config.home.homeDirectory}/nixconfig";
    };
  };
}
