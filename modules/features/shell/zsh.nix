{...}:
{
  flake.modules = {

    nixos.zsh = {...}: {
      programs.zsh.enable = true;
    };

    homeManager.zsh = {lib, ...}: {
      programs = {

        eza = {
          enable = true;
          enableZshIntegration = true;
          git = true;
        };

        zsh = {
          enable = true;
          enableCompletion = lib.mkDefault true;
          autosuggestion.enable = lib.mkDefault true;
          syntaxHighlighting = {
            enable = lib.mkDefault true;
            highlighters = [ "main" ];
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
