_: {
  aspects.rust.home = { pkgs, ... }: {
    packages = with pkgs; [
      rust-analyzer
      rustfmt
      clippy
      rustc
      cargo
    ];
    rum.programs.helix.languages = {
      language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      language = [
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }
      ];
    };
  };
}
