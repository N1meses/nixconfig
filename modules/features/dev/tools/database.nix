_: {
  aspects.database.description = "Database client tooling.";
  aspects.database.home = { pkgs, ... }: {
    packages = with pkgs; [
      sqlite
      postgresql
    ];
  };
}
