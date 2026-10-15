;;; nemesis-keys.el --- Keymaps for nemesis  -*- lexical-binding: t; -*-

;;; Commentary:
;; Every nemesis binding, grouped like keymap.md.  Alt acts on the text,
;; Ctrl around it.  Prefix keys carry a label for which-key.

;;; Code:

(require 'nemesis-commands)
(require 'nemesis-objects)
(require 'nemesis-mc)

;; Not autoloaded by their packages.
(autoload 'eglot-rename "eglot" nil t)
(autoload 'eglot-code-actions "eglot" nil t)
(autoload 'flymake-goto-next-error "flymake" nil t)
(autoload 'flymake-goto-prev-error "flymake" nil t)

(defvar nemesis-goto-map
  (let ((map (make-sparse-keymap)))
    (pcase-dolist (`(,key . ,cmd)
                   '(("h" . beginning-of-line)
                     ("l" . end-of-line)
                     ("k" . beginning-of-buffer)
                     ("j" . end-of-buffer)
                     ("s" . back-to-indentation)
                     ("t" . nemesis-window-top)
                     ("c" . nemesis-window-middle)
                     ("b" . nemesis-window-bottom)
                     ("u" . scroll-up-command)
                     ("f" . nemesis-next-defun)
                     ("F" . beginning-of-defun)
                     ("e" . flymake-goto-next-error)
                     ("E" . flymake-goto-prev-error)
                     ("d" . xref-find-definitions)
                     ("r" . xref-find-references)
                     ("g" . find-file-at-point)
                     ("i" . consult-imenu)))
      (keymap-set map key cmd)
      (keymap-set map (concat "M-" key) cmd))
    (dotimes (digit 10)
      (keymap-set map (format "%d" digit) #'nemesis-goto-line-live)
      (keymap-set map (format "M-%d" digit) #'nemesis-goto-line-live))
    map)
  "Goto keys under `M-g'.  Alt on the second key means the same.")

(defvar nemesis-around-map (nemesis--object-map nil)
  "Text objects with their surroundings, under `M-m a'.")

(defvar nemesis-inside-map (nemesis--object-map t)
  "Text objects without their surroundings, under `M-m i'.")

(defvar-keymap nemesis-match-map
  :doc "Brackets, pairs and text objects under `M-m'."
  "m" #'nemesis-match-bracket
  "a" (cons "around" nemesis-around-map)
  "i" (cons "inside" nemesis-inside-map)
  "s" #'surround-insert
  "d" #'nemesis-delete-pair
  "r" #'nemesis-change-pair)

(defvar-keymap nemesis-window-map
  :doc "Window keys under `C-w'."
  "n" #'nemesis-split-dwindle
  "s" #'split-window-below
  "v" #'split-window-right
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "H" #'windmove-swap-states-left
  "J" #'windmove-swap-states-down
  "K" #'windmove-swap-states-up
  "L" #'windmove-swap-states-right
  "o" #'delete-other-windows
  "q" #'delete-window)

(defvar-keymap nemesis-buffer-map
  :doc "Buffer keys under `C-b'."
  "TAB" #'next-buffer
  "<backtab>" #'previous-buffer
  "a" #'mode-line-other-buffer
  "b" #'switch-to-buffer
  "p" #'project-switch-to-buffer
  "n" #'find-file
  "S" #'scratch-buffer
  "q" #'kill-current-buffer)

(defvar-keymap nemesis-project-map
  :doc "File and project keys under `C-p'."
  "f" #'project-find-file
  "g" #'consult-ripgrep
  "p" #'project-switch-project
  "e" #'project-dired
  "s" #'project-eshell
  "w" #'write-file
  "z" #'revert-buffer-quick
  "c" #'nemesis-copy-file-path
  "d" #'nemesis-delete-this-file
  "k" #'project-kill-buffers)

(defvar-keymap nemesis-lsp-map
  :doc "Language server keys under `C-l'."
  "r" #'eglot-rename
  "a" #'eglot-code-actions
  "k" #'eldoc)

(defvar-keymap nemesis-map
  :doc "The nemesis layer.  Active through `emulation-mode-map-alists'."
  ;; Selection
  "M-v" #'nemesis-select-toggle
  "M-s" #'exchange-point-and-mark
  "M-V" #'nemesis-select-line
  "M-e" #'expreg-expand
  "M-E" #'expreg-contract
  "M-a" #'mark-whole-buffer
  "M-c" #'mc/mark-next-lines
  ;; Motions
  "M-h" #'backward-char
  "M-j" #'next-line
  "M-k" #'previous-line
  "M-l" #'forward-char
  "M-H" #'backward-word
  "M-L" #'forward-to-word
  "M-J" #'forward-paragraph
  "M-K" #'backward-paragraph
  "M-b" #'pop-to-mark-command
  "M-o" #'nemesis-open-below
  "M-O" #'nemesis-open-above
  "M-g" (cons "goto" nemesis-goto-map)
  "M-m" (cons "match" nemesis-match-map)
  ;; Search
  "M-f" #'isearch-forward-regexp
  "M-n" #'nemesis-search-next
  "M-N" #'nemesis-search-prev
  "M-F" #'nemesis-mc-all-matches
  ;; Actions
  "M-y" #'nemesis-copy
  "M-p" #'yank
  "M-P" #'consult-yank-pop
  "M-d" #'nemesis-cut
  "M-D" #'nemesis-delete
  "M-z" #'nemesis-undo
  "M-Z" #'undo-redo
  "M-C" #'comment-line
  "M-r" #'nemesis-replace-char
  "M-w" #'duplicate-dwim
  "M-t" #'nemesis-join
  "<backtab>" '(menu-item "" nemesis-dedent :filter nemesis--backtab-filter)
  ;; Around the text
  "C-w" (cons "window" nemesis-window-map)
  "C-b" (cons "buffer" nemesis-buffer-map)
  "C-p" (cons "project" nemesis-project-map)
  "C-l" (cons "lsp" nemesis-lsp-map)
  "C-q" #'nemesis-close
  "C-c q" #'quoted-insert
  "C-s" #'save-buffer
  "C-S-s" #'save-some-buffers)

(defconst nemesis--isearch-keys
  '(("M-n" . isearch-repeat-forward)
    ("M-N" . isearch-repeat-backward)
    ("M-F" . nemesis-mc-all-matches))
  "Bindings nemesis adds to `isearch-mode-map', which beats the layer.")

(provide 'nemesis-keys)
;;; nemesis-keys.el ends here
