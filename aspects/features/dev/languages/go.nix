_: {
  aspects.dev.languages.go = {
    description = "Go toolchain and gopls wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        gopls
        gotools
        golangci-lint
        go
      ];
      rum.programs.helix.languages = {
        language-server.gopls.command = "${pkgs.gopls}/bin/gopls";
        language = [
          {
            name = "go";
            auto-format = true;
            language-servers = [ "gopls" ];
          }
        ];
      };
    };
  };
}
