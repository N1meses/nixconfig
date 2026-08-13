_: {
  aspects.c.description = "C/C++ toolchain and clangd wiring.";
  aspects.c.home = { pkgs, ... }: {
    packages = with pkgs; [
      clang-tools
      ccls
      gcc
    ];
    rum.programs.helix.languages = {
      language-server.clangd.command = "${pkgs.clang-tools}/bin/clangd";
      language = [
        {
          name = "c";
          auto-format = true;
          language-servers = [ "clangd" ];
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = [ "clangd" ];
        }
      ];
    };
  };
}
