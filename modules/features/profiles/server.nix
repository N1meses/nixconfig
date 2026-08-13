{ config, ... }: {

  aspects.bundle.server = {
    home = {
      features.apps.yazi.terminalFilechooser = false;
    };

    includes = with config.aspectLib.names; [
      bundle.base
      bundle.cliEnv
      server.serverCore
      server.sshd
      dev.tools.network
      desktop.apps.nh
    ];
    description = "Headless server role: base plus CLI environment, hardened sshd, networking tools and nh.";
  };

}
