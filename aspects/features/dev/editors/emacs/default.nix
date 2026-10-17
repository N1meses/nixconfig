{ inputs, ... }:
{
  aspects.dev.editors.emacs = {
    description = "GNU Emacs with packages and init baked into one wrapped package.";

    wrapper =
      { config, pkgs, ... }:
      let
        cfg = config.editors.emacs;
        emacs = (pkgs.emacsPackagesFor (cfg.base pkgs)).withPackages cfg.packages;
        initDir = pkgs.linkFarm "emacs-init" [
          {
            name = "early-init.el";
            path = pkgs.writeText "early-init.el" cfg.earlyInit;
          }
          {
            name = "init.el";
            path = pkgs.writeText "init.el" cfg.init;
          }
        ];
      in
      {
        package = emacs;
        flags = [
          "--init-directory"
          "${initDir}"
        ];
      };

    home =
      { lib, pkgs, ... }:
      let
        nemesis =
          epkgs:
          epkgs.trivialBuild {
            pname = "nemesis";
            version = "0";
            src = ./nemesis;
            packageRequires = with epkgs; [
              multiple-cursors
              expreg
              surround
              consult
              avy
            ];
            turnCompilationWarningToError = true;
          };

        noxTheme =
          epkgs:
          epkgs.trivialBuild {
            pname = "nox-theme";
            version = "0";
            src = pkgs.linkFarm "nox-theme-src" [
              {
                name = "nox-default-theme.el";
                path = pkgs.writeText "nox-default-theme.el" (
                  import "${inputs.self}/assets/themes/nox/to-emacs.nix"
                );
              }
              {
                name = "nox-theme.el";
                path = pkgs.writeText "nox-theme.el" ''
                  ;;; nox-theme.el --- -*- lexical-binding: t -*-
                  (add-to-list 'custom-theme-load-path
                               (file-name-directory (or load-file-name buffer-file-name)))
                  ;; Helix scopes Emacs has no face for; coloured by nox-default.
                  (defface nox-type-builtin-face '((t :inherit font-lock-type-face))
                    "Builtin/primitive types (helix `type.builtin').")
                  (defface nox-namespace-face '((t :inherit font-lock-constant-face))
                    "Modules and paths (helix `namespace').")
                  (defface nox-variable-builtin-face '((t :inherit font-lock-builtin-face))
                    "Builtin variables like `builtins', `self' (helix `variable.builtin').")
                  (provide 'nox-theme)
                '';
              }
            ];
          };
      in
      {
        options.editors.emacs = {
          base = lib.mkOption {
            type = lib.types.functionTo lib.types.package;
            default = p: p.emacs-pgtk;
            description = "Emacs build to wrap, picked from pkgs.";
          };
          packages = lib.mkOption {
            type = lib.types.functionTo (lib.types.listOf lib.types.package);
            default = _: [ ];
            description = "Emacs packages, passed to withPackages.";
          };
          earlyInit = lib.mkOption {
            type = lib.types.lines;
            description = "Contents of early-init.el.";
          };
          init = lib.mkOption {
            type = lib.types.lines;
            description = "Contents of init.el.";
          };
        };

        config = {
	  environment.sessionVariables = {
            EDITOR = "emacs -nw";
            VISUAL = lib.mkDefault "emacs";
	  };
	  
	  rum.programs.nushell.aliases = {
	    em = "emacs -nw";
	  };

	  editors.emacs = {
            packages = epkgs: [
              (noxTheme epkgs)
              (nemesis epkgs)
              epkgs.treesit-grammars.with-all-grammars
              epkgs.nix-ts-mode
              epkgs.vertico
              epkgs.orderless
              epkgs.envrc
              epkgs.corfu
              epkgs.marginalia
              epkgs.indent-bars
              epkgs.eldoc-box
            ];
            earlyInit = lib.mkBefore (builtins.readFile ./early-init.el);
            init = lib.mkMerge [
              (lib.mkBefore (builtins.readFile ./init.el))
              # After init.el: its first line must stay the lexical-binding cookie.
              (lib.mkAfter ''
		(defconst my/rust-analyzer "${pkgs.rust-analyzer}/bin/rust-analyzer"
                "rust-analyzer from nixpkgs, for when none is on `exec-path'.")
              '')
            ];
          };  
	};
      };
  };
}
