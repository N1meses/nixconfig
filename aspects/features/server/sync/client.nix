{ config, ... }:
let
  shared = import ./_shared.nix;
in
{
  aspects.server.sync.client = {
    description = "Continuous two-way Unison sync of the working set with the atlas hub.";
    includes = with config.aspectLib.aspectNames; [
      desktop.compositors.compositors
      shell.ssh
    ];
    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (shared) hubPath profile;

        logDir = "${config.xdg.state.directory}/unison";

        wrapper = pkgs.writeShellApplication {
          name = "unison-sync";
          runtimeInputs = with pkgs; [
            unison
            openssh
            util-linux
            coreutils
          ];
          text = ''
            dir="''${UNISON:-$HOME/.unison}"
            root="''${UNISON_SYNC_ROOT:-${config.directory}}"
            exec 9>"$dir/unison-sync.lock"
            flock -n 9 || exit 0

            shopt -s nullglob
            archives=("$dir"/ar*)
            if (( ''${#archives[@]} == 0 )); then
              msg="unison-sync: no archive yet; run once by hand: unison ${profile} -batch=false"
              echo "$msg" >&2
              echo "$msg" >>"${logDir}/${profile}.log" || true
              exit 1
            fi

            delay=10
            while true; do
              start=$(date +%s)
              {
                unison ${profile} &&
                  {
                    watch=()
                    for p in ${lib.escapeShellArgs shared.paths}; do
                      if [[ -e "$root/$p" || -L "$root/$p" ]]; then watch+=(-path "$p"); fi
                    done
                    # an empty -path list would mean the whole root
                    (( ''${#watch[@]} )) && unison ${profile}-common -repeat watch "''${watch[@]}"
                  }
              } 9>&- || true
              (( $(date +%s) - start >= 60 )) && delay=10
              sleep "$delay" 9>&-
              delay=$(( delay * 2 > 300 ? 300 : delay * 2 ))
            done
          '';
        };
      in
      {
        packages = [
          pkgs.unison
          wrapper
        ];

        xdg.state.files."unison".type = "directory";

        files.".unison/${profile}-common.prf".text = lib.concatLines (
          [
            "root = ${config.directory}"
            "root = ssh://atlas-sync/${hubPath}"
          ]
          ++ map (i: "ignore = ${i}") shared.ignore
          ++ [
            "batch = true"
            "prefer = newer"
            "copyonconflict = true"
            "logfile = ${logDir}/${profile}.log"
          ]
        );

        files.".unison/${profile}.prf".text = lib.concatLines (
          [ "include ${profile}-common.prf" ] ++ map (p: "path = ${p}") shared.paths
        );

        features.compositors.autoStart = [ "unison-sync" ];
      };
  };
}
