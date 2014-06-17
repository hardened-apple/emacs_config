;; Set up packages and load configurations.
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))
(package-initialize)

;; I keep single file packages in this directory
(add-to-list 'load-path "~/.emacs.d/packages/")

(when (not package-archive-contents)
   (package-refresh-contents))

;; In a let as I don't like polluting the namespace.
(let
    ((common-packages
      '(undo-tree paredit yasnippet goto-chg wrap-region magit
                  evil-leader evil evil-exchange evil-args surround))
     (require-only
      '(buffer-move transpose-frame epa-file eldoc)))

  (let
      ((require-packages
        (append require-only common-packages)))

     ;; Install packages, require packages

    (dolist (p common-packages)
      (when (not (package-installed-p p))
        (package-install p)))

    (dolist (p require-packages)
      (require p))))

;; Load all files in the directory plugin_configurations
;; Name of file denotes order it's loaded in.
;; Note order matters in two ways here:
;;    wrap-region after paredit to not overwrite '('
;;    evil-leader before evil so works in initial buffers.
(dolist (file
         (directory-files "~/.emacs.d/plugin_configurations" t "^.+\\.elc?$"))
  (load file))


;; Settings always run regardless of extra plugins.
;; Have loaded the extra plugins and done all configurations for the extras.
;; Now I do general settings.

(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(setq inhibit-startup-message t)
(setq default-frame-alist '((font . "Tamsyn-10")))
(set-default-font "Tamsyn-10")
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Add line numbers to buffer and show column number in status line
(global-linum-mode t)
(setq column-number-mode t)

;; Highlight matching brackets
(show-paren-mode 1)

;; Automatically break long lines
;; use spaces instead of tabs
(setq-default auto-fill-function 'do-auto-fill)
(setq-default indent-tabs-mode nil)
(setq-default fill-column 80)

;; remove scrollbar, menubar, and toolbar in gui
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)


;; Enable some useful commands disabled by default
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)
(put 'erase-buffer 'disabled nil)

;; Make it more likely that split-window-sensibly will split vertically
(setq split-height-threshold 27)
(setq split-width-threshold 87) ; 87 is 80 columns of text + line numbers etc


;; make searches case-sensitive by default
(setq-default case-fold-search nil)

;; C mode specific things.
(setq c-default-style "linux"
      c-basic-offset 4)

(setq inferior-lisp-program "/usr/bin/sbcl")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"]))
 ;; '(custom-enabled-themes (quote (wombat))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; Functions
(defun backward-up-sexp (arg)
  (interactive "p")
  (let ((ppss (syntax-ppss)))
    (cond ((elt ppss 3)
           (goto-char (elt ppss 8))
           (backward-up-sexp (1- arg)))
          ((backward-up-list arg)))))

;; Remap C-M-u to account for comments and strings
(global-set-key [remap backward-up-list] 'backward-up-sexp)
(global-set-key (kbd "RET") 'newline-and-indent)

;; Remove M-r as move-to-window-line-top-bottom, and replace with M-p
;;   (done because paredit binds M-r)
(global-set-key (kbd "M-p") 'move-to-window-line-top-bottom)
