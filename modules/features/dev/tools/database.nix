_: {
  aspects.database.home = {pkgs, ...}: {
    packages = with pkgs; [
      sqlite
      postgresql
    ];
  };
}
