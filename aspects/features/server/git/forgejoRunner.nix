{ config, ... }: {
  aspects.server.git.forgejoRunner = {
    description = "Forgejo Actions runner registered against atlas.";
    includes = with config.aspectLib.aspectNames; [ core.sops ];
    nixos =
      { config, pkgs, ... }:
      {
        services.forgejo-runner = {
          package = pkgs.forgejo-runner;
          instances.atlas = {
            enable = true;
            settings = {
              server.connections.default = {
                url = "http://localhost:3000";
                uuid = "9ef013b2-2a45-40e6-9c96-255f9bf005f8";
              };
              runner.labels = [ "nix:host" ];
            };
            secrets.server.connections.default.token_url = config.sops.secrets."forgejo-runner-token".path;

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
