_: {
  flake.modules.homeManager.cli = {pkgs, ...}: {
    home.packages = with pkgs; [jq yq sd just hyperfine tokei watchexec btop gh];
  };
}
