{ config, ... }: {

  aspects.server.description = "Headless server role: base plus CLI environment, hardened sshd, networking tools and nh.";

  aspects.server = {
    home = {
      features.apps.yazi.terminalFilechooser = false;
    };

    includes = with config.aspectLib.names; [
      base
      cliEnv
      serverCore
      sshd
      network
      nh
    ];
  };
}
