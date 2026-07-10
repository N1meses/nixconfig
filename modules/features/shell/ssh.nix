{lib, ...}: {
  flake.modules.homeManager.ssh = _: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          SetEnv = {
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
          controlMaster = "auto";
          controlPath = "~/.ssh/cm-%r@%h:%p";
          controlPersist = "10m";
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
        "atlas-unlock" = {
          hostname = "192.168.68.10";
          port = 2222;
          user = "root";
          proxyJump = lib.mkDefault "hephaistos";
        };
        "atlas" = {
          hostname = lib.mkDefault "100.68.232.99";
          user = lib.mkDefault "atlas";
        };
      };
    };
  };
}
