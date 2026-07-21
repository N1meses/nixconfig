{ config, ... }: {
  aspects.base.includes = with config.aspectLib.names; [
    core
    local
    users
    tailscale
    doas
  ];
}
