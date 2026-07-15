_: {
  aspects.python.home = {pkgs, ...}: {
    home.packages = with pkgs; [pyright ruff python3 uv];
    programs.helix.languages = {
      language-server.pyright = {
        command = "${pkgs.pyright}/bin/pyright-langserver";
        args = ["--stdio"];
      };
      language = [
        {
          name = "python";
          auto-format = true;
          language-servers = ["pyright"];
        }
      ];
    };
  };
}
