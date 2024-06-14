;; To bootstrap / reload packages after deleting elpa directory:
;;  1. M-x package-refresh-contents
;;  2. M-x package-install-selected-packages
;;  3. Restart emacs

(require 'package)

;; This is added before everything else so that the benchmarking
;; includes all the customize / initialization logic.
(if (require 'benchmark-init nil 'noerror)
    (progn
      ;; Comment out to profile on init startup:
      (benchmark-init/deactivate)
      (add-hook 'after-init-hook 'benchmark-init/deactivate)))


(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t))
  ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
  ;; and `package-pinned-packages`. Most users will not need or want to do this.
  ;; (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t))

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
 '(alert-fade-time 5)
 '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosave/" t)))
 '(backup-by-copying t)
 '(backup-directory-alist '(("." . "~/.emacs.d/backup")))
 '(before-save-hook '(delete-trailing-whitespace))
 '(browse-url-browser-function 'browse-url-default-browser)
 '(delete-old-versions t)
 '(desktop-path '("~/.emacs.d/"))
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width-start t)
 '(evil-undo-system 'undo-redo)
 '(evil-vsplit-window-right t)
 '(evil-want-keybinding nil)
 '(fill-column 88)
 '(global-display-line-numbers-mode t)
 '(global-orglink-mode t)
 '(gnutls-algorithm-priority "normal:-vers-tls1.3")
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
     ("b" "TODO tree for this buffer" todo-tree "" nil)
     ("l" "TOOD list for this buffer" org-todo-list-current-file "" nil)))
 '(org-agenda-files '("~/Documents/notes/sabbatical" "~/Documents/notes/"))
 '(org-agenda-restore-windows-after-quit t)
 '(org-agenda-todo-list-sublevels t)
 '(org-agenda-window-setup 'current-window)
 '(org-ascii-bullets '((ascii 42) (latin1 167) (utf-8 8226)))
 '(org-ascii-headline-spacing '(0 . 0))
 '(org-export-headline-levels 0)
 '(org-export-with-author nil)
 '(org-export-with-date nil)
 '(org-export-with-section-numbers nil)
 '(org-export-with-title nil)
 '(org-export-with-toc nil)
 '(org-export-with-todo-keywords nil)
 '(org-fontify-done-headline nil)
 '(org-format-latex-options
   '(:foreground default :background default :scale 1.5 :html-foreground "Black" :html-background "Transparent" :html-scale 1.5 :matchers
                 ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(org-image-actual-width nil)
 '(org-indirect-buffer-display 'current-window)
 '(org-notifications-play-sounds nil)
 '(org-notifications-style 'libnotify)
 '(org-notifications-title "Agenda Reminder")
 '(org-preview-latex-default-process 'dvipng)
 '(org-priority-default 68)
 '(org-priority-lowest 68)
 '(org-startup-indented t)
 '(org-startup-with-inline-images t)
 '(org-startup-with-latex-preview t)
 '(org-todo-keywords '((sequence "TODO" "PROG" "|" "DONE" "WONTDO")))
 '(org-use-property-inheritance '("DEADLINE" "SCHEDULED"))
 '(org-wild-notifier-keyword-whitelist nil)
 '(package-selected-packages
   '(ox-slack org-notifications org-ql dash alert orglink ox-gfm go-mode yaml-mode rust-mode hl-todo evil-collection monokai-theme evil-org evil))
 '(require-final-newline t)
 '(select-enable-clipboard nil)
 '(show-paren-mode t)
 '(split-height-threshold nil)
 '(tool-bar-mode nil)
 '(tool-bar-style 'both-horiz)
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



;; For macOS, we can use builtin Apple emoji to render unicode nicely
(when (member "Apple Color Emoji" (font-family-list))
  (set-fontset-font
   t 'symbol (font-spec :family "Apple Color Emoji") nil 'prepend))

(require 'evil)
(evil-mode 1)

(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)

(require 'evil-collection)
;; instead of customizing the huge list just remove stuff we don't want
(setq evil-collection-mode-list (remove '(custom cus-edit) evil-collection--supported-modes))
(evil-collection-init)

(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(require 'evil-adjust)
(evil-adjust)

(load-theme 'monokai t)

(global-hl-todo-mode)

;; GPG encryption
(require 'epa-file)
(epa-file-enable)

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

(evil-define-operator evil-yank-to-clipboard (beg end type _ yank-handler)
  "Yank region to system clipboard."
  :repeat nil
  :move-point nil
  (interactive "<R><x><y>")
  (evil-use-register ?+)
  (evil-yank beg end type ?+ yank-handler))

(evil-define-command evil-paste-from-clipboard ()
  "Paste system clipboard to buffer."
  (interactive)
  (evil-paste-from-register ?+))

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

(defun slide-buffer (dir)
  "Move current buffer into window at direction DIR,
   creating if it does not exist."
  (require 'windmove)
  (let ((buffer (current-buffer))
        (other-window (windmove-find-other-window dir)))
    (when (or (null other-window)
              (and (window-minibuffer-p other-window)
                   (not (minibuffer-window-active-p other-window))))
      (setq other-window (split-window nil nil dir)))
    (if (null other-window)
        (user-error "No window %s from selected window" dir))
      (switch-to-prev-buffer)
      (select-window other-window)
      (switch-to-buffer buffer nil t)))

(defun slide-buffer-up () (interactive) (slide-buffer 'up))
(defun slide-buffer-down () (interactive) (slide-buffer 'down))
(defun slide-buffer-left () (interactive) (slide-buffer 'left))
(defun slide-buffer-right () (interactive) (slide-buffer 'right))

;; rebuild all open agenda buffers
(defun org-agenda-redo-all()
  (interactive)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-agenda-mode)
        ;; TBD: maybe-redo vs redo. maybe-redo seemed to work before
        ;; but now it seems like redo is working better
        (org-agenda-redo)))))

(defun org-agenda-redo-save-hook()
    ;; same as above, but only if current mode is org-mode
    (when (eq major-mode 'org-mode)
      (org-agenda-redo-all)
      ;; re-evaluate notifications after updating agenda
      (org-notifications-start)))

;; https://emacs.stackexchange.com/a/13238
(defun org-todo-list-current-file (&optional arg)
  "Like `org-todo-list', but using only the current buffer's file."
  (interactive "P")
  (let ((org-agenda-files (list (buffer-file-name (current-buffer)))))
    (if (null (car org-agenda-files))
        (error "%s is not visiting a file" (buffer-name (current-buffer)))
      (org-todo-list arg))))

;; ----------------------------------------------------------------------
;; Key bindings
;; ----------------------------------------------------------------------

;; TODO figure out commenting keybinds
(global-set-key (kbd "s-/") 'comment-line)

(global-set-key (kbd "C-c a") 'org-agenda)
;; TODO: keybind for org-mode directory?
;; (global-set-key (kbd "???") '???)

(global-set-key (kbd "s-\\") 'evil-window-vsplit)
(global-set-key (kbd "s-|") 'evil-window-split)

(global-set-key (kbd "<C-s-left>") 'slide-buffer-left)
(global-set-key (kbd "<C-s-right>") 'slide-buffer-right)
(global-set-key (kbd "<C-s-down>") 'slide-buffer-down)
(global-set-key (kbd "<C-s-up>") 'slide-buffer-up)

(global-set-key (kbd "<s-mouse-1>") 'go-to-definition-or-open-link)
(global-set-key (kbd "<C-down-mouse-1>") 'go-to-definition-or-open-link)

;; window movement
(global-set-key (kbd "<M-s-right>") 'windmove-right)
(global-set-key (kbd "<M-s-left>") 'windmove-left)
(global-set-key (kbd "<M-s-down>") 'windmove-down)
(global-set-key (kbd "<M-s-up>") 'windmove-up)

;; on linux
(global-set-key (kbd "<C-M-right>") 'windmove-right)
(global-set-key (kbd "<C-M-left>") 'windmove-left)
(global-set-key (kbd "<C-M-down>") 'windmove-down)
(global-set-key (kbd "<C-M-up>") 'windmove-up)

; Reevaluate syntax highlight like vim
(global-set-key (kbd "C-l") 'font-lock-update)

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

;; Copy-paste (cmd+v and cmd+c)
(define-key evil-normal-state-map (kbd "s-c") 'evil-yank-to-clipboard)
(define-key evil-insert-state-map (kbd "s-c") 'evil-yank-to-clipboard)
(define-key evil-visual-state-map (kbd "s-c") 'evil-yank-to-clipboard)
(define-key evil-insert-state-map (kbd "s-c") 'evil-yank-to-clipboard)

(define-key evil-normal-state-map (kbd "s-v") 'evil-paste-from-clipboard)
(define-key evil-insert-state-map (kbd "s-v") 'evil-paste-from-clipboard)
(define-key evil-visual-state-map (kbd "s-v") 'evil-paste-from-clipboard)
(define-key evil-insert-state-map (kbd "s-v") 'evil-paste-from-clipboard)

(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

;; Add LaTeX binaries to path for org-mode
(setenv "PATH" (concat "/Library/TeX/texbin:" (getenv "PATH")))
(add-to-list 'exec-path "/Library/TeX/texbin")

;; Make org-mode wrap text by default
(add-hook 'org-mode-hook 'visual-line-mode)

;; Update agenda views upon saving org files
(add-hook 'after-save-hook 'org-agenda-redo-save-hook)

;; Org mode synced files auto-update to the file on disk
(add-hook 'org-mode-hook #'auto-revert-mode)

;; Export org-mode to github-flavored markdown
(eval-after-load "org"
  '(require 'ox-gfm nil t))

(org-notifications-start)
;; add our own rule to make sure notifs are persistent.
(alert-add-rule :category "org-notifications"
                :persistent t
                :style 'notifications
                ;; by default this is inserted to head of list
                :continue t)
