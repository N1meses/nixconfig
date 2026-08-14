{ config, ... }: {
  aspects.server.forgejoRunner = {
    description = "Forgejo Actions runner registered against atlas.";
    includes = with config.aspectLib.names; [ core.sops ];
    nixos =
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
              gawk # scripts/drvdiff.sh; PATH here is exactly this list, nothing else
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
  };
}
