{lib, ...}: {
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
        "hephaistos" = {
          hostname = lib.mkDefault "100.127.108.44";
          user = lib.mkDefault "hephaistos";
        };
        "prometheus" = {
          hostname = lib.mkDefault "100.93.27.90";
          user = lib.mkDefault "prometheus";
        };
        "forgejo" = {
          hostname = lib.mkDefault "100.75.163.80";
          user = lib.mkDefault "forgejo";
          port = lib.mkDefault 2222;
        };
        "athena" = {
          hostname = lib.mkDefault "100.75.163.80";
          user = lib.mkDefault "athena";
        };
      };
    };
  };
}
