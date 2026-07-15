_: {
  aspects.nix.home = {pkgs, ...}: {
    packages = with pkgs; [nixd alejandra];
    rum.programs.helix.languages = {
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
