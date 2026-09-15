{ config, ... }: {
  aspects.bundle.base = {
    description = "Baseline every host gets: nix settings, locale, user accounts and tailscale.";
    includes = with config.aspectLib.aspectNames; [
      core.core
      core.local
      core.users
      server.vpn.tailscale
    ];
  };
}
