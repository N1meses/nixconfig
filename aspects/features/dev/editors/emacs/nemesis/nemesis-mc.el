;;; nemesis-mc.el --- Multiple cursors for nemesis  -*- lexical-binding: t; -*-

;;; Commentary:
;; Every match becomes a cursor, and the multiple-cursors whitelists for
;; nemesis commands.  Without a whitelist entry mc asks once per command
;; and stores the answer in `mc/list-file'.  The entries go into mc's
;; default lists because loading `mc/list-file' overwrites the user lists.

;;; Code:

(require 'multiple-cursors-core)

(defun nemesis--mc-read-regexp ()
  "Return the regexp for `nemesis-mc-all-matches'.
During a search, its string, and the search ends.  Otherwise ask, with
the last search as default."
  (if isearch-mode
      (let ((re (if isearch-regexp isearch-string (regexp-quote isearch-string))))
        (isearch-done t)
        (isearch-clean-overlays)
        re)
    (read-regexp "Cursors on: " (car regexp-search-ring))))

(defun nemesis-mc-all-matches (regexp)
  "Put a cursor on every match of REGEXP, each match selected.
Searches the selection, or the whole buffer without one."
  (interactive (list (nemesis--mc-read-regexp)))
  (let ((beg (if (use-region-p) (region-beginning) (point-min)))
        (end (if (use-region-p) (region-end) (point-max)))
        matches)
    (save-excursion
      (goto-char beg)
      (while (and (< (point) end) (re-search-forward regexp end t))
        (push (cons (match-beginning 0) (match-end 0)) matches)
        (when (= (match-beginning 0) (match-end 0))
          (forward-char))))
    (unless matches
      (user-error "No match for %s" regexp))
    (setq matches (nreverse matches))
    (mc/remove-fake-cursors)
    (dolist (m (cdr matches))
      (goto-char (cdr m))
      (set-mark (car m))
      (mc/create-fake-cursor-at-point))
    (goto-char (cdar matches))
    (push-mark (caar matches) t t)
    (when (cdr matches)
      (multiple-cursors-mode 1))))

(defconst nemesis--mc-run-for-all
  '(nemesis-select-toggle nemesis-select-line nemesis-copy nemesis-cut
    nemesis-delete nemesis-replace-char nemesis-join nemesis-dedent
    nemesis-open-below nemesis-open-above nemesis-match-bracket
    nemesis-delete-pair nemesis-change-pair nemesis-next-defun
    forward-to-word backward-paragraph beginning-of-line end-of-line
    back-to-indentation beginning-of-defun exchange-point-and-mark
    yank comment-line duplicate-dwim surround-insert indent-for-tab-command)
  "Commands every cursor runs.")

(defconst nemesis--mc-run-once
  '(nemesis-undo undo-redo nemesis-mc-all-matches nemesis-search-next
    nemesis-search-prev nemesis-goto-line-live nemesis-window-top
    nemesis-window-middle nemesis-window-bottom nemesis-close
    nemesis-split-dwindle nemesis-copy-file-path nemesis-delete-this-file
    mark-whole-buffer pop-to-mark-command scroll-up-command scroll-down-command
    beginning-of-buffer end-of-buffer save-buffer save-some-buffers)
  "Commands only the real cursor runs.")

(dolist (cmd nemesis--mc-run-for-all)
  (add-to-list 'mc--default-cmds-to-run-for-all cmd))
(dolist (cmd nemesis--mc-run-once)
  (add-to-list 'mc--default-cmds-to-run-once cmd))

(provide 'nemesis-mc)
;;; nemesis-mc.el ends here
