{ config, ... }: {
  aspects.base.description = "Baseline every host gets: nix settings, locale, user accounts, tailscale and privilege escalation.";
  aspects.base.includes = with config.aspectLib.names; [
    core
    local
    users
    tailscale
    doas
  ];
}
