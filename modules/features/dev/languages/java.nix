{...}: {
  flake.modules.homeManager.java = {pkgs, ...}: {
    home.packages = with pkgs; [
      jdk
      jdt-language-server
      gradle
    ];
  };
}
