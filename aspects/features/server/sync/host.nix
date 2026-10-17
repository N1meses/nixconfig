{ config, ... }:
let
  shared = import ./_shared.nix;
in
{
  aspects.server.sync.host = {
    description = "Unison sync hub: a forced-command `sync` user owning the shared working set.";
    includes = with config.aspectLib.aspectNames; [ server.sshd ];
    nixos =
      { lib, pkgs, ... }:
      let
        inherit (shared) hubPath user;

        serverCmd = pkgs.writeShellScript "unison-sync-server" ''
          export PATH=${pkgs.unison}/bin:${pkgs.util-linux}/bin:$PATH
          mountpoint -q ${hubPath} || { echo "unison-sync: ${hubPath} is not mounted" >&2; exit 1; }
          exec unison -server
        '';

        keyFiles = lib.optionals (builtins.pathExists ./keys) (
          builtins.filter (f: lib.hasSuffix ".pub" (toString f)) (lib.filesystem.listFilesRecursive ./keys)
        );
        keys = lib.concatMap (
          f:
          builtins.filter (l: l != "" && !lib.hasPrefix "#" l) (
            map lib.trim (lib.splitString "\n" (builtins.readFile f))
          )
        ) keyFiles;
      in
      {
        users.users.${user} = {
          isSystemUser = true;
          group = user;
          home = hubPath;
          createHome = false;
          shell = pkgs.bashInteractive;
          openssh.authorizedKeys.keys = map (k: ''restrict,command="${serverCmd}" ${k}'') keys;
        };
        users.groups.${user} = { };

        environment.systemPackages = [ pkgs.unison ];

        features.server.allowedUsers = [ user ];

        services.openssh.extraConfig = lib.mkAfter ''
          Match User ${user}
            ClientAliveInterval 30
            ClientAliveCountMax 3
        '';

        systemd.tmpfiles.rules = [ "d ${hubPath} 0700 ${user} ${user} -" ];
      };
  };
}
