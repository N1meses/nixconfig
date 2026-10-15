;;; init.el --- -*- lexical-binding: t -*-

(when (file-exists-p custom-file)
  (load custom-file nil t))

(require 'nox-theme)
(load-theme 'nox-default t)

;; Relative line numbers, like helix.
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Tree-sitter: grammars come from withPackages, which adds them to
;; treesit-extra-load-path (never setq that). t = use every *-ts-mode.
(setopt treesit-enabled-modes t)
(setq treesit-font-lock-level 4)        ; highlight everything, like helix
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

;; Where the Emacs ts-modes classify nodes differently from helix's
;; queries/<lang>/highlights.scm, override them to match helix.
(defun my/helix-rules (language &rest queries)
  "Add QUERIES for LANGUAGE as an always-on font-lock feature that overrides."
  (setq-local treesit-font-lock-settings
              (append treesit-font-lock-settings
                      (treesit-font-lock-rules
                       :language language :override t :feature 'helix
                       queries)))
  (unless (memq 'helix (car treesit-font-lock-feature-list))
    (setf (car treesit-font-lock-feature-list)
          (append (car treesit-font-lock-feature-list) '(helix))))
  (treesit-font-lock-recompute-features))

;; nix-ts-mode colours every identifier named like a builtin (`path', `map', ...)
;; as builtin even when it is a local variable, every `builtins.X' as builtin
;; even when called, and select/inherit sources as types. Rebuild helix's
;; order instead; one call per step, so later steps win.
(defconst my/nix-builtin-functions
  (rx bos (or "abort" "baseNameOf" "derivation" "derivationStrict" "dirOf"
              "fetchGit" "fetchMercurial" "fetchTarball" "fromTOML" "import"
              "isNull" "map" "placeholder" "removeAttrs" "scopedImport"
              "throw" "toString")
      eos)
  "Non-`__' names helix's nix query marks @function.builtin.")

(add-hook 'nix-ts-mode-hook
          (lambda ()
            ;; every variable use: @variable (`lib' in `lib.x', `pkgs' in `inherit (pkgs)')
            (my/helix-rules 'nix '(variable_expression name: (identifier) @font-lock-variable-use-face))
            ;; called: @function (`f x', last attr of `builtins.pathExists p', `lib.mkIf c')
            (my/helix-rules
             'nix
             '(apply_expression function: (variable_expression name: (identifier) @font-lock-function-call-face))
             '(apply_expression
               function: (select_expression
                          attrpath: (attrpath (identifier) @font-lock-function-call-face :anchor))))
            ;; @function.builtin (helix colours it like any function) and @variable.builtin
            (my/helix-rules
             'nix
             `((variable_expression name: (identifier) @font-lock-function-call-face)
               (:match ,my/nix-builtin-functions @font-lock-function-call-face))
             '((variable_expression name: (identifier) @nox-variable-builtin-face)
               (:equal "builtins" @nox-variable-builtin-face)))
            ;; @string.special.path
            (my/helix-rules
             'nix
             '([(path_expression) (hpath_expression) (spath_expression)] @font-lock-string-face))))

(add-hook 'rust-ts-mode-hook
          (lambda ()
            (my/helix-rules
             'rust
             '((primitive_type) @nox-type-builtin-face)
             '(use_list (identifier) @nox-namespace-face)
             '(use_list (scoped_identifier name: (identifier) @nox-namespace-face))
             '(use_declaration argument: (scoped_identifier name: (identifier) @nox-namespace-face)))))

(add-hook 'python-ts-mode-hook
          (lambda ()
            (let ((builtin "\\`\\(?:bool\\|bytes\\|dict\\|float\\|frozenset\\|int\\|list\\|set\\|str\\|tuple\\)\\'"))
              ;; helix: any identifier with a builtin type name, except calls
              ;; like `str(x)'. Separate calls: a later setting wins, patterns
              ;; inside one query have no reliable order.
              (my/helix-rules
               'python
               `((identifier) @nox-type-builtin-face
                 (:match ,builtin @nox-type-builtin-face)))
              (my/helix-rules
               'python
               `(call function: (identifier) @font-lock-builtin-face
                      (:match ,builtin @font-lock-builtin-face))))))

;; Cut long lines off and scroll sideways, like helix (no soft-wrap).
(setq-default truncate-lines t)

;; Never the GTK file dialog (pgtk can't use the yazi portal); file prompts
;; stay in the minibuffer. `M-x my/yazi' picks files with yazi instead.
(setq use-file-dialog nil)

(defun my/yazi ()
  "Pick files with yazi in a terminal and visit them.
Same chooser as the termfilechooser portal: the title matches its
floating window rule."
  (interactive)
  (unless (and (executable-find "xdg-terminal-exec") (executable-find "yazi"))
    (user-error "my/yazi needs xdg-terminal-exec and yazi on PATH"))
  (let ((out (make-temp-file "emacs-yazi-")))
    (make-process
     :name "yazi"
     :command (list "xdg-terminal-exec" "--title=termfilechooser"
                    "yazi" (concat "--chooser-file=" out)
                    (expand-file-name default-directory))
     :sentinel (lambda (proc _event)
                 (unless (process-live-p proc)
                   (let ((files (with-temp-buffer
                                  (insert-file-contents out)
                                  (split-string (buffer-string) "\n" t))))
                     (delete-file out)
                     (mapc #'find-file files)))))))

;; Editing basics nemesis relies on.
(delete-selection-mode 1)               ; typing / pasting replaces the selection
(which-key-mode 1)                      ; show a prefix's keys after a pause
(global-auto-revert-mode 1)             ; reload files changed on disk
(setq isearch-lazy-count t)             ; "3/12" while searching
(vertico-mode 1)
(setq completion-styles '(orderless basic))

;; LSP: eglot (built in).  Python needs no entry: eglot's default list picks
;; pyright-langserver.  Rust prefers a rust-analyzer on exec-path (project
;; devshell), else the nixpkgs one (`my/rust-analyzer', set in default.nix).
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd")))
  (add-to-list 'eglot-server-programs
               `((rust-ts-mode rust-mode)
                 . ,(lambda (&optional _interactive _project)
                      (list (or (executable-find "rust-analyzer")
                                my/rust-analyzer))))))
(dolist (hook '(nix-ts-mode-hook python-ts-mode-hook rust-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;; Per-buffer environment from the project's .envrc (direnv), so devshell
;; tools (cargo, rust-analyzer, ...) are found.  Enabled after init, as late
;; as possible, so it sets up each buffer before other modes start processes.
(add-hook 'after-init-hook #'envrc-global-mode)

(
  when-let ((d (getenv "NEMESIS_DEV")))
  (add-to-list 'load-path d)
)
(require 'nemesis)
(nemesis-mode 1)
(keymap-global-set "<f5>" #'nemesis-mode)
