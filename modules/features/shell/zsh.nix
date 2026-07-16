_: {
  aspects.zsh = {
    nixos = _: {
      programs.zsh.enable = true;
    };

    finix = {pkgs, ...}: {
      users.defaultUserShell = pkgs.zsh;
      environment.shells = [pkgs.zsh];
      environment.systemPackages = [pkgs.zsh];
      environment.etc."zshenv".text = "";
    };

    home = {pkgs, ...}: {
      packages = [pkgs.eza];

      rum.programs.zsh = {
        enable = true;

        plugins = {
          autosuggestions.source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          forgit.source = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh";
          fzf-tab.source = "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh";
          history-substring-search.source = "${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh";
          nix-shell.source = "${pkgs.zsh-nix-shell}/share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh";
          syntax-highlighting.source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        };

        initConfig = ''
          # completions — regenerate the compdump at most once a day
          autoload -Uz compinit
          if [[ -n ~/.zcompdump(#qNmh+24) ]]; then
            compinit
          else
            compinit -C
          fi

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
  };
}
