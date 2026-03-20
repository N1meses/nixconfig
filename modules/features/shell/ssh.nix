{...}: {
  flake.modules.homeManager.ssh = {...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          setEnv = {
            TERM = "xterm-256color";
          };
          compression = true;
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          identityAgent = "none";
          identityFile = [
            "~/.ssh/id_ed25519_sk_rk_bio"
            "~/.ssh/id_ed25519_sk_rk_nfc"
          ];
        };
      };
    };
  };
}
