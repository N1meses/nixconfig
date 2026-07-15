_: {
  aspects.ssh.home = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkDefault mkOption concatStrings mapAttrsToList concatMapStrings isList isBool isAttrs;
    # ssh_config directives are case-insensitive, so the camelCase keys work as-is
    toLine = k: v:
      if isAttrs v
      then concatStrings (mapAttrsToList (ek: ev: "  ${k} ${ek}=${toString ev}\n") v) # SetEnv
      else if isList v
      then concatMapStrings (x: "  ${k} ${toString x}\n") v
      else if isBool v
      then "  ${k} ${
        if v
        then "yes"
        else "no"
      }\n"
      else "  ${k} ${toString v}\n";
    toBlock = host: opts: "Host ${host}\n" + concatStrings (mapAttrsToList toLine opts);
  in {
    options.ssh.matchBlocks = mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = {};
      description = "ssh Host blocks; contributed to by hosts, emitted to ~/.ssh/config.";
    };

    config = {
      ssh.matchBlocks = {
        "*" = {
          SetEnv.TERM = "xterm-256color";
          compression = true;
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          identityAgent = "none";
          identityFile = mkDefault [
            "~/.ssh/id_ed25519_sk_rk_bio"
            "~/.ssh/id_ed25519_sk_rk_nfc"
          ];
          controlMaster = "auto";
          controlPath = "~/.ssh/cm-%r@%h:%p";
          controlPersist = "10m";
        };
        hephaistos = {
          hostname = mkDefault "100.127.108.44";
          user = mkDefault "hephaistos";
        };
        prometheus = {
          hostname = mkDefault "100.93.27.90";
          user = mkDefault "prometheus";
        };
        forgejo = {
          hostname = mkDefault "100.75.163.80";
          user = mkDefault "forgejo";
          port = mkDefault 2222;
        };
        athena = {
          hostname = mkDefault "100.75.163.80";
          user = mkDefault "athena";
        };
        "atlas-unlock" = {
          hostname = "192.168.68.10";
          port = 2222;
          user = "root";
          proxyJump = mkDefault "hephaistos";
        };
        atlas = {
          hostname = mkDefault "100.68.232.99";
          user = mkDefault "atlas";
        };
      };

      files.".ssh/config".text =
        concatStrings (mapAttrsToList toBlock config.ssh.matchBlocks);
    };
  };
}
