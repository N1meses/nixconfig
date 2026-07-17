{ config, ... }: {
  aspects.binaryCache.nixos =
    { config, pkgs, ... }:
    {
      # Serve atlas's /nix/store as a signed binary cache. nix-serve-ng signs
      # narinfo on the fly with secretKeyFile, so anything already built (e.g. by
      # the Forgejo CI runner) is served signed — no separate `nix copy` step.
      services.nix-serve = {
        enable = true;
        package = pkgs.nix-serve-ng;
        secretKeyFile = config.sops.secrets."atlas-cache-key".path;
        bindAddress = "0.0.0.0"; # reachable only via the tailnet, see firewall below
        port = 5000;
      };

      # LoadCredential reads this as root before dropping to the DynamicUser
      # `nix-serve` service, so no owner/group is needed (default root:0400).
      sops.secrets."atlas-cache-key" = { };

      # every host reaches atlas over the tailnet as MagicDNS `atlas`
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];
    };
  aspects.binaryCache.includes = with config.aspectLib.names; [ sops ];
}
