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
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  )

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
 '(fill-column 88)
 '(org-todo-keywords (quote ((sequence "TODO" "PROG" "DONE"))))
 '(package-selected-packages
   (quote
    (hl-todo evil-collection monokai-theme evil-org evil ##)))
 '(split-height-threshold nil))
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
(require 'evil)
(evil-mode 1)

;; TODO: bindings for customize-mode

;; (when (require 'evil-collection nil t)
;;   (evil-collection-init))

(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar))

(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(load-theme 'monokai t)

(global-hl-todo-mode)
(setq hl-todo-color-background t)
(setq hl-todo-keyword-faces
      '(("TODO"   . "#FFEB3B")
        ("NOTE"   . "#FFEB3B")
        ("FIXME"  . "#FFEB3B")))

;; ----------------------------------------------------------------------
;; Custom functions
;; ----------------------------------------------------------------------
(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))


;; ----------------------------------------------------------------------
;; Startup configuration
;; ----------------------------------------------------------------------
(global-display-line-numbers-mode)

(setq default-frame-alist
      '((width . 0.5) (height . 1.0)))

;; Make `:q` not kill the entier process
;; TODO: open scratch buffer if this is the "sole remaining window"
;; Also make `:wq` do the same thing
(evil-ex-define-cmd "q" 'kill-buffer-and-window)

;; Typing out `:quit` will still quit emacs
(evil-ex-define-cmd "quit" 'evil-quit)

;; Start with a scratch buffer
(setq inhibit-startup-screen t)
