{...}: {
  flake.modules.homeManager.database = {pkgs, ...}: {
    home.packages = with pkgs; [
      sqlite
      postgresql
    ];
  };
}
