{ config, ... }: {
  aspects.forgejoRunner.description = "Forgejo Actions runner registered against atlas.";
  aspects.forgejoRunner.nixos =
    { config, pkgs, ... }:
    {
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances.atlas = {
          enable = true;
          name = "atlas-nix";
          url = "http://localhost:3000";
          tokenFile = config.sops.secrets."forgejo-runner-token".path;

          labels = [ "nix:host" ];

          hostPackages = with pkgs; [
            nix
            git
            bash
            coreutils
            gnutar
            gzip
            gnused
            gnugrep
            jq
            openssh
            curl
            nodejs
          ];
        };
      };

      sops.secrets."forgejo-runner-token" = { };
    };
  aspects.forgejoRunner.includes = with config.aspectLib.names; [ sops ];
}
