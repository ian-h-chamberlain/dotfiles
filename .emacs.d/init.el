(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
  ;; and `package-pinned-packages`. Most users will not need or want to do this.
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosave/" t)))
 '(backup-by-copying t)
 '(backup-directory-alist '(("." . "~/.emacs.d/backup")))
 '(before-save-hook '(delete-trailing-whitespace))
 '(browse-url-browser-function 'browse-url-default-browser)
 '(delete-old-versions t)
 '(display-line-numbers-width-start t)
 '(evil-vsplit-window-right t)
 '(fill-column 88)
 '(global-display-line-numbers-mode t)
 '(hl-todo-color-background t)
 '(hl-todo-keyword-faces
   '(("TODO" . "#FFEB3B")
     ("NOTE" . "#FFEB3B")
     ("FIXME" . "#FFEB3B")))
 '(inhibit-startup-screen t)
 '(kept-new-versions 10)
 '(org-agenda-custom-commands
   '(("n" "Agenda and all TODOs"
      ((agenda "" nil)
       (alltodo "" nil))
      nil)
     ("w" "Weekend Agenda and TODOs" agenda ""
      ((org-agenda-overriding-header "WEEKEND")
       (org-agenda-span '2)
       (org-agenda-start-day "saturday")
       (org-read-date-prefer-future nil)))
     ("3" "3-day Agenda and TODOs" agenda ""
      ((org-agenda-overriding-header "3 DAY VIEW")
       (org-agenda-span '3)
       (org-agenda-start-day "today")))))
 '(org-agenda-files '("~/Documents/notes/"))
 '(org-agenda-restore-windows-after-quit t)
 '(org-agenda-todo-list-sublevels t)
 '(org-agenda-window-setup 'current-window)
 '(org-indirect-buffer-display 'current-window)
 '(org-startup-indented t)
 '(org-todo-keywords '((sequence "TODO" "PROG" "DONE")))
 '(org-use-property-inheritance '("DEADLINE" "SCHEDULED"))
 '(package-selected-packages
   '(rust-mode org-mru-clock- org hl-todo evil-collection monokai-theme evil-org evil ##))
 '(require-final-newline t)
 '(show-paren-mode t)
 '(split-height-threshold nil)
 '(version-control t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ================================================================================
;; User Configuration
;; ================================================================================

;; ----------------------------------------------------------------------
;; Package/Theme configuration
;; ----------------------------------------------------------------------
;; Directory for non-package (require) calls
(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'evil)
(evil-mode 1)

;; TODO: evil-collection bindings for customize-mode
;; (when (require 'evil-collection nil t)
;;   (evil-collection-init))

(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar))

(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(require 'evil-adjust)
(evil-adjust)

(load-theme 'monokai t)

(global-hl-todo-mode)

;; ----------------------------------------------------------------------
;; Custom functions and evil-mode commands
;; ----------------------------------------------------------------------
(evil-define-command evil-quit-buffer-or-window (&optional force)
  "Close the current buffer, displaying that buffer. If it is the last
   open buffer, "
  :repeat nil
  (interactive "<!>")
  (setq curbuf (current-buffer))
  (setq curwindow (get-buffer-window curbuf))

  ;; TODO rework this a bit
  (if (eq curwindow (next-window nil nil "visible"))
      (bury-buffer)
    (delete-window)
    (unless (get-buffer-window curbuf) (bury-buffer curbuf))))

(evil-define-command evil-save-and-quit-buffer-or-window (file &optional force)
  "Save the current buffer and close it, closing the window if that was the
   last buffer in the window."
  ;; parts taken from evil-commands.el: 'evil-save-and-close
  :repeat nil
  (interactive "<f><!>")
  (evil-write nil nil nil file force)
  (evil-quit-buffer-or-window))

(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
   In Delete Selection mode, if the mark is active, just deactivate it;
   then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

(defun go-to-definition-or-open-link (event)
  "Find the definition of the identifier at point, or attempt to open a file
   or hyperlink if no definitions were found."
  (interactive "e")
  ;; move point like normal mouse click
  (save-mark-and-excursion
    (mouse-set-point event)
    (let* ((url-str (thing-at-point 'url t))
           (parsed-url (url-generic-parse-url url-str)))
      (if (and
           (url-type parsed-url)
           (url-host parsed-url))
          (browse-url url-str)
        ;; If not a valid URL (no proto+hostname), then try to find definitions
        ;; taken from xref--read-identifier
        (let* ((xref-backend (xref-find-backend))
               (identifier (xref-backend-identifier-at-point xref-backend)))
          (xref-find-definitions identifier))))))

;; ----------------------------------------------------------------------
;; Key bindings
;; ----------------------------------------------------------------------
(global-set-key (kbd "s-c") 'evil-yank)

;; TODO figure out commenting keybinds
(global-set-key (kbd "s-/") 'comment-line)

(global-set-key (kbd "C-c a") 'org-agenda)
;; TODO: keybind for org-mode directory?
;; (global-set-key (kbd "???") '???)

(global-set-key (kbd "s-\\") 'evil-window-vsplit)
(global-set-key (kbd "s-|") 'evil-window-split)

(global-set-key (kbd "<s-mouse-1>") 'go-to-definition-or-open-link)

;; window movement
(global-set-key (kbd "<M-s-right>") 'windmove-right)
(global-set-key (kbd "<M-s-left>") 'windmove-left)
(global-set-key (kbd "<M-s-down>") 'windmove-down)
(global-set-key (kbd "<M-s-up>") 'windmove-up)

;; ----------------------------------------------------------------------
;; Startup configuration
;; ----------------------------------------------------------------------
(setq-default indent-tabs-mode nil)

(desktop-save-mode 1)
(setq-default desktop-save t)

(global-display-line-numbers-mode)

;; Allow using mouse to resize split windows
(window-divider-mode)

;; TODO: handle "qa" better than currently (basically, it should kill
;; all buffers and open the scratch buffer)

;; Make `:q` not kill the entire process
(evil-ex-define-cmd "q" 'evil-quit-buffer-or-window)

;; Make `:wq` not kill the entire process
(evil-ex-define-cmd "wq" 'evil-save-and-quit-buffer-or-window)

;; Typing out `:quit` will still quit emacs
(evil-ex-define-cmd "quit" 'evil-quit)

;; Make <esc> quit from minibuffer, etc.
(define-key evil-normal-state-map [escape] 'keyboard-quit)

(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
