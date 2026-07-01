{config, ...}: {
  flake.aspectInclude.server = with config.flake.lib.aspects; [
    base
    sshd
    git
    network
    nh
    yazi
  ];
}
