_: {
  aspects.shell.starship = {
    description = "The starship prompt, themed.";
    home = { lib, ... }: {
      rum.programs.starship = {
        enable = lib.mkDefault true;
        integrations.zsh.enable = true;

        settings = {
          scan_timeout = 30;
          command_timeout = 500;
          add_newline = true;

          directory = {
            fish_style_pwd_dir_length = 3;

            truncation_length = 3;
            truncate_to_repo = true;
            truncation_symbol = "…/";

            home_symbol = "󰋜 ~";

            read_only = " 󰌾";

            substitutions = {
              "Documents" = "󰈙 ";
              "Downloads" = " ";
              "Music" = "󰝚 ";
              "Pictures" = " ";
              "/nixconfig" = "/";
              "~/.config" = " ";
            };

            repo_root_style = "bold underline";
            repo_root_format = lib.concatStrings [
              "[$before_root_path]($before_repo_root_style)"
              "[$repo_root]($repo_root_style)"
              "[$path]($style)"
              "[$read_only]($read_only_style)"
            ];
          };

          git_branch = {
            symbol = " ";
            truncation_length = 25;
            truncation_symbol = "…";
            only_attached = false;
            format = "[$symbol$branch(:$remote_branch)]($style) ";
          };

          git_status = {
            ahead = "⇡\${count} ";
            behind = "⇣\${count} ";
            diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";

            conflicted = "󰅖 \${count} ";
            stashed = "󰋻 \${count} ";
            staged = "󰸞 \${count} ";
            modified = "󰏫 \${count} ";
            renamed = "󱀱 \${count} ";
            deleted = "󰅙 \${count} ";
            untracked = "󰓾 \${count} ";
            format = "[$all_status$ahead_behind]($style) ";
          };

          git_commit = {
            commit_hash_length = 7;
            format = "[$hash$tag]($style) ";
            only_detached = true;
            tag_symbol = " 󰓹 ";
            tag_disabled = false;
          };

          git_state = {
            format = "[$state( $progress_current/$progress_total)]($style) ";
            rebase = "󰳖 REBASING";
            merge = " MERGING";
            revert = " REVERTING";
            cherry_pick = " PICKING";
            bisect = " BISECTING";
            am = " AM";
            am_or_rebase = " AM/REBASE";
          };

          git_metrics = {
            disabled = false;
            format = "([+$added]($added_style)[-$deleted]($deleted_style) )";
            only_nonzero_diffs = true;
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
            impure_msg = "impure";
            pure_msg = "pure";
            heuristic = true;
          };

          os = {
            disabled = false;
            format = "[$symbol]($style) ";
            symbols = {
              NixOS = "";
              Arch = "󰣇";
              Debian = "󰣚";
              Fedora = "󰣛";
              Linux = "";
              Macos = "";
              Ubuntu = "";
              Windows = "";
            };
          };

          cmd_duration = {
            min_time = 2000;
            format = "[ 󱎫 $duration]($style) ";
            show_milliseconds = false;
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";

            vimcmd_symbol = "[❮](bold green)";
            vimcmd_replace_one_symbol = "[❮](bold purple)";
            vimcmd_replace_symbol = "[❮](bold purple)";
            vimcmd_visual_symbol = "[❮](bold yellow)";
          };

          aws.disabled = lib.mkDefault true;
          gcloud.disabled = lib.mkDefault true;
          kubernetes.disabled = lib.mkDefault true;
          docker_context.disabled = lib.mkDefault true;
          package.disabled = lib.mkDefault true;
          battery.disabled = lib.mkDefault true;
          bun.disabled = true;
        };
      };
    };
  };
}
