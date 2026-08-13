{ config, ... }: {
  aspects.binaryCache.description = "nix-serve binary cache, published on the tailnet.";
  aspects.binaryCache.nixos =
    { config, pkgs, ... }:
    {
      services.nix-serve = {
        enable = true;
        package = pkgs.nix-serve-ng;
        secretKeyFile = config.sops.secrets."atlas-cache-key".path;
        bindAddress = "0.0.0.0";
        port = 5000;
      };

      sops.secrets."atlas-cache-key" = { };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];
    };
  aspects.binaryCache.includes = with config.aspectLib.names; [ sops ];
}
