_: {
  aspects.shell.zsh = {
    nixos = _: {
      programs.zsh.enable = true;
    };

    finix = { pkgs, ... }: {
      users.defaultUserShell = pkgs.zsh;
      environment.shells = [ pkgs.zsh ];
      environment.systemPackages = [ pkgs.zsh ];
      environment.etc."zshenv".text = "";
    };

    home = { pkgs, lib, ... }: {
      packages = [
        pkgs.eza
        pkgs.atuin
      ];

      xdg.config.files."atuin/config.toml".text = ''
        update_check = false
      '';

      rum.programs.zsh = {
        enable = true;

        plugins = {
          "00-compinit".config = ''
            # package-shipped completions (_jj, _nix, _gh, _eza, …). finix has
            # no /etc/zshrc to do this and zsh's built-in fpath is just its own
            # functions dir, so without these two lines every completion a
            # package ships is invisible. Appended, not prepended, so zsh's own
            # curated completions still win on conflict.
            fpath+=(
              /run/current-system/sw/share/zsh/site-functions
              /etc/profiles/per-user/$USERNAME/share/zsh/site-functions
            )

            # completions — regenerate the compdump at most once a day
            autoload -Uz compinit
            if [[ -n ~/.zcompdump(#qNmh+24) ]]; then
              compinit
            else
              compinit -C
            fi
          '';

          "10-fzf".config = ''
            source <(${lib.getExe pkgs.fzf} --zsh)
          '';

          "20-fzf-tab" = {
            source = "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh";
            config = ''
              # fzf-tab drives the menu itself
              zstyle ':completion:*' menu no
              zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
              zstyle ':fzf-tab:*' use-fzf-default-opts yes
              zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
              zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview \
                'eza -1 --icons=auto --color=always $realpath'
            '';
          };

          "30-forgit".source = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh";
          "30-nix-shell".source =
            "${pkgs.zsh-nix-shell}/share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh";
          "40-autosuggestions".source =
            "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          "50-atuin".config = ''
            source <(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow --disable-ai)
          '';

          "90-syntax-highlighting".source =
            "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";

          "99-history-substring-search" = {
            source = "${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh";
            config = ''
              bindkey '^[[A' history-substring-search-up
              bindkey '^[[B' history-substring-search-down
              bindkey '^[OA' history-substring-search-up
              bindkey '^[OB' history-substring-search-down
              bindkey -M vicmd 'k' history-substring-search-up
              bindkey -M vicmd 'j' history-substring-search-down
            '';
          };
        };

        initConfig = "\n" + ''
          # aliases
          alias rm='rm -i'
          alias cp='cp -i'
          alias mv='mv -i'

          alias ..='cd ..'
          alias ...='cd ../..'
          alias ....='cd ../../..'
          alias -- -='cd -'

          alias re='exec $SHELL -l'

          alias ls='eza --icons=auto --git'
          alias ll='eza -l --icons=auto --git --header'
          alias la='eza -la --icons=auto --git --header'
          alias lt='eza --tree --level=2 --icons=auto'
          alias lt3='eza --tree --level=3 --icons=auto'
          alias llm='eza -l --sort=modified --icons=auto --git'
          alias lls='eza -l --sort=size --icons=auto --git'

          alias grep='grep --color=auto'

          alias du='du -h'
          alias df='df -h'

          # history
          HISTSIZE=10000
          SAVEHIST=10000
          HISTFILE="$HOME/.zsh_history"
          setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

          # show fastfetch only in login shells, not every shell
          if [[ -o login ]] && command -v fastfetch >/dev/null; then
            fastfetch
          fi
        '';
      };
    };
    description = "zsh as the login shell, with completions, fzf-tab and atuin history.";
  };
}
