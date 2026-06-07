{...}: {
  flake.modules.homeManager.c = {pkgs, ...}: {
    home.packages = with pkgs; [clang-tools ccls gcc];
    programs.helix.languages = {
      language-server.clangd.command = "${pkgs.clang-tools}/bin/clangd";
      language = [
        {
          name = "c";
          auto-format = true;
          language-servers = ["clangd"];
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = ["clangd"];
        }
      ];
    };
  };
}
