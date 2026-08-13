_: {
  aspects.cli.description = "General CLI utilities.";
  aspects.cli.home = { pkgs, ... }: {
    packages = with pkgs; [
      jq
      yq
      sd
      just
      hyperfine
      tokei
      watchexec
      btop
      gh
    ];
  };
}
