_: {
  aspects.dev.languages.java = {
    description = "Java toolchain and jdtls wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        jdk
        jdt-language-server
        gradle
      ];
      rum.programs.helix.languages = {
        language-server.jdtls.command = "${pkgs.jdt-language-server}/bin/jdtls";
        language = [
          {
            name = "java";
            auto-format = true;
            language-servers = [ "jdtls" ];
          }
        ];
      };
    };
  };
}
