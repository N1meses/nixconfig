{...}: {
  flake.modules.homeManager.nh = {...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "all --keep-since 7d --keep 5";
      };
      flake = "/home/nimeses/nixconfig";
    };
  };
}
