;;; nemesis-objects.el --- Text objects and pairs for nemesis  -*- lexical-binding: t; -*-

;;; Commentary:
;; `M-m': select around / inside objects, delete and replace pairs, jump
;; to the matching bracket.  Pairs are found with the syntax table, so
;; brackets inside strings and comments don't count (unlike surround.el).
;; Characters that are neither brackets nor string quotes in the current
;; mode fall back to a plain search on the current line.

;;; Code:

(require 'thingatpt)
(require 'nemesis-treesit)

(defconst nemesis--pairs
  '((?\( . ?\)) (?\[ . ?\]) (?{ . ?}) (?< . ?>))
  "Asymmetric pairs; every other character pairs with itself.")

(defun nemesis--open-char (char)
  "Return the opening character of the pair CHAR belongs to."
  (or (car (rassq char nemesis--pairs)) char))

(defun nemesis--close-char (char)
  "Return the closing character of the pair CHAR belongs to."
  (or (cdr (assq (nemesis--open-char char) nemesis--pairs)) char))

(defun nemesis--sexp-bounds (beg)
  "Return (BEG . END) of the bracket pair or string starting at BEG, or nil."
  (when beg
    (let ((end (ignore-errors (scan-sexps beg 1))))
      (and end (cons beg end)))))

(defun nemesis--bracket-bounds (open)
  "Return the bounds of the innermost OPEN bracket pair around point."
  (let ((ppss (syntax-ppss)))
    (nemesis--sexp-bounds
     (if (and (not (nth 8 ppss)) (eq (char-after) open))
         (point)
       (seq-find (lambda (pos) (eq (char-after pos) open))
                 (reverse (nth 9 ppss)))))))

(defun nemesis--string-bounds (quote)
  "Return the bounds of the string delimited by QUOTE around point."
  (let ((ppss (syntax-ppss)))
    (nemesis--sexp-bounds
     (cond ((and (nth 3 ppss) (eq (char-after (nth 8 ppss)) quote))
            (nth 8 ppss))
           ((and (not (nth 8 ppss)) (eq (char-after) quote))
            (point))))))

(defun nemesis--line-pair-bounds (open close)
  "Return the bounds of OPEN ... CLOSE around point on this line.
Plain text search, no syntax and no nesting."
  (let ((pt (point))
        (bol (line-beginning-position))
        (eol (line-end-position)))
    (save-excursion
      (if (eq open close)
          (let (found)
            (goto-char bol)
            (while (and (not found) (search-forward (string open) eol t))
              (let ((beg (1- (point))))
                (when (and (search-forward (string close) eol t)
                           (<= beg pt) (< pt (point)))
                  (setq found (cons beg (point))))))
            found)
        (goto-char (min (1+ pt) eol))
        (when (search-backward (string open) bol t)
          (let ((beg (point)))
            (and (search-forward (string close) eol t)
                 (< pt (point))
                 (cons beg (point)))))))))

(defun nemesis--pair-bounds (char)
  "Return the bounds of the pair CHAR (opening or closing) around point."
  (let ((open (nemesis--open-char char)))
    (pcase (char-syntax open)
      (?\( (nemesis--bracket-bounds open))
      (?\" (nemesis--string-bounds open))
      (_ (nemesis--line-pair-bounds open (nemesis--close-char open))))))

(defun nemesis--nearest-pair-bounds ()
  "Return the bounds of the nearest bracket pair or string around point."
  (let* ((ppss (syntax-ppss))
         (here (and (not (nth 8 ppss))
                    (memq (char-syntax (or (char-after) ?\s)) '(?\( ?\"))
                    (point)))
         (starts (delq nil (list (car (last (nth 9 ppss)))
                                 (and (nth 3 ppss) (nth 8 ppss))))))
    (nemesis--sexp-bounds (or here (and starts (apply #'max starts))))))

(defun nemesis--inner (bounds)
  "Return BOUNDS without their first and last character."
  (and bounds (cons (1+ (car bounds)) (1- (cdr bounds)))))

;;;; Objects

(defun nemesis--thing-bounds (thing inner)
  "Return the bounds of THING at point; unless INNER, with trailing blanks."
  (let ((b (bounds-of-thing-at-point thing)))
    (if (or inner (null b))
        b
      (save-excursion
        (goto-char (cdr b))
        (skip-chars-forward " \t")
        (cons (car b) (point))))))

(defun nemesis--line-bounds (inner)
  "Return the bounds of the current line; unless INNER, with its newline."
  (cons (line-beginning-position)
        (if inner
            (line-end-position)
          (min (point-max) (1+ (line-end-position))))))

(defun nemesis--paragraph-bounds (inner)
  "Return the bounds of the paragraph; unless INNER, with following blank lines."
  (let ((b (bounds-of-thing-at-point 'paragraph)))
    (when b
      (save-excursion
        (let ((beg (progn (goto-char (car b))
                          (skip-chars-forward " \t\n")
                          (line-beginning-position)))
              (end (progn (goto-char (cdr b))
                          (skip-chars-backward " \t\n")
                          (point))))
          (if inner
              (cons beg end)
            (skip-chars-forward " \t\n")
            (cons beg (if (eobp) (point) (line-beginning-position)))))))))

(defun nemesis--comment-start ()
  "Return the start of the comment at or after point on this line, or nil."
  (let ((ppss (syntax-ppss)))
    (if (nth 4 ppss)
        (nth 8 ppss)
      (save-excursion
        (let ((eol (line-end-position)))
          (skip-chars-forward " \t")
          (when (and (< (point) eol) (forward-comment 1))
            (nth 8 (syntax-ppss (1- (point))))))))))

(defun nemesis--comment-bounds (inner)
  "Return the bounds of the comment at point.
Directly following line comments belong to it.  INNER leaves out the
first comment starter."
  (let ((beg (nemesis--comment-start)))
    (when beg
      (save-excursion
        (goto-char beg)
        (forward-comment 1)
        (let ((end (point)))
          (while (and (bolp)
                      (progn (skip-chars-forward " \t") (not (eolp)))
                      (forward-comment 1))
            (setq end (point)))
          (goto-char end)
          (skip-chars-backward " \t\n")
          (setq end (point))
          (goto-char beg)
          (when (and inner comment-start-skip (looking-at comment-start-skip))
            (goto-char (match-end 0)))
          (cons (point) end))))))

(defun nemesis--object-bounds (object inner)
  "Return the bounds of OBJECT at point, its inside when INNER.
OBJECT is a symbol or a pair character."
  (pcase object
    ('word (nemesis--thing-bounds 'word inner))
    ('symbol (nemesis--thing-bounds 'symbol inner))
    ('line (nemesis--line-bounds inner))
    ('paragraph (nemesis--paragraph-bounds inner))
    ('function (nemesis-function-bounds inner))
    ('type (nemesis-type-bounds inner))
    ('comment (nemesis--comment-bounds inner))
    ('pair (let ((b (nemesis--nearest-pair-bounds)))
             (if inner (nemesis--inner b) b)))
    ((pred characterp) (let ((b (nemesis--pair-bounds object)))
                         (if inner (nemesis--inner b) b)))))

(defun nemesis--select (bounds)
  "Select BOUNDS, point at the end."
  (unless bounds
    (user-error "No such object at point"))
  (push-mark (car bounds) t t)
  (goto-char (cdr bounds)))

(defun nemesis--object-command (object inner)
  "Return a command that selects OBJECT, its inside when INNER."
  (lambda ()
    (interactive)
    (nemesis--select (nemesis--object-bounds object inner))))

(defconst nemesis-objects
  '(("w" word "word") ("s" symbol "symbol") ("l" line "line")
    ("p" paragraph "paragraph") ("f" function "function") ("t" type "type")
    ("c" comment "comment") ("m" pair "nearest pair")
    ("(" ?\( "( )") (")" ?\( "( )") ("[" ?\[ "[ ]") ("]" ?\[ "[ ]")
    ("{" ?{ "{ }") ("}" ?{ "{ }") ("<" ?< "< >") (">" ?< "< >")
    ("\"" ?\" "\" \"") ("'" ?' "' '") ("`" ?` "` `"))
  "Text objects: (KEY OBJECT LABEL).")

(defun nemesis--object-map (inner)
  "Return a keymap selecting every object, their inside when INNER."
  (let ((map (make-sparse-keymap)))
    (pcase-dolist (`(,key ,object ,label) nemesis-objects)
      (keymap-set map key (cons label (nemesis--object-command object inner))))
    map))

;;;; Pairs

(defun nemesis-match-bracket ()
  "Jump between a bracket and its partner."
  (interactive)
  (pcase (char-syntax (or (char-after) ?\s))
    (?\( (goto-char (1- (scan-sexps (point) 1))))
    (?\) (goto-char (scan-sexps (1+ (point)) -1)))
    (_ (user-error "Not on a bracket"))))

(defun nemesis--pair-or-error (char)
  "Return the bounds of the pair CHAR around point, or signal an error."
  (or (nemesis--pair-bounds char)
      (user-error "No %c pair around point" char)))

(defun nemesis-delete-pair (char)
  "Delete the pair CHAR around point, keep its contents."
  (interactive (list (read-char "Delete pair: ")))
  (let ((b (nemesis--pair-or-error char)))
    (save-excursion
      (goto-char (1- (cdr b)))
      (delete-char 1)
      (goto-char (car b))
      (delete-char 1))))

(defun nemesis-change-pair (old new)
  "Replace the pair OLD around point with the pair NEW."
  (interactive
   (let ((old (read-char "Replace pair: ")))
     (list old (read-char (format "Replace %c with: " old)))))
  (let ((b (nemesis--pair-or-error old)))
    (save-excursion
      (goto-char (1- (cdr b)))
      (delete-char 1)
      (insert (nemesis--close-char new))
      (goto-char (car b))
      (delete-char 1)
      (insert (nemesis--open-char new)))))

(provide 'nemesis-objects)
;;; nemesis-objects.el ends here
