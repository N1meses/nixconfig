{config, ...}: {
  flake.aspectInclude.server = with config.flake.lib.aspects; [
    base
    serverCore
    sshd
    git
    network
    nh
    yazi
  ];
}
