_: {
  aspects.ssh.home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkOption
        concatStrings
        mapAttrsToList
        concatMapStrings
        isList
        isBool
        isAttrs
        ;
      toLine =
        k: v:
        if isAttrs v then
          concatStrings (mapAttrsToList (ek: ev: "  ${k} ${ek}=${toString ev}\n") v) # SetEnv
        else if isList v then
          concatMapStrings (x: "  ${k} ${toString x}\n") v
        else if isBool v then
          "  ${k} ${if v then "yes" else "no"}\n"
        else
          "  ${k} ${toString v}\n";
      toBlock = host: opts: "Host ${host}\n" + concatStrings (mapAttrsToList toLine opts);
    in
    {
      options.ssh.matchBlocks = mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        default = { };
        description = "ssh Host blocks; contributed to by hosts, emitted to ~/.ssh/config.";
      };

      config = {
        packages = [
          pkgs.openssh
        ];

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
        };

        files.".ssh/config".text = concatStrings (mapAttrsToList toBlock config.ssh.matchBlocks);
      };
    };
}
