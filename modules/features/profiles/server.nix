{ config, ... }: {

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
