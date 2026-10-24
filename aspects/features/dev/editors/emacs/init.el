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
;; Markdown: Emacs 31's built-in tree-sitter mode; not autoloaded by default.
(autoload 'markdown-ts-mode "markdown-ts-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

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
             '(use_declaration argument: (scoped_identifier name: (identifier) @nox-namespace-face)))
            ;; @constructor: PascalCase callee of a path call (`Strategy::Tag(x)').
            (my/helix-rules
             'rust
             '((call_expression function: (scoped_identifier name: (identifier) @font-lock-type-face))
               (:match "\\`[A-Z]" @font-lock-type-face)))))

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
;; Except prose: org and markdown wrap at word boundaries.
(dolist (hook '(org-mode-hook markdown-ts-mode-hook))
  (add-hook hook #'visual-line-mode))

;; Markdown: TAB indents like in code (markdown-ts binds it to heading
;; folding, which moves to C-c TAB); spaces, steps of 2 (list nesting), so
;; <backtab> (nemesis dedent) goes back by the same step.
(defun my/markdown-tab ()
  "Indent the line or selection one step."
  (interactive)
  (if (use-region-p)
      (progn
        (indent-rigidly-right-to-tab-stop (region-beginning) (region-end))
        (setq deactivate-mark nil))
    (indent-rigidly-right-to-tab-stop (line-beginning-position)
                                      (line-end-position))))
(add-hook 'markdown-ts-mode-hook
          (lambda ()
            (setq-local indent-tabs-mode nil tab-width 2)
            ;; outline-minor-mode would still take TAB on heading lines.
            (setq-local outline-minor-mode-cycle nil)))
(with-eval-after-load 'markdown-ts-mode
  (keymap-set markdown-ts-mode-map "TAB" #'my/markdown-tab)
  (keymap-set markdown-ts-mode-map "C-c TAB" #'markdown-ts-outline-cycle))

;; PlantUML: plantuml-mode for .puml files, ob-plantuml for org src blocks.
;; Both run the `plantuml' binary from exec-path (project devshell); the
;; default 'server mode would send every diagram to plantuml.com.
(setq plantuml-default-exec-mode 'executable
      org-plantuml-exec-mode 'plantuml)
;; plantuml-mode's autoload covers .pu/.uml/.plantuml, not .puml.
(add-to-list 'auto-mode-alist '("\\.puml\\'" . plantuml-mode))
(with-eval-after-load 'org
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t) (plantuml . t))))

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
(electric-pair-mode 1)                  ; ( [ { " insert their closing pair

;; Clipboard: a tty frame can't reach the Wayland clipboard (`gui-select-text'
;; needs a window system), so copy goes through wl-copy there.  Paste always
;; reads wl-paste: pgtk answers from its own record of what Emacs last copied
;; until GTK reports that another app took the clipboard (pgtkselect.c), and
;; when that report is lost, pasting from other apps yields nil.
(defvar my/wl-last nil "Text this Emacs last put on the clipboard.")

(defun my/clipboard-cut (text)
  "Put TEXT on the system clipboard."
  (setq my/wl-last text)
  (if (display-graphic-p)
      (gui-select-text text)
    (let ((proc (make-process :name "wl-copy" :command '("wl-copy")
                              :connection-type 'pipe :noquery t)))
      (process-send-string proc text)
      (process-send-eof proc))))

(defun my/clipboard-paste ()
  "Return the clipboard text if another program put it there, else nil."
  (with-temp-buffer
    (when (zerop (call-process "wl-paste" nil '(t nil) nil "--no-newline" "--type" "text"))
      (let ((text (buffer-string)))
        (unless (or (string-empty-p text) (equal text my/wl-last))
          text)))))

(when (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
  (setq interprogram-cut-function #'my/clipboard-cut
        interprogram-paste-function #'my/clipboard-paste))
(setq isearch-lazy-count t)             ; "3/12" while searching
(vertico-mode 1)
(marginalia-mode 1)                     ; details next to vertico candidates
(setq completion-styles '(orderless basic))

;; Completion popup while typing (fed by eglot).  In the popup M-j / M-k
;; move (corfu remaps next-line / previous-line), RET inserts, C-g closes.
(setq corfu-auto t)
(global-corfu-mode 1)

;; Indentation guides in code buffers.  nix-ts-mode counts as nix-mode, and
;; indent-bars checks nix-mode (tab-width, 8) before nix-ts-mode, so give it
;; the real offset (2).
(defun my/indent-bars ()
  "Turn on `indent-bars-mode' with the right spacing for this mode."
  (when (derived-mode-p 'nix-ts-mode)
    (setq-local indent-bars-spacing-override nix-ts-mode-indent-offset))
  (indent-bars-mode 1))
(add-hook 'prog-mode-hook #'my/indent-bars)

;; LSP: eglot (built in).  Python and Rust need no entry: eglot's default list
;; picks pyright-langserver and rust-analyzer from exec-path (devshell/user).
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd"))))
;; Colours come from tree-sitter + the helix rules only.  Semantic tokens
;; would paint over them (declarations and constructor calls turn function-yellow).
(setq eglot-ignored-server-capabilities '(:semanticTokensProvider))
(dolist (hook '(nix-ts-mode-hook python-ts-mode-hook rust-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;; LSP hover docs (signature, parameters, docs) in a popup at the cursor.
;; GUI only: the popup is a child frame; the terminal keeps the echo area.
;; C-l h turns the always-on popup off / on, C-l k shows it once.
(defvar my/eldoc-box-auto t
  "Non-nil: the docs popup follows the cursor in eglot buffers.")

(defun my/eldoc-box ()
  "Follow eglot: docs popup at point while eglot manages the buffer."
  (eldoc-box-hover-at-point-mode
   (if (and my/eldoc-box-auto (display-graphic-p) (eglot-managed-p)) 1 -1)))
(add-hook 'eglot-managed-mode-hook #'my/eldoc-box)

(defun my/eldoc-box-toggle ()
  "Turn the always-on docs popup off or on, in every eglot buffer."
  (interactive)
  (setq my/eldoc-box-auto (not my/eldoc-box-auto))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (eglot-managed-p)
        (my/eldoc-box))))
  (message "Docs popup %s" (if my/eldoc-box-auto "follows the cursor" "off")))

(defun my/doc-at-point ()
  "Show the docs at point once: popup in the GUI, echo area in a terminal."
  (interactive)
  (if (display-graphic-p)
      (eldoc-box-help-at-point)
    (eldoc)))

(with-eval-after-load 'nemesis-keys
  (keymap-set nemesis-lsp-map "k" #'my/doc-at-point)
  (keymap-set nemesis-lsp-map "h" #'my/eldoc-box-toggle))

;; Popup border: eldoc-box defaults to white; use the theme's dim grey.
(with-eval-after-load 'eldoc-box
  (set-face-attribute 'eldoc-box-border nil
                      :background (face-foreground 'shadow nil t)))

;; Semantic tokens: rust-analyzer marks std items (parse, unwrap_or) as
;; defaultLibrary, which eglot paints as builtin (purple).  Empty that face so
;; they keep the normal method / function colour.
(with-eval-after-load 'eglot
  (face-spec-set 'eglot-semantic-defaultLibrary '((t :inherit nil)))
  ;; Hover docs are markdown; render them with the built-in tree-sitter
  ;; markdown mode so code blocks get syntax colours (default: plain text).
  (require 'markdown-ts-mode)
  (defun my/doc-view-mode ()
    "Render LSP docs: `markdown-ts-view-mode', prose as doc comments.
Paragraphs get `font-lock-doc-face' (like Rust ///) appended, so code
blocks keep their syntax colours and links / code spans their faces."
    (markdown-ts-view-mode)
    (setq-local treesit-font-lock-settings
                (append treesit-font-lock-settings
                        (treesit-font-lock-rules
                         :language 'markdown :override 'append
                         :feature 'doc-prose
                         '((paragraph) @font-lock-doc-face))))
    (setf (car treesit-font-lock-feature-list)
          (append (car treesit-font-lock-feature-list) '(doc-prose)))
    (treesit-font-lock-recompute-features))
  (setq eglot-documentation-renderer #'my/doc-view-mode)

  ;; The signature line (signatureHelp) is plain text with only the function
  ;; name and the active parameter marked.  Colour it with the buffer's own
  ;; major mode; the active parameter stays bold on top.
  (defun my/eglot-colour-signature (orig &rest args)
    "Around `eglot--sig-info': syntax-colour the signature's first line."
    (let ((info (apply orig args))
          (mode major-mode))
      (if (not (and (stringp info) (provided-mode-derived-p mode 'prog-mode)))
          info
        (let* ((eol (or (string-search "\n" info) (length info)))
               (label (with-temp-buffer
                        (insert (substring-no-properties info 0 eol))
                        (delay-mode-hooks (funcall mode))
                        (font-lock-ensure)
                        (buffer-string))))
          (dotimes (i eol)
            (let ((face (get-text-property i 'face info)))
              (when (memq 'eldoc-highlight-function-argument (ensure-list face))
                (add-face-text-property i (1+ i) 'eldoc-highlight-function-argument
                                        nil label))))
          (concat label (substring info eol))))))
  (advice-add 'eglot--sig-info :around #'my/eglot-colour-signature)

  ;; Inlay hints: eglot 31.1 fetches them once when text is displayed and
  ;; has no handler for workspace/inlayHint/refresh.  A just-opened Rust file
  ;; gets nothing while rust-analyzer still indexes, and hints only appear
  ;; after an edit.  Tell servers we take refreshes, and refetch on one.
  (cl-defmethod eglot-client-capabilities :around (_server)
    (let ((caps (cl-call-next-method)))
      (plist-put caps :workspace
                 (plist-put (plist-get caps :workspace)
                            :inlayHint '(:refreshSupport t)))))
  (defun my/eglot-refetch-hints (server)
    "Refetch inlay hints for the visible part of SERVER's buffers.
Calls the fetch directly: going through jit-lock would be dropped,
because eglot skips a region equal to the last one it fetched."
    (dolist (buffer (eglot--managed-buffers server))
      (with-current-buffer buffer
        (when eglot-inlay-hints-mode
          (dolist (window (get-buffer-window-list buffer nil t))
            (eglot--update-hints-1 (window-start window)
                                   (window-end window t)))))))
  (cl-defmethod eglot-handle-request
    (server (_method (eql workspace/inlayHint/refresh)))
    "Refetch inlay hints when SERVER asks for it."
    (my/eglot-refetch-hints server)
    nil)
  ;; rust-analyzer sends that refresh too early (hints still empty) and not
  ;; again, so also refetch when a server progress report (indexing, build
  ;; scripts) ends.  Debounced: several end at once.
  (defvar my/eglot-hints-timer nil)
  (cl-defmethod eglot-handle-notification :after
    (server (_method (eql $/progress)) &key value &allow-other-keys)
    (when (equal (plist-get value :kind) "end")
      (when my/eglot-hints-timer (cancel-timer my/eglot-hints-timer))
      (setq my/eglot-hints-timer
            (run-at-time 0.5 nil #'my/eglot-refetch-hints server)))))

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
