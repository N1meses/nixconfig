{...}: {
  flake.modules.homeManager.zig = {pkgs, ...}: {
    home.packages = with pkgs; [zls zig];
    programs.helix.languages = {
      language-server.zls.command = "${pkgs.zls}/bin/zls";
      language = [
        {
          name = "zig";
          auto-format = true;
          language-servers = ["zls"];
        }
      ];
    };
  };
}
