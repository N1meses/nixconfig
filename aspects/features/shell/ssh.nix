_: {
  aspects.shell.ssh = {
    description = "ssh client config and per-host match blocks.";
    home =
      {
        config,
        lib,
        pkgs,
        userEntry,
        ...
      }:
      let
        inherit (lib)
          filterAttrs
          hasInfix
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
        render = blocks: concatStrings (mapAttrsToList toBlock blocks);
        isPattern = host: hasInfix "*" host || hasInfix "?" host;
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

          files.".ssh/config".text =
            let
              blocks = config.ssh.matchBlocks;
            in
            render (filterAttrs (h: _: !isPattern h) blocks)
            + render (filterAttrs (h: _: isPattern h && h != "*") blocks)
            + render (filterAttrs (h: _: h == "*") blocks);

          files.".ssh/authorized_keys" = lib.mkIf (userEntry.keys != [ ]) {
            type = "copy";
            permissions = "0444";
            text = lib.concatLines (map (lib.removeSuffix "\n") userEntry.keys);
          };
        };
      };
  };
}
