;;; nemesis-commands.el --- Small commands for nemesis  -*- lexical-binding: t; -*-

;;; Commentary:
;; Commands behind nemesis keys that have no exact built-in equivalent.
;; Without a selection, actions work on the character after point, like a
;; one-character selection in helix.

;;; Code:

;;;; Selection

(defun nemesis-select-toggle ()
  "Start a selection at point, or drop the active one.
Plain motions extend an active selection."
  (interactive)
  (if (region-active-p)
      (deactivate-mark)
    (push-mark nil t t)))

(defun nemesis-select-line (n)
  "Select the current line.
When whole lines are already selected, extend the selection by N lines."
  (interactive "p")
  (if (and (use-region-p) (bolp) (> (point) (mark))
           (save-excursion (goto-char (mark)) (bolp)))
      (forward-line n)
    (let ((beg (if (use-region-p) (region-beginning) (point)))
          (end (if (use-region-p) (region-end) (point))))
      (goto-char beg)
      (push-mark (line-beginning-position) t t)
      (goto-char end)
      (forward-line n))))

(defun nemesis--bounds ()
  "Return the selection as (BEG . END), or the character after point."
  (if (use-region-p)
      (cons (region-beginning) (region-end))
    (cons (point) (min (1+ (point)) (point-max)))))

;;;; Actions

(defun nemesis-copy ()
  "Copy the selection, or the character after point."
  (interactive)
  (let ((b (nemesis--bounds)))
    (kill-ring-save (car b) (cdr b))))

(defun nemesis-cut ()
  "Cut the selection, or the character after point."
  (interactive)
  (let ((b (nemesis--bounds)))
    (kill-region (car b) (cdr b))))

(defun nemesis-delete ()
  "Delete the selection, or the character after point, without copying."
  (interactive)
  (let ((b (nemesis--bounds)))
    (delete-region (car b) (cdr b))))

(defun nemesis-undo (&optional arg)
  "Undo ARG changes in the whole buffer, even while something is selected.
Plain `undo' would only undo inside the selection."
  (interactive "P")
  (deactivate-mark)
  (undo (and arg (prefix-numeric-value arg))))

(defun nemesis-replace-char (char)
  "Replace every character of the selection with CHAR; newlines stay.
Without a selection, replace the character after point."
  (interactive (list (read-char "Replace with: ")))
  (let* ((b (nemesis--bounds))
         (text (buffer-substring (car b) (cdr b)))
         (pt (point))
         (mk (and (use-region-p) (mark))))
    (goto-char (car b))
    (delete-region (car b) (cdr b))
    (insert (replace-regexp-in-string "[^\n]" (string char) text t t))
    (goto-char pt)
    (when mk
      (set-mark mk)
      (setq deactivate-mark nil))))

(defun nemesis-join ()
  "Join the next line onto this one, or all lines of the selection."
  (interactive)
  (if (use-region-p)
      (delete-indentation nil (region-beginning) (region-end))
    (delete-indentation t)))

(defun nemesis-dedent ()
  "Dedent the selected lines, or the current line, to the previous tab stop."
  (interactive)
  (if (use-region-p)
      (progn
        (indent-rigidly-left-to-tab-stop (region-beginning) (region-end))
        (setq deactivate-mark nil))
    (indent-rigidly-left-to-tab-stop (line-beginning-position)
                                     (line-end-position))))

(defun nemesis-open-below ()
  "Open a new indented line below the current one."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defconst nemesis--tty-esc-o-keys
  '((?A . up) (?B . down) (?C . right) (?D . left) (?H . home) (?F . end)
    (?P . f1) (?Q . f2) (?R . f3) (?S . f4))
  "Keys a terminal sends as ESC O <char>, which Emacs reads as M-O <char>.")

(defun nemesis--tty-esc-o-key ()
  "Return the terminal key this M-O starts, or nil for a real M-O.
The rest of an escape sequence is already waiting; a typed M-O is not."
  (unless (display-graphic-p)
    (let ((next (read-event nil nil 0.01)))
      (or (alist-get next nemesis--tty-esc-o-keys)
          (progn (when next (push next unread-command-events))
                 nil)))))

(defvar mc--executing-command-for-fake-cursor)

(defvar nemesis--esc-o-key nil
  "What the real cursor's last `nemesis-open-above' decoded, for fake cursors.")

(defun nemesis-open-above ()
  "Open a new indented line above the current one.
In a terminal, an arrow, Home/End or F1-F4 key that arrives as ESC O
<char> runs as that key instead."
  (interactive)
  (let* ((fake (bound-and-true-p mc--executing-command-for-fake-cursor))
         (key (if fake
                  nemesis--esc-o-key
                (setq nemesis--esc-o-key (nemesis--tty-esc-o-key)))))
    (cond ((null key)
           (beginning-of-line)
           (open-line 1)
           (indent-according-to-mode))
          ((not fake)
           (push key unread-command-events)))))

;;;; Goto

(defun nemesis-next-defun ()
  "Move to the start of the next function."
  (interactive)
  (beginning-of-defun -1))

(defun nemesis-window-top ()
  "Move point to the top line of the window."
  (interactive)
  (move-to-window-line 0))

(defun nemesis-window-middle ()
  "Move point to the middle line of the window."
  (interactive)
  (move-to-window-line nil))

(defun nemesis-window-bottom ()
  "Move point to the bottom line of the window."
  (interactive)
  (move-to-window-line -1))

(defun nemesis--digit (event)
  "Return the digit of EVENT if it is 0-9, with or without Alt, else nil."
  (let ((base (event-basic-type event)))
    (and (integerp base)
         (<= ?0 base ?9)
         (seq-every-p (lambda (m) (eq m 'meta)) (event-modifiers event))
         (- base ?0))))

(defun nemesis--goto-line (line)
  "Move to the start of LINE."
  (goto-char (point-min))
  (forward-line (1- (max line 1))))

(defun nemesis--read-keys (prompt)
  "Read one key sequence with PROMPT and return its events as a list.
Terminals send Alt+key as ESC key, which comes back as one Alt event."
  (let ((keys (read-key-sequence-vector prompt)))
    (if (and (= (length keys) 2) (eq (aref keys 0) ?\e) (integerp (aref keys 1)))
        (list (event-apply-modifier (aref keys 1) 'meta 27 "M-"))
      (append keys nil))))

(defun nemesis-goto-line-live ()
  "Go to a line by number, jumping on every digit typed.
The number starts with the digit of the key that ran this command.
More digits (with or without Alt) extend it, DEL removes the last one,
RET ends.  Any other key ends and then runs as usual."
  (interactive)
  (let ((line (or (nemesis--digit last-command-event) 0))
        done)
    (unless (use-region-p)
      (push-mark nil t))
    (while (not done)
      (nemesis--goto-line line)
      (let* ((keys (nemesis--read-keys (format "Line: %d" line)))
             (key (and (null (cdr keys)) (car keys)))
             (digit (and key (nemesis--digit key))))
        (cond (digit (setq line (+ (* line 10) digit)))
              ((memq key '(?\d backspace)) (setq line (/ line 10)))
              ((memq key '(?\r return)) (setq done t))
              (t (setq unread-command-events (append keys unread-command-events))
                 (setq done t)))))))

;;;; Search

(defun nemesis--select-match ()
  "Select the last match, point at its end."
  (goto-char (match-end 0))
  (push-mark (match-beginning 0) t t))

(defun nemesis--search (forward)
  "Select the next match of the last search, wrapping around.
Search forward when FORWARD is non-nil, else backward."
  (let ((re (or (car regexp-search-ring) (user-error "No previous search")))
        (from (cond ((not (use-region-p)) (point))
                    (forward (region-end))
                    (t (region-beginning))))
        (search (if forward #'re-search-forward #'re-search-backward)))
    (unless (save-excursion
              (goto-char from)
              (or (funcall search re nil t)
                  (progn
                    (goto-char (if forward (point-min) (point-max)))
                    (when (funcall search re nil t)
                      (message "Search wrapped")
                      t))))
      (user-error "No match for %s" re))
    (nemesis--select-match)))

(defun nemesis-search-next ()
  "Select the next match of the last search."
  (interactive)
  (nemesis--search t))

(defun nemesis-search-prev ()
  "Select the previous match of the last search."
  (interactive)
  (nemesis--search nil))

(defun nemesis--isearch-select ()
  "Select the match when a search ends; for `isearch-mode-end-hook'.
The search start goes on the mark ring first, so `pop-to-mark-command'
returns there."
  (when (and (not isearch-mode-end-hook-quit)
             isearch-other-end
             (/= (point) isearch-opoint))
    (push-mark isearch-opoint t)
    (push-mark isearch-other-end t t)))

;;;; Windows, buffers, files

(defun nemesis-close ()
  "Close what is in front.
Special buffers (help etc.) quit; the last window kills its buffer;
otherwise the window closes and its buffer stays."
  (interactive)
  (cond ((derived-mode-p 'special-mode) (quit-window))
        ((one-window-p) (kill-current-buffer))
        (t (delete-window))))

(defun nemesis-split-dwindle ()
  "Split along the longer side of the window, then find a file there."
  (interactive)
  (select-window (if (> (window-pixel-width) (window-pixel-height))
                     (split-window-right)
                   (split-window-below)))
  (call-interactively #'find-file))

(defun nemesis--file ()
  "Return the file of the current buffer, or signal an error."
  (or buffer-file-name
      (user-error "Buffer %s has no file" (buffer-name))))

(defun nemesis-copy-file-path ()
  "Copy the full path of the current file."
  (interactive)
  (let ((file (nemesis--file)))
    (kill-new file)
    (message "Copied %s" file)))

(defun nemesis-delete-this-file ()
  "Delete the current file after asking, then kill its buffer."
  (interactive)
  (let ((file (nemesis--file)))
    (when (yes-or-no-p (format "Delete %s? " file))
      (delete-file file)
      (set-buffer-modified-p nil)
      (kill-current-buffer)
      (message "Deleted %s" file))))

;;;; Fallback keys

(defun nemesis--unless-local (key cmd)
  "Return CMD, or nil when the buffer's own keymaps bind KEY.
Used as a menu-item filter, so KEY falls through to the major mode."
  (let ((local (current-local-map))
        (prop (get-char-property (point) 'keymap)))
    (unless (or (and local (keymap-lookup local key))
                (and prop (keymap-lookup prop key)))
      cmd)))

(defun nemesis--backtab-filter (cmd)
  "Menu-item filter for <backtab>: CMD unless the mode has its own."
  (nemesis--unless-local "<backtab>" cmd))

(provide 'nemesis-commands)
;;; nemesis-commands.el ends here
