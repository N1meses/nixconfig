;;; early-init.el --- -*- lexical-binding: t -*-
(defconst my/state-dir
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state/")))
(make-directory my/state-dir t)
(setq user-emacs-directory my/state-dir)

(setq auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" my/state-dir)
      abbrev-file-name (expand-file-name "abbrev_defs" my/state-dir))

;; Auto-save files (#file#) go to the state dir, not next to the file.
;; t = the full path is in the name, so equal file names don't collide.
(make-directory (expand-file-name "auto-save/" my/state-dir) t)
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my/state-dir) t)))

(setq custom-file (expand-file-name "custom.el" my/state-dir))

;; No GTK menu/tool/scroll bars: themed by GTK (noctalia), not by nox.
;; Set as frame parameters here so they never flash on startup; F10 still
;; opens the menu as a popup.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)
