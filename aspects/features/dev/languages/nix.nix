_: {
  aspects.dev.languages.nix = {
    description = "Nix toolchain, nixd language server and nixfmt formatting.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        nixd
        nixfmt
      ];
      rum.programs.helix.languages = {
        language-server.nixd.command = "${pkgs.nixd}/bin/nixd";
        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [ "nixd" ];
            formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          }
        ];
      };
    };
  };
}
