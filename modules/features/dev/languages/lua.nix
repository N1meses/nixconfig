{...}: {
  flake.modules.homeManager.lua = {pkgs, ...}: {
    home.packages = with pkgs; [lua-language-server stylua lua];
    programs.helix.languages = {
      language-server.lua-language-server.command = "${pkgs.lua-language-server}/bin/lua-language-server";
      language = [
        {
          name = "lua";
          auto-format = true;
          language-servers = ["lua-language-server"];
        }
      ];
    };
  };
}
