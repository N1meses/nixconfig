{ config, ... }: {
  aspects.base.includes = with config.aspectLib.names; [
    core
    shell
    local
    users
    tailscale
    helix
  ];
}
