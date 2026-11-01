{ config, ... }:
let
  shared = import ./_shared.nix;
in
{
  aspects.server.files.sync.client = {
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

        # The unison ignores as find(1) prune tests, so repo discovery skips what is never synced.
        findPrune = lib.concatMapStringsSep " -o " (
          i:
          if lib.hasPrefix "Name " i then
            "-name ${lib.escapeShellArg (lib.removePrefix "Name " i)}"
          else
            ''-path "$root"/${lib.escapeShellArg (lib.removePrefix "Path " i)}''
        ) shared.ignore;

        wrapper = pkgs.writeShellApplication {
          name = "unison-sync";
          runtimeInputs = with pkgs; [
            unison
            openssh
            util-linux
            coreutils
            findutils
            gnused
            git
          ];
          text = ''
            dir="''${UNISON:-$HOME/.unison}"
            root="''${UNISON_SYNC_ROOT:-${config.directory}}"
            exec 9>"$dir/unison-sync.lock"
            flock -n 9 || exit 0

            # Turn every repo's git-ignored paths into unison ignores (sourced by ${profile}-common.prf).
            # Always writes the file: a missing `source` target is a fatal unison error.
            gen_gitignore() {
              local out="$dir/gitignore.prf" tmp p repo rel f
              tmp=$(mktemp "$out.XXXXXX")
              for p in ${lib.escapeShellArgs shared.paths}; do
                [[ -d "$root/$p" ]] || continue
                while IFS= read -r -d "" repo; do
                  repo=''${repo%/.git}
                  rel=$(printf '%s\n' "''${repo#"$root"/}" | sed 's/[][*?{}\\]/\\&/g')
                  # quoted output lines are names git can't print raw (control chars); skip them
                  { git -c core.quotePath=false -C "$repo" ls-files -oi --exclude-standard --directory 2>/dev/null || true; } |
                    sed -e '/^"/d' -e 's|/$||' -e 's/[][*?{}\\]/\\&/g' |
                    while IFS= read -r f; do printf 'ignore = Path %s/%s\n' "$rel" "$f"; done
                done < <(find "$root/$p" \( ${findPrune} \) -prune -o -name .git -print0 -prune 2>/dev/null)
              done >"$tmp"
              mv "$tmp" "$out"
            }
            gen_gitignore 9>&- || true

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
              gen_gitignore 9>&- || true
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
            "source gitignore.prf"
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
