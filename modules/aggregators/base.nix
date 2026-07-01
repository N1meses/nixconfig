{config, ...}: {
  flake.aspectInclude.base = with config.flake.lib.aspects; [
    core
    shell
    local
    users
    tailscale
    helix
  ];
}
