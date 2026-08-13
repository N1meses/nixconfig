_: {
  aspects.zig.description = "Zig toolchain and zls wiring.";
  aspects.zig.home = { pkgs, ... }: {
    packages = with pkgs; [
      zls
      zig
    ];
    rum.programs.helix.languages = {
      language-server.zls.command = "${pkgs.zls}/bin/zls";
      language = [
        {
          name = "zig";
          auto-format = true;
          language-servers = [ "zls" ];
        }
      ];
    };
  };
}
