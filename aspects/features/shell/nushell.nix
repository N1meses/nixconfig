{ inputs, ... }:
let
  inshellah =
    { config, lib, ... }:
    {
      imports = [ "${inputs.inshellah}/nix/module.nix" ];
      programs.inshellah = {
        enable = true;
        extraScrapePackages = lib.concatMap (u: u.packages) (
          lib.filter (u: u.enable) (lib.attrValues config.hjem.users)
        );
      };
    };
in
{
  aspects.shell.nushell = {
    description = "Nushell as the interactive shell behind a bash login (or alongside zsh), with inshellah completions.";
    nixos = inshellah;
    finix = {
      imports = [
        inshellah
        inputs.finix.nixosModules.bash
      ];
      programs.bash.enable = true;
    };

    home =
      {
        config,
        osConfig,
        pkgs,
        lib,
        ...
      }:
      {
        files =
          lib.mkIf
            (lib.elem (lib.getName osConfig.users.users.${config.user}.shell) [
              "bash"
              "bash-interactive"
            ])
            {
              ".bash_profile".text = ''
                . ${config.environment.loadEnv}
                [ -r ~/.bashrc ] && . ~/.bashrc
              '';
              ".bashrc".text = ''
                if [[ $- == *i* && $(ps -o comm= -p $PPID) != nu ]] && command -v nu >/dev/null; then
                  exec nu
                fi
              '';
            };

        packages = [
          pkgs.atuin
          pkgs.eza
        ];

        xdg.config.files."atuin/config.toml".text = lib.mkDefault ''
          update_check = false
        '';

        rum.programs.zoxide.integrations.nushell.enable = true;
        rum.programs.starship.integrations.nushell.enable = true;
        rum.programs.nix-your-shell = {
          enable = true;
          integrations.nushell.enable = true;
        };

        rum.programs.nushell = {
          enable = true;

          plugins = with pkgs.nushellPlugins; [
            #polars
            query
            skim
            gstat
            formats
            desktop_notifications
          ];

          settings = {
            show_banner = false;
            completions.algorithm = "fuzzy";
            history.file_format = "sqlite";
          };

          aliases = {
            ll = "eza -l --icons=auto --git --header";
            la = "eza -la --icons=auto --git --header";
            lt = "eza --tree --level=2 --icons=auto";
            lt3 = "eza --tree --level=3 --icons=auto";
            llm = "eza -l --sort=modified --icons=auto --git";
            lls = "eza -l --sort=size --icons=auto --git";
	    
	    em = "emacs -nw";
          };

          extraConfig = ''
            source ${
              pkgs.runCommand "atuin-init-nu" { } ''
                HOME=$TMPDIR ${lib.getExe pkgs.atuin} init nu --disable-up-arrow --disable-ai > "$out"
              ''
            }

            # direnv: rum's integration leaves $env.PATH a string after load-env
            $env.config.hooks.pre_prompt = (
              $env.config.hooks.pre_prompt? | default [] | append {||
                if (which direnv | is-empty) { return }
                direnv export json | from json | default {} | load-env
                if ($env.PATH | describe) == "string" {
                  $env.PATH = ($env.PATH | split row (char esep))
                }
              }
            )
          '';
        };
      };
  };

  pins.inshellah = {
    url = "https://github.com/manic-systems/inshellah";
    flake = false;
  };
}
