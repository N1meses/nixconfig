_: {
  flake.modules = {
    nixos.zsh = _: {
      programs.zsh.enable = true;
    };

    finix.zsh = {pkgs, ...}: {
      users.defaultUserShell = pkgs.zsh;
      environment.shells = [pkgs.zsh];
      environment.systemPackages = [pkgs.zsh];
      environment.etc."zshenv".text = "";
    };

    homeManager.zsh = {
      pkgs,
      lib,
      config,
      ...
    }: {
      programs = {
        eza = {
          enable = true;
          enableZshIntegration = true;
          git = true;
        };

        zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          enableCompletion = lib.mkDefault true;
          autosuggestion.enable = lib.mkDefault true;
          syntaxHighlighting = {
            enable = lib.mkDefault true;
            highlighters = ["main"];
          };

          completionInit = ''
            autoload -Uz compinit
            # Only regenerate compdump once a day
            if [[ -n ~/.zcompdump(#qNmh+24) ]]; then
              compinit
            else
              compinit -C
            fi
          '';

          shellAliases = {
            rm = "rm -i";
            cp = "cp -i";
            mv = "mv -i";

            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "-" = "cd -";

            re = "exec $SHELL -l";

            ls = "eza --icons=auto --git";
            ll = "eza -l --icons=auto --git --header";
            la = "eza -la --icons=auto --git --header";
            lt = "eza --tree --level=2 --icons=auto";
            lt3 = "eza --tree --level=3 --icons=auto";
            llm = "eza -l --sort=modified --icons=auto --git";
            lls = "eza -l --sort=size --icons=auto --git";

            grep = "grep --color=auto";

            du = "du -h";
            df = "df -h";
          };

          initContent = ''
            # show fastfetch only in login shells, not every shell
            if [[ -o login ]] && command -v fastfetch >/dev/null; then
              fastfetch
            fi

            # Set history options for better performance
            setopt HIST_FCNTL_LOCK
            setopt HIST_IGNORE_DUPS
            setopt SHARE_HISTORY
          '';

          plugins = [
            {
              name = "fzf-tab";
              src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
            }
            {
              name = "zsh-history-substring-search";
              src = "${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search";
            }
            {
              name = "zsh-forgit";
              src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
            }
            {
              name = "zsh-nix-shell";
              src = "${pkgs.zsh-nix-shell}/share/zsh/plugins/zsh-nix-shell";
              file = "nix-shell.plugin.zsh";
            }
          ];

          history = {
            size = 10000;
            save = 10000;
            path = "$HOME/.zsh_history";
            ignoreAllDups = false;
            ignoreDups = true;
            ignoreSpace = true;
            share = true;
          };
        };
      };
    };
  };
}
