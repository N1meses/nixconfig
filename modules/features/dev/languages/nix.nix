_: {
  flake.modules.homeManager.nix = {pkgs, ...}: {
    home.packages = with pkgs; [nixd alejandra];
    programs.helix.languages = {
      language-server.nixd.command = "${pkgs.nixd}/bin/nixd";
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = ["nixd"];
          formatter.command = "${pkgs.nixfmt}/bin/nxifmt";
        }
      ];
    };
  };
}
