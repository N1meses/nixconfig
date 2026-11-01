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
                uuid = "1cd845f2-b171-4a05-9453-5b05ee2b797f";
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
