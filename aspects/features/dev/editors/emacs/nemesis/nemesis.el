;;; nemesis.el --- Modeless helix-style editing  -*- lexical-binding: t; -*-

;;; Commentary:
;; A global minor mode for selection-first editing without modes: Alt acts
;; on the text (move, select, edit), Ctrl around it (files, windows,
;; buffers, LSP).  The keymap sits in `emulation-mode-map-alists', above
;; every major and minor mode map.  It is off in the minibuffer and in
;; `nemesis-excluded-modes'.

;;; Code:

(defgroup nemesis nil
  "Modeless helix-style keybindings."
  :prefix "nemesis-"
  :group 'editing
  :group 'convenience)

(defcustom nemesis-excluded-modes '(term-mode)
  "Major modes where the nemesis keys stay off.
Derived modes count too."
  :type '(repeat symbol))

(require 'nemesis-keys)

(defvar-local nemesis--active t
  "Non-nil when `nemesis-map' applies in this buffer.")

(defvar nemesis--alist `((nemesis--active . ,nemesis-map))
  "Entry for `emulation-mode-map-alists'.")

(defvar nemesis--isearch-saved nil
  "The `isearch-mode-map' bindings nemesis replaced, as (KEY . COMMAND).")

(defun nemesis--off ()
  "Turn the nemesis keys off in this buffer."
  (setq-local nemesis--active nil))

(defun nemesis--check-mode ()
  "Turn the nemesis keys off if this buffer's major mode is excluded."
  (when (derived-mode-p nemesis-excluded-modes)
    (nemesis--off)))

(defun nemesis--isearch-keys (on)
  "Add the nemesis keys to `isearch-mode-map' when ON, else restore it."
  (cond ((and on (not nemesis--isearch-saved))
         (pcase-dolist (`(,key . ,cmd) nemesis--isearch-keys)
           (push (cons key (keymap-lookup isearch-mode-map key))
                 nemesis--isearch-saved)
           (keymap-set isearch-mode-map key cmd)))
        ((not on)
         (pcase-dolist (`(,key . ,cmd) nemesis--isearch-saved)
           (keymap-set isearch-mode-map key cmd))
         (setq nemesis--isearch-saved nil))))

;;;###autoload
(define-minor-mode nemesis-mode
  "Modeless helix-style editing on Alt and Ctrl."
  :global t
  :lighter " N"
  (if nemesis-mode
      (progn
        (add-to-list 'emulation-mode-map-alists 'nemesis--alist)
        (add-hook 'minibuffer-setup-hook #'nemesis--off)
        (add-hook 'after-change-major-mode-hook #'nemesis--check-mode)
        (add-hook 'isearch-mode-end-hook #'nemesis--isearch-select))
    (setq emulation-mode-map-alists
          (delq 'nemesis--alist emulation-mode-map-alists))
    (remove-hook 'minibuffer-setup-hook #'nemesis--off)
    (remove-hook 'after-change-major-mode-hook #'nemesis--check-mode)
    (remove-hook 'isearch-mode-end-hook #'nemesis--isearch-select))
  (nemesis--isearch-keys nemesis-mode))

(provide 'nemesis)
;;; nemesis.el ends here
