;;; init.el --- SHL Emacs Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; Packaging
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(defvar shl/package-contents-refreshed nil)

(defun shl/package-refresh-contents-once ()
  (when (not shl/package-contents-refreshed)
    (setq shl/package-contents-refreshed t)
    (package-refresh-contents)))

(defun shl/require (package)
  (when (not (package-installed-p package))
    (shl/package-refresh-contents-once)
    (package-install package))
  (package-installed-p package))

(defun shl/maybe-require (package)
  (condition-case err
      (shl/require package)
    (error
     (message "Couldn't install optional package `%s': %S" package err)
     nil)))

;; Setup execpath
(when (shl/require 'exec-path-from-shell)
  (when (or (memq window-system '(mac ns x pgtk))
            (unless (memq system-type '(ms-dos windows-nt))
              (daemonp)))
    (exec-path-from-shell-initialize)))

;; Appearance
;; (when (shl/require 'modus-themes)
;;   (load-theme 'modus-vivendi-deuteranopia :no-confirm))
(when (shl/require 'gruber-darker-theme)
  (load-theme 'gruber-darker :no-confirm))

(when (shl/maybe-require 'fontaine)
  (add-hook 'emacs-startup-hook #'fontaine-mode)
  (add-hook 'emacs-startup-hook (lambda ()
                                  (fontaine-set-preset 'regular-dark)))
    (setopt x-underline-at-descent-line nil)
    (setq fontaine-presets
        '((small
           :default-family "Iosevka Comfy Motion"
           :default-height 80
           :variable-pitch-family "Iosevka Comfy Duo")
          (regular-dark
           :default-family "Iosevka Comfy"
           :variable-pitch-family "Iosevka Comfy Duo"
           :default-weight medium) ; like this it uses all the fallback values and is named `regular'
          (regular-light 
           :default-weight semilight) ; like this it uses all the fallback values and is named `regular'
          (medium-light
           :default-weight semilight
           :default-height 115)
          (medium-dark
           :default-weight medium
           :default-height 115
           :bold-weight extrabold)
          (large
           :inherit medium
           :default-height 150))))

(add-hook 'org-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(setopt display-line-numbers-width 3
        display-line-numbers-type 'relative)
(when (boundp 'display-fill-column-indicator)
  (setq-default indicate-buffer-boundaries 'left
                display-fill-column-indicator-character ?┊)
  (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode))

;; Settings
(setopt custom-file (concat user-emacs-directory "custom.el")
        bookmark-default-file (locate-user-emacs-file ".bookmarks.el")  ;; Hide bookmarks.el, to not clutter user-emacs-dir
        use-short-answers t  ;; Use y and n instead of yes and no.
	buffer-menu-max-size 30
        inhibit-splash-screen t
	case-fold-search t  ;; Ignore case while searching
	column-number-mode t  ;; Show column number in modeline
	indent-tabs-mode nil  ;; Ensure that all indentation is with spaces
	create-lockfiles nil  ;; Don't clutter directories with lock files
	auto-save-default nil ;; Don't autosave buffers
	make-backup-files nil  ;; Don't make backups
	vc-make-backup-files nil  ;; Don't make backups of version controlled files
	save-interprogram-paste-before-kill t  ;; Save existing clipboard text into kill ring before replacing.
	scroll-preserve-screen-position 'always  ;; Ensure that scrolling does not move point
        truncate-lines nil ;; Truncate lines when wider than buffer-width
        truncate-partial-width-windows nil)

;; Speed up font rendering for special characters
;; @see https://www.reddit.com/r/emacs/comments/988paa/emacs_on_windows_seems_lagging/
(setq inhibit-compacting-font-caches t)

;; GUI Frames
(setq use-file-dialog nil)
(setq use-dialog-box nil)

;; Savehist
(savehist-mode 1)

;; Turn of bell
(setq ring-bell-function 'ignore)

;; Minibuffer
(when (shl/maybe-require 'vertico)
  (vertico-mode))

(when (shl/maybe-require 'embark)
  (global-set-key (kbd "C-.") 'embark-act)
  (global-set-key (kbd "M-.") 'embark-dwim))

(when (shl/maybe-require 'which-key)
  (add-hook 'after-init-hook 'which-key-mode)
  (setq-default which-key-idle-delay 0.3))

(when (shl/maybe-require 'consult)
  (global-set-key [remap switch-to-buffer] 'consult-buffer)
  (global-set-key [remap switch-to-buffer-other-window] 'consult-buffer-other-window)
  (global-set-key [remap switch-to-buffer-other-frame] 'consult-buffer-other-frame)
  (global-set-key [remap goto-line] 'consult-goto-line))

(when (shl/maybe-require 'embark-consult)
  (with-eval-after-load 'embark
    (require 'embark-consult)
    (add-hook 'embark-collect-mode-hook 'embark-consult-preview-minor-mode)))

(when (shl/maybe-require 'marginalia)
  (setq marginalia-max-relative-age 0)  ;; Use absolute time
  (marginalia-mode))

(use-package orderless
  :ensure t
  :config

  (with-eval-after-load 'vertico
    (require 'orderless)
    (setq completion-styles '(orderless basic)))

  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((eglot (styles orderless))
                                        (eglot-capf (styles orderless))))
  (setq completion-cycle-threshold 4))

(when (shl/maybe-require 'orderless)
  (setq completion-category-defaults nil
        completion-category-overrides '((eglot (styles orderless))
                                        (eglot-capf (styles orderless)))
        completion-cycle-threshold 4)

  (with-eval-after-load 'vertico
    (require 'orderless)
    (setq completion-styles '(orderless basic))))

;; Ensure that opening parentheses are paired with closing
(add-hook 'prog-mode-hook #'electric-pair-mode)
(add-hook 'prog-mode-hook #'electric-indent-mode)


;; Subword-mode enables moving in CamelCase and snake_case
(global-subword-mode)

;; Delete selection
(add-hook 'after-init-hook #'delete-selection-mode)

;; Expand Region makes for a nicer way to mark stuff
(when (shl/maybe-require 'expand-region)
  (global-set-key (kbd "M-h") #'er/expand-region))

;; Hippie Expand instead of dabbrev
(global-set-key [remap dabbre-expand] 'hippie-expand)

;; Compilation
(defun shl/colorize-compilation-buffer ()
  (read-only-mode 'toggle)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (read-only-mode 'toggle))
(add-hook 'compilation-filter-hook 'shl/colorize-compilation-buffer)

(when (shl/require 'magit)
  (global-set-key (kbd "C-x g") #'magit-status))

(when (shl/require 'rust-mode)
  (require 'rust-mode))

(when (shl/maybe-require 'obsidian)
  (obsidian-specify-path "~/data/Exocortex/Exocortex")

  (add-hook
   'obsidian-mode-hook
   (lambda ()
     (local-set-key (kbd "C-c C-o") 'obsidian-follow-link-at-point)
     (local-set-key (kbd "C-c C-l") 'obsidian-insert-wikilink)
     (local-set-key (kbd "C-c C-b") 'obsidian-backlink-jump)))


  (global-set-key (kbd "C-c n") 'obsidian-hydra/body))

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(mapc #'treesit-install-language-grammar
      (mapcar #'car treesit-language-source-alist))q

(setq major-mode-ramap-alist
      '((yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)
        (python-mode . python-ts-mode)))


;;; init.el ends here
