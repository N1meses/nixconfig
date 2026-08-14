{ config, ... }: {
  aspects.bundle.base = {
    description = "Baseline every host gets: nix settings, locale, user accounts and tailscale.";
    includes = with config.aspectLib.names; [
      core.core
      core.local
      core.users
      server.vpn.tailscale
    ];
  };
}
