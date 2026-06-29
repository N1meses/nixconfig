_: {
  flake.modules.homeManager.java = {pkgs, ...}: {
    home.packages = with pkgs; [jdk jdt-language-server gradle];
    programs.helix.languages = {
      language-server.jdtls.command = "${pkgs.jdt-language-server}/bin/jdtls";
      language = [
        {
          name = "java";
          auto-format = true;
          language-servers = ["jdtls"];
        }
      ];
    };
  };
}
