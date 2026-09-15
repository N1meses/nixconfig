_: {
  aspects.dev.tools.database = {
    description = "Database client tooling.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        sqlite
        postgresql
      ];
    };
  };
}
