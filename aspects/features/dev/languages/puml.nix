_: {
  aspects.dev.languages.puml = {
    description = "PlantUML tooling.";
    home = { pkgs, ... }: {
      packages = with pkgs; [ plantuml ];
    };
  };
}
