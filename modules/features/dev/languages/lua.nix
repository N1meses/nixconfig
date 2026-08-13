_: {
  aspects.lua.description = "Lua toolchain and lua-language-server wiring.";
  aspects.lua.home = { pkgs, ... }: {
    packages = with pkgs; [
      lua-language-server
      stylua
      lua
    ];
    rum.programs.helix.languages = {
      language-server.lua-language-server.command = "${pkgs.lua-language-server}/bin/lua-language-server";
      language = [
        {
          name = "lua";
          auto-format = true;
          language-servers = [ "lua-language-server" ];
        }
      ];
    };
  };
}
