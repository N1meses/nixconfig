{...}: {
  flake.modules.homeManager.bash = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
      shfmt
      bash
    ];
  };
}
