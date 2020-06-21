;;; evil-adjust.el --- Adjustments for evil-mode.

;; Copyright (C) 2016 Troy Pracy

;; Author: Troy Pracy
;; Keywords: evil
;; Version: 0.2

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package compensates for annoying off-by-one incompatibilities between
;; `evil-normal-state' and lisp modes.

;; When using `lisp-interaction-mode' in `evil-normal-state', one cannot use
;; C-x C-j (`eval-print-last-sexp') on the last character of a sexp, since
;; Emacs thinks the cursor is one space back.

;; With Emacs 25, a similar issue occurs additionally in both `emacs-lisp-mode'
;; and lisp-interaction-mode when using C-x C-e (`eval-last-sexp').
;; This package adjusts for these issues by remapping the affected functions to
;; evil-adjust wrappers.

;; Installation:
;;   (require 'evil-adjust)
;;   (evil-adjust)

;;; Code:

  (defun evil-adjust-eval-print-last-sexp (&optional arg)
    "Evaluate the sexp before point and print it on a new line.

This function is a wrapper around `eval-print-last-sexp' which corrects for
cursor position in normal/visual states when `evil-move-cursor-back' is set to
`t' (as by default).

Long output is truncated. See the variables `eval-expression-print-length' and
`eval-expression-print-level'.
A prefix argument of 0 inhibits truncation and prints integers with additional
octal, hexadecimal and character representations, in the format: 1 (#o1, #x1,
?\C-a).

Errors start the debugger unless an argument of `nil' is passed for
`eval-expression-debug-on-error'."
    (interactive "P")
    (cl-case evil-state
      ('normal (progn
                 (evil-append 1)
                 (eval-print-last-sexp arg)
                 (evil-normal-state)
                 ))
      ('visual (progn
                 (evil-append 1)
                 (eval-print-last-sexp arg)
                 (evil-visual-restore)
                 ))
      (otherwise (eval-print-last-sexp arg))
      ))

  (defun evil-adjust-eval-last-sexp (&optional arg)
    "Evaluate the sexp before point and print it in the echo area.

This function is a wrapper around `eval-last-sexp' which corrects for cursor
position in normal/visual states when `evil-move-cursor-back' is set to `t'
(as by default).

Long output is truncated. See the variables `eval-expression-print-length' and
`eval-expression-print-level'.
A prefix argument of 0 inhibits truncation and prints integers with additional
octal, hexadecimal and character representations, in the format: 1 (#o1, #x1,
?\C-a).

Errors start the debugger unless an argument of `nil' is passed for
`eval-expression-debug-on-error'."
    (interactive "P")
    (cl-case evil-state
      ('normal (progn
                 (evil-append 1)
                 (eval-last-sexp arg)
                 (evil-normal-state)
                 ))
      ('visual (progn
                 (evil-append 1)
                 (eval-last-sexp arg)
                 (evil-visual-restore)
                 ))
      (otherwise (eval-last-sexp arg))
      ))

(defun evil-adjust-emacs25-p ()
  (return (= 25 (truncate (string-to-number emacs-version)))))

(defun evil-adjust (&rest options)
  "Initialize evil adjustments.

Remaps `eval-print-last-sexp' to `evil-adjust-eval-print-last-sexp'.
In Emacs 25, additionally remaps `eval-last-sexp' to `evil-adjust-eval-last-sexp'.
The options `:noevalprintfix' and `:noemacs25fix' inhibit specific adjustments.

This function must be called after the variable `evil-move-cursor-back' is set."
  (interactive)
  (when (and evil-move-cursor-back
             (not (member :noevalprintfix options)))
    (define-key lisp-interaction-mode-map
      [remap eval-print-last-sexp]
      'evil-adjust-eval-print-last-sexp))

  (when (and (= 25 (truncate (string-to-number emacs-version)))
             evil-move-cursor-back
             (not (member :noemacs25fix options)))
    (define-key emacs-lisp-mode-map
      [remap eval-last-sexp]
      'evil-adjust-eval-last-sexp)
    (define-key lisp-interaction-mode-map
      [remap eval-last-sexp]
      'evil-adjust-eval-last-sexp)))

(provide 'evil-adjust)

;;; evil-adjust.el ends here
