;;; init.el --- my minimal dottie
;;; Commentary:
;;; Code:

;;;; Set user-emacs-directory
(when load-file-name (setq user-emacs-directory (file-name-directory load-file-name)))

;;;; Set custom-file
(setq custom-file (concat user-emacs-directory "init_custom.el"))

;;;; Frame appearance
(menu-bar-mode 0)           ;; Menu bar
(tool-bar-mode 0)           ;; Tool bar
(scroll-bar-mode 0)         ;; Scroll bar
(line-number-mode 1)        ;; Line number (mode line)
(column-number-mode 1)      ;; Column number (mode line)

;;;; Behavior
(setq ring-bell-function 'ignore)    ;; No visible-bell
(setq scroll-step 1)                 ;; Keyboard scroll one line at a time
(setq inhibit-startup-screen t)      ;; Disable startup screen
(setq-default indent-tabs-mode nil)  ;; Use spaces instead of tabs when indenting

;;;; Directory for cache files
(unless (file-directory-p (concat user-emacs-directory ".cache"))
  (make-directory (concat user-emacs-directory ".cache")))

;;;; Auto save
;; auto-save directory
(unless (file-directory-p (concat user-emacs-directory ".cache/auto-save"))
  (make-directory (concat user-emacs-directory ".cache/auto-save")))
(setq auto-save-file-name-transforms `((".*" , (concat user-emacs-directory ".cache/auto-save/") t)))
;; auto-save-list file
(setq auto-save-list-file-prefix (concat user-emacs-directory ".cache/auto-save/.saves-"))

;;;; Backup
;; backup directory
(setq backup-directory-alist `((".*" . , (concat user-emacs-directory "backup"))))
;; backup version control
(setq version-control t
      kept-new-versions 10
      kept-old-versions 2
      delete-old-versions t)

;;;; Buffers
(defalias 'list-buffers 'ibuffer)  ;; Make ibuffer default ('C-x C-b')
(global-auto-revert-mode 1)  ;; auto revert buffers
;; make buffer names unique
(when (require 'uniquify nil t)
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

;;;; Recentf
(setq recentf-max-saved-items 10000
      recentf-save-file (locate-user-emacs-file ".cache/recentf" ".recentf")
      recentf-exclude '("/.cache"))
(recentf-mode 1)

;;;; Mini buffer history
(setq history-length 3000
      savehist-file (locate-user-emacs-file ".cache/savehist" ".emacs-history"))
(savehist-mode 1)

;;;; Cursor
(when window-system
  (setq blink-cursor-blinks 0)
  (blink-cursor-mode 1))
;;(global-hl-line-mode 1)

;;;; Remember cursor position
(setq save-place-file (locate-user-emacs-file ".cache/places" ".emacs-places"))
(if (version<= "25" emacs-version)
    (save-place-mode 1)
  (require 'saveplace)
  (setq-default save-place t))

;;;; Paren style
(setq show-paren-style 'mixed)
(set-face-attribute 'show-paren-match nil
  :background nil :foreground nil :underline "orange" :weight 'extra-bold)
(show-paren-mode 1)

;;;; dired
(setq dired-recursive-copies 'always
      dired-recursive-deletes 'always
      dired-isearch-filenames t
      dired-dwim-target t
      wdired-allow-to-change-permissions t)
(add-hook 'dired-load-hook (lambda () (define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)))

;;;; Ido
(setq ido-enable-flex-matching t
      ido-everywhere t
      ido-save-directory-list-file (locate-user-emacs-file ".cache/ido.last" ".ido.last"))
(ido-mode 1)
;; ido recentf
(defun ido-find-recentf ()
  "Find a recent file using Ido."
  (interactive)
  (find-file (ido-completing-read "Recentf: " recentf-list)))

;;;; abbrev
(unless (file-directory-p (concat user-emacs-directory "abbrev"))
  (make-directory (concat user-emacs-directory "abbrev")))
(setq abbrev-file-name (locate-user-emacs-file "abbrev/abbrev_defs" ".abbrev_defs")
      save-abbrevs 'silently)
(when (file-readable-p abbrev-file-name)
  (quietly-read-abbrev-file))

;;;; Bookmarks
(setq bookmark-default-file (locate-user-emacs-file ".cache/bookmarks" ".emacs.bmk"))

;;;; eshell
(setq eshell-directory-name (concat user-emacs-directory ".cache/eshell/"))

;;;; URLs, cookies
(setq url-configuration-directory (concat user-emacs-directory ".cache/url/")
      url-cookie-file (concat user-emacs-directory ".cache/url/cookies"))

;;;; Keybindings
(define-key key-translation-map [?\C-h] [?\C-?])  ;; Use C-h to send a backspace
(setq set-mark-command-repeat-pop t)  ;; C-u C-SPC C-SPC ... to cycle through the mark ring
(define-key global-map "\C-cr" 'ido-find-recentf)

;;;; melpa / use-package / init-loader
(when (require 'package nil t)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  (package-initialize)
  (unless package-archive-contents (package-refresh-contents))
  ;; use-package
  (unless (package-installed-p 'use-package)
    (package-install 'use-package))
  (if (file-directory-p (concat user-emacs-directory "inits"))
      ;; init-loader
      (use-package init-loader :ensure t
        :config (init-loader-load))))

;;;; Load custom-file
(load custom-file t)

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; init.el ends here
