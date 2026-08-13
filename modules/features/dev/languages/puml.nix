_: {
  aspects.puml.description = "PlantUML tooling.";
  aspects.puml.home = { pkgs, ... }: {
    packages = with pkgs; [ plantuml ];
  };
}
