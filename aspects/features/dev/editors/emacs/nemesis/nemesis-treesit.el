;;; nemesis-treesit.el --- Tree-sitter objects for nemesis  -*- lexical-binding: t; -*-

;;; Commentary:
;; The `f' (function) and `t' (type) text objects.  With a tree-sitter
;; parser they climb the syntax tree; `f' falls back to the defun commands.
;; Node types measured with the Emacs 31.1 grammars.

;;; Code:

(require 'treesit)

(defcustom nemesis-function-node-regexp
  (rx bos (or "function_definition" "function_item" "function_declaration"
              "method_definition" "binding")
      eos)
  "Tree-sitter node types the `f' object selects.
`binding' is a nix attribute: nix has no functions with names."
  :type 'regexp
  :group 'nemesis)

(defcustom nemesis-type-node-regexp
  (rx bos (or "class_definition" "struct_item" "impl_item" "enum_item"
              "trait_item" "attrset_expression")
      eos)
  "Tree-sitter node types the `t' object selects."
  :type 'regexp
  :group 'nemesis)

(defun nemesis--treesit-node (regexp)
  "Return the innermost node around point whose type matches REGEXP."
  (when (and (treesit-available-p) (treesit-parser-list))
    (treesit-parent-until
     (treesit-node-at (point))
     (lambda (node) (string-match-p regexp (treesit-node-type node)))
     t)))

(defun nemesis--treesit-bounds (node inner)
  "Return (BEG . END) of NODE, or of its body when INNER.
The body is the `body' or `expression' field; braces around it and
the whitespace inside them are left out."
  (let* ((body (if inner
                   (or (treesit-node-child-by-field-name node "body")
                       (treesit-node-child-by-field-name node "expression")
                       node)
                 node))
         (beg (treesit-node-start body))
         (end (treesit-node-end body)))
    (if (and inner (eq (char-after beg) ?{) (eq (char-before end) ?}))
        (save-excursion
          (goto-char (1+ beg))
          (skip-chars-forward " \t\n")
          (setq beg (point))
          (goto-char (1- end))
          (skip-chars-backward " \t\n")
          (cons beg (max beg (point))))
      (cons beg end))))

(defun nemesis-function-bounds (inner)
  "Return the bounds of the function at point, its body when INNER."
  (let ((node (nemesis--treesit-node nemesis-function-node-regexp)))
    (if node
        (nemesis--treesit-bounds node inner)
      (save-excursion
        (let* ((end (progn (end-of-defun) (skip-chars-backward " \t\n") (point)))
               (beg (progn (beginning-of-defun) (point))))
          (if (and inner (eq (char-syntax (char-after beg)) ?\())
              (cons (1+ beg) (1- (scan-sexps beg 1)))
            (cons beg end)))))))

(defun nemesis-type-bounds (inner)
  "Return the bounds of the class/struct/... at point, its body when INNER."
  (let ((node (or (nemesis--treesit-node nemesis-type-node-regexp)
                  (user-error "No type at point (needs a tree-sitter mode)"))))
    (nemesis--treesit-bounds node inner)))

(provide 'nemesis-treesit)
;;; nemesis-treesit.el ends here
