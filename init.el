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
(setopt custom-safe-themes t)
(when (shl/require 'ef-themes)
  (setopt ef-themes-mixed-fonts t
	  ef-themes-variable-pitch-ui t)
  (mapc #'disable-theme custom-enabled-themes)

  (defun my-ef-themes-mode-line ()
    "Tweak the style of the mode lines."
    (ef-themes-with-colors
     (custom-set-faces
      `(mode-line ((,c :background ,bg-active :foreground ,fg-main :box (:line-width 1 :color ,fg-dim))))
      `(mode-line-inactive ((,c :box (:line-width 1 :color ,bg-active)))))))

  (add-hook 'ef-themes-post-load-hook #'my-ef-themes-mode-line)

  (ef-themes-select 'ef-deuteranopia-light))


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

(require 'treesit)
(when (treesit-available-p)
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

  (mapc #'treesit-install-language-grammar
        (mapcar #'car treesit-language-source-alist))

  (setq major-mode-ramap-alist
        '((yaml-mode . yaml-ts-mode)
          (toml-mode . toml-ts-mode)
          (bash-mode . bash-ts-mode)
          (python-mode . python-ts-mode))))


(require 'cl-lib)
(defun shl/git-clone-clipboard-url ()
  "Clone git URL in clipboard asynchronously and open in dired when finished."
  (interactive)
  (cl-assert (string-match-p "^\\(http\\|https\\|ssh\\)://" (current-kill 0)) nil "No URL in clipboard")
  (let* ((url (current-kill 0))
         (download-dir (expand-file-name "~/data/resources/code-reference/"))
         (project-dir (concat (file-name-as-directory download-dir)
                              (file-name-base url)))
         (default-directory download-dir)
         (command (format "git clone %s" url))
         (buffer (generate-new-buffer (format "*%s*" command)))
         (proc))
    (when (file-exists-p project-dir)
      (if (y-or-n-p (format "%s exists. delete?" (file-name-base url)))
          (delete-directory project-dir t)
        (user-error "Bailed")))
    (switch-to-buffer buffer)
    (setq proc (start-process-shell-command (nth 0 (split-string command)) buffer command))
    (with-current-buffer buffer
      (setq default-directory download-dir)
      (shell-command-save-pos-or-erase)
      (require 'shell)
      (shell-mode)
      (view-mode +1))
    (set-process-sentinel proc (lambda (process state)
                                 (let ((output (with-current-buffer (process-buffer process)
                                                 (buffer-string))))
                                   (kill-buffer (process-buffer process))
                                   (if (= (process-exit-status process) 0)
                                       (progn
                                         (message "finished: %s" command)
                                         (dired project-dir))
                                     (user-error (format "%s\n%s" command output))))))
    (set-process-filter proc #'comint-output-filter)))

;;;; Eshell Prompt
;; A nicer eshell prompt https://gist.github.com/ekaschalk/f0ac91c406ad99e53bb97752683811a5
;; with some useful discussion of how it was put together http://www.modernemacs.com/post/custom-eshell/
;; I've made just a few tiny modifications.

(with-eval-after-load 'eshell
(require 'dash)
(require 's)

(defmacro with-face (STR &rest PROPS)
  "Return STR propertized with PROPS."
  `(propertize ,STR 'face (list ,@PROPS)))

(defmacro esh-section (NAME ICON FORM &rest PROPS)
  "Build eshell section NAME with ICON prepended to evaled FORM with PROPS."
  `(setq ,NAME
         (lambda () (when ,FORM
                 (-> ,ICON
                    (concat esh-section-delim ,FORM)
                    (with-face ,@PROPS))))))

(defun esh-acc (acc x)
  "Accumulator for evaluating and concatenating esh-sections."
  (--if-let (funcall x)
      (if (s-blank? acc)
          it
        (concat acc esh-sep it))
    acc))

(defun esh-prompt-func ()
  "Build `eshell-prompt-function'"
  (concat esh-header
          (-reduce-from 'esh-acc "" eshell-funcs)
          "\n"
          eshell-prompt-string))

(esh-section esh-dir
             "\xf07c"  ;  (faicon folder)
             (abbreviate-file-name (eshell/pwd))
             '(:foreground "#268bd2" :underline t))

(esh-section esh-git
             "\xe907"  ;  (git icon)
             (with-eval-after-load 'magit
             (magit-get-current-branch))
             '(:foreground "#b58900"))

(esh-section esh-python
             "\xe928"  ;  (python icon)
             (with-eval-after-load "virtualenvwrapper"
             venv-current-name))

(esh-section esh-clock
             "\xf017"  ;  (clock icon)
             (format-time-string "%H:%M" (current-time))
             '(:foreground "forest green"))

;; Below I implement a "prompt number" section
(setq esh-prompt-num 0)
(add-hook 'eshell-exit-hook (lambda () (setq esh-prompt-num 0)))
(advice-add 'eshell-send-input :before
            (lambda (&rest args) (setq esh-prompt-num (cl-incf esh-prompt-num))))

(esh-section esh-num
             "\xf0c9"  ;  (list icon)
             (number-to-string esh-prompt-num)
             '(:foreground "brown"))

;; Separator between esh-sections
(setq esh-sep " | ")  ; or "  "

;; Separator between an esh-section icon and form
(setq esh-section-delim " ")

;; Eshell prompt header
(setq esh-header "\n┌─")  ; or "\n "

;; Eshell prompt regexp and string. Unless you are varying the prompt by eg.
;; your login, these can be the same.
(setq eshell-prompt-regexp "^└─>> ") ;; note the '^' to get regex working right
(setq eshell-prompt-string "└─>> ")

;; Choose which eshell-funcs to enable
(setq eshell-funcs (list esh-dir esh-git esh-python esh-clock esh-num))

;; Enable the new eshell prompt
(setq eshell-prompt-function 'esh-prompt-func))

(defun eshell-clear-buffer ()
  "Clear terminal"
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(add-hook 'eshell-mode-hook
          #'(lambda()
              (local-set-key (kbd "C-l") 'eshell-clear-buffer)))

(when (shl/maybe-require 'esh-autosuggest)
  (add-hook 'eshell-mode-hook #'esh-autosuggest-mode))


;;; init.el ends here
