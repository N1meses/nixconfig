_: {
  aspects.dev.languages.python = {
    description = "Python toolchain and pyright wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        pyright
        ruff
        python3
        uv
      ];
      rum.programs.helix.languages = {
        language-server.pyright = {
          command = "${pkgs.pyright}/bin/pyright-langserver";
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "python";
            auto-format = true;
            language-servers = [ "pyright" ];
          }
        ];
      };
    };
  };
}
