_: {
  aspects.dev.tools.cli = {
    description = "General CLI utilities.";
    home = { pkgs, ... }: {
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
  };
}
