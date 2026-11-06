_: {
  aspects.shell.starship = {
    description = "The starship prompt, themed.";
    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        jj = "${lib.getExe pkgs.jujutsu} --ignore-working-copy";
        # no $all: it would render the git modules a second time beside $vcs
        languages = [
          "rust"
          "golang"
          "nodejs"
          "c"
          "cpp"
          "lua"
          "zig"
          "java"
          "ruby"
          "haskell"
        ];
        # what's on PATH beyond the first shell's copy; `nix shell` sets nothing else
        nixPathPrompt = pkgs.writers.writeDash "nix-path-prompt" ''
          [ -z "$IN_NIX_SHELL" ] && [ -n "$NIX_BASE_PATH" ] || exit 0
          IFS=:
          for p in $PATH; do
            case ":$NIX_BASE_PATH:" in *":$p:"*) continue ;; esac
            case "$p" in
              /nix/store/*-man | /nix/store/*-man/*) ;;
              /nix/store/*)
                p=''${p#/nix/store/*-}
                out="$out ''${p%%/*}"
                ;;
            esac
          done
          [ -z "$out" ] || printf '❄️%s' "$out"
        '';
        envModules = [
          "nix_shell"
          "custom.nix_path"
          "python"
          "conda"
          "pixi"
        ]
        ++ languages
        ++ [ "direnv" ];
      in
      {
        # set once by the first shell; `nix shell` children inherit it unchanged
        rum.programs.zsh.plugins."00-nix-base-path".config = ''
          export NIX_BASE_PATH="''${NIX_BASE_PATH-$PATH}"
        '';
        rum.programs.nushell.extraConfig = ''
          $env.NIX_BASE_PATH = ($env.NIX_BASE_PATH? | default ($env.PATH | str join (char esep)))
          # atuin's pre_prompt `job spawn` is still running when the prompt
          # renders, so $jobs shows a phantom ✦ on nu; same config, jobs off
          $env.STARSHIP_CONFIG = "${
            (pkgs.formats.toml { }).generate "starship-nu.toml" (
              lib.recursiveUpdate config.rum.programs.starship.settings { jobs.disabled = true; }
            )
          }"
        '';

        rum.programs.starship = {
          enable = lib.mkDefault true;
          integrations.zsh.enable = true;

          settings =
            lib.genAttrs languages (_: {
              format = "[$symbol($version )]($style)";
            })
            // {
              scan_timeout = 30;
              command_timeout = 500;
              add_newline = true;

              # left-aligned only, so a resize can't cut anything off;
              # the group around line 3 drops it when there's no repo or env
              format = lib.concatStrings [
                "[╭──╼](bold blue) $username$hostname$jobs$cmd_duration$status\n"
                "[┆](bold blue) $directory\n"
                "([┆](bold blue) $vcs\${custom.jj_ahead}"
                (lib.concatMapStrings (m: "\${${m}}") envModules)
                "\n)$character"
              ];

              # the host alone, the same locally and over ssh;
              # any account but this one (root, say) still shows up
              username = {
                show_always = true;
                format = "([$user]($style)[ at ](dimmed))";
                style_user = "bold green";
                style_root = "bold red";
                aliases.${config.user} = "";
              };

              hostname = {
                ssh_only = false;
                format = "[$hostname]($style) ";
                style = "bold red";
              };

              jobs.format = "[$symbol$number]($style) ";

              cmd_duration = {
                min_time = 2000;
                format = "[󱎫 $duration]($style) ";
                show_milliseconds = false;
              };

              status = {
                disabled = false;
                format = "[✗$status]($style) ";
              };

              character = {
                success_symbol = "[╰─>](bold blue)";
                error_symbol = "[╰─>](bold red)";

                vimcmd_symbol = "[╰─<](bold green)";
                vimcmd_replace_one_symbol = "[╰─<](bold purple)";
                vimcmd_replace_symbol = "[╰─<](bold purple)";
                vimcmd_visual_symbol = "[╰─<](bold yellow)";
              };

              directory = {
                truncation_length = 0;
                truncate_to_repo = false;
                read_only = " 󰌾";
                style = "bold cyan";

                repo_root_style = "bold underline cyan";
                repo_root_format = lib.concatStrings [
                  "[$before_root_path]($before_repo_root_style)"
                  "[$repo_root]($repo_root_style)"
                  "[$path]($style)"
                  "[$read_only]($read_only_style) "
                ];
              };

              # git and jj share one layout: name, id, lines, [files], sync.
              # jj first, or colocated repos render as a detached git HEAD
              vcs = {
                order = [
                  "jj"
                  "git"
                  "hg"
                  "pijul"
                  "fossil"
                ];
                git_modules = "$git_branch$git_commit$git_metrics$git_status$git_state";
              };

              jj_bookmark = {
                symbol = "";
                format = "[$symbol$bookmark(@$remote)$diverged]($style) ";
              };

              jj_change.format = "$change ";

              jj_metrics.format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";

              jj_status = {
                format = "([\\[$all\\]]($style) )";
                description_empty = "";
                conflicted = "!";
                immutable = "◆";
                added = "A\${count}";
                modified = "~\${count}";
                deleted = "✘\${count}";
                renamed = "»\${count}";
                copied = "=\${count}";
              };

              # jj_status has no ahead count; unpushed commits with content, without @
              custom.jj_ahead = {
                # fixed shell: the default follows $STARSHIP_SHELL, and nushell has no `[`
                shell = [ (lib.getExe pkgs.dash) ];
                when = "${jj} root";
                command = ''
                  [ -n "$(${jj} git remote list 2>/dev/null)" ] || exit 0
                  n=$(${jj} log --no-graph -r 'remote_bookmarks()..@- ~ root() ~ empty()' -T '"x"' 2>/dev/null | wc -c)
                  [ "$n" -gt 0 ] && echo "⇡$n"
                '';
                format = "([$output]($style) )";
                style = "bold red";
              };

              # the module's heuristic can't tell `nix shell` paths from ones
              # the session already had (compositor and terminal wrappers)
              custom.nix_path = {
                when = true;
                shell = [ "${nixPathPrompt}" ];
                format = "([$output]($style) )";
                style = "bold blue";
              };

              git_branch = {
                symbol = "";
                only_attached = true;
                format = "[$symbol$branch(:$remote_branch)]($style) ";
              };

              git_commit = {
                only_detached = false;
                commit_hash_length = 7;
                # conditional: no hash before the first commit
                format = "([$hash$tag]($style) )";
                style = "bold green";
              };

              git_metrics = {
                disabled = false;
                format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
              };

              git_status = {
                format = lib.concatStrings [
                  "([\\[$conflicted$stashed$deleted$renamed$modified$typechanged$staged$untracked\\]]($style) )"
                  "([$ahead_behind]($style) )"
                ];
                ahead = "⇡\${count}";
                behind = "⇣\${count}";
                diverged = "⇡\${ahead_count}⇣\${behind_count}";

                conflicted = "!\${count}";
                stashed = "≡\${count}";
                staged = "A\${count}";
                modified = "~\${count}";
                renamed = "»\${count}";
                deleted = "✘\${count}";
                untracked = "?\${count}";
              };

              git_state = {
                format = "[$state( $progress_current/$progress_total)]($style) ";
                style = "bold red";
              };

              python = {
                symbol = "🐍 ";
                format = "[$symbol$pyenv_prefix($version )(\\($virtualenv\\) )]($style)";

                detect_extensions = [
                  "py"
                  "ipynb"
                ];
                detect_files = [
                  "requirements.txt"
                  "pyproject.toml"
                  "Pipfile"
                  "setup.py"
                  "manage.py"
                  "tox.ini"
                  ".python-version"
                ];

                pyenv_version_name = false;
                python_binary = [
                  "python3"
                  "python"
                ];
              };

              nix_shell = {
                symbol = "❄️ ";
                format = "[$symbol$state(\\($name\\))]($style) ";
                impure_msg = "";
                pure_msg = "pure ";
              };

              # silent while things work; only flags an .envrc that isn't allowed
              direnv = {
                disabled = false;
                symbol = "";
                format = "([$loaded$allowed]($style) )";
                loaded_msg = "";
                unloaded_msg = "";
                allowed_msg = "";
                not_allowed_msg = "direnv blocked";
                denied_msg = "direnv denied";
              };
            };
        };
      };
  };
}
