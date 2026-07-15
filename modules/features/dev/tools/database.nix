_: {
  aspects.database.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      sqlite
      postgresql
    ];
  };
}
