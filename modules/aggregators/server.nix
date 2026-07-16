{ config, ... }: {
  aspects.server.includes = with config.aspectLib.names; [
    base
    serverCore
    sshd
    git
    network
    nh
    yazi
  ];
}
