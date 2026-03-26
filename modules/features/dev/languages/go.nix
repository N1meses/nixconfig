{...}: {
  flake.modules.homeManager.go = {pkgs, ...}: {
    home.packages = with pkgs; [
      gopls
      gotools
      golangci-lint
      go
    ];
  };
}
