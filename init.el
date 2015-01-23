;;;; Align
;;;;
(defun align-repeat (start end regexp)
  "repeat alignment with respect to
     the given regular expression"
  (interactive "r\nsAlign regexp: ")
  (align-regexp start end
                (concat "\\(\\s-*\\)" regexp) 1 1 t))


;;;; Auto Save / Backups
;;;;
(setq auto-save-default t
      auto-save-interval 500)


;;;; Window history buffer switch
;;;;
(defvar buffer-choose-default-function 'switch-to-buffer
  "Function to call with the key C-x b  with no prefix.")

(defun window-history-buffer-choose (&optional prefix)
  "Select a buffer from the current window history."
  (interactive "P")
  (if prefix
      (let ((buffer-names
             (mapcar (lambda (list-thing) (buffer-name (car list-thing)))
                     (append (window-prev-buffers) (window-next-buffers)))))
        (if buffer-names
            (switch-to-buffer
             (completing-read "Buffer previous " buffer-names
                              nil t nil nil (car buffer-names) nil))
          (call-interactively buffer-choose-default-function)))
    (call-interactively buffer-choose-default-function)))

(define-key ctl-x-map "b" 'window-history-buffer-choose)


;;;; CamelCase word motion
;;;;
(global-subword-mode 1)


;;;; Compile Shortcut
;;;;
(global-set-key (kbd "<f9>") 'compile)
(global-set-key (kbd "<C-f9>") 'recompile)


;;;; Enable commands
;;;;
(setq disabled-command-function nil)


;;;; File Handling
;;;;
(defun remove-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (unless (and filename (file-exists-p filename))
      (error "Buffer '%s' is not visiting a file!" name))
    (delete-file filename)
    (kill-buffer buffer)
    (message "File '%s' removed" filename)))

(defun rename-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless (and filename (file-exists-p filename))
      (error "Buffer '%s' is not visiting a file!" name))
    (let ((new-name (read-file-name "New name: " filename)))
      (rename-file filename new-name 1)
      (rename-buffer new-name t)
      (set-visited-file-name new-name)
      (set-buffer-modified-p nil)
      (message "File '%s' successfully renamed to '%s'" name
               (file-name-nondirectory new-name)))))


;;;; Indentation Motion
;;;;
(defun beginning-of-line-or-indentation ()
  "Move to the beginning of the line or indentation."
  (interactive)
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (beginning-of-line))))

(global-set-key (kbd "C-a") 'beginning-of-line-or-indentation)


;;;; Info
;;;;
(defun info-goto-page-in-region (startpt endpt)
  (interactive "r")
  (info (buffer-substring startpt endpt)))


;;;; Lines
;;;;
;;; New lines
(defun open-line-below ()
  (interactive)
  (end-of-line)
  (indent-new-comment-line))

(defun open-line-above ()
  (interactive)
  (end-of-line)
  (indent-new-comment-line)
  (transpose-lines 1)
  (forward-line -2)
  (end-of-line))

(global-set-key (kbd "C-o") 'open-line-below)
(global-set-key (kbd "C-S-o") 'open-line-above)

;;; Move lines around
(defun move-this-line-down (numlines)
  (interactive "p")
  (let ((col (current-column)))
    (forward-line)
    (transpose-lines numlines)
    (forward-line -1)
    (move-to-column col)))

(defun move-this-line-up (numlines)
  (interactive "p")
  (let ((col (current-column)))
    (forward-line)
    (transpose-lines (- numlines))
    ;; Note: I have advised TRANSPOSE-SUBR, which means I need to call
    ;; FORWARD-LINE with argument -1, if I hadn't I'd need to call it with
    ;; argument (- (1+ NUMLINES))
    (forward-line -1)
    ;;(forward-line (- (1+ numlines)))
    (move-to-column col)))

(global-set-key (kbd "<C-s-up>") 'move-this-line-up)
(global-set-key (kbd "<C-s-down>") 'move-this-line-down)
(global-set-key (kbd "M-j") (lambda () (interactive) (join-line -1)))
(global-set-key (kbd "RET") 'indent-new-comment-line)


;;;; Make scripts executeable automatically
;;;;
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)


;;;; Move more quickly
;;;;
(global-set-key (kbd "C-S-n") (lambda (numtimes) (interactive "p")
                                (ignore-errors (next-line (* numtimes 5)))))
(global-set-key (kbd "C-S-p") (lambda (numtimes) (interactive "p")
                                (ignore-errors (previous-line (* numtimes 5)))))


;;;; Recursive minibuffers
;;;;
(setq enable-recursive-minibuffers t)


;;;; Redefining sexp motion
;;;;
(defun backward-up-sexp (arg)
  (interactive "p")
  (let ((ppss (syntax-ppss)))
    (cond ((elt ppss 3)
           (goto-char (elt ppss 8))
           (backward-up-sexp (1- arg)))
          ((backward-up-list arg)))))

(global-set-key [remap backward-up-list] 'backward-up-sexp)
(global-set-key (kbd "C-M-<backspace>") 'backward-kill-sexp)


;;;; Replace yes/no by y/n
;;;;
(fset 'yes-or-no-p 'y-or-n-p)


;;;; Scrolling
;;;;
(require 'view)
(global-set-key (kbd "C-v") 'View-scroll-half-page-forward)
(global-set-key (kbd "M-v") 'View-scroll-half-page-backward)
(global-set-key (kbd "C-S-v") 'scroll-up-command)
(global-set-key (kbd "M-V") 'scroll-down-command)
(global-set-key (kbd "C-q") 'move-to-window-line-top-bottom)
(setq scroll-conservatively 101
      scroll-margin 3
      auto-window-vscroll nil
      next-screen-context-lines 3)


;;;; Set the files to use
;;;;
(setq custom-file "~/.emacs.d/customize.el"
      abbrev-file-name "~/.emacs.d/abbrev_defs"
      backup-directory-alist `((".*" . "~/.emacs.d/backups/"))
      backup-by-copying-when-linked t
      auto-save-file-name-transforms `((".*" "~/.emacs.d/autosaves/" t)))
(load custom-file)


;;;; Transpose things (negative)
;;;;
;; I want negative arguments in transpose-* to "drag" the current object back
;; with repeated calls. To do this I need the point to end up at the end of the
;; same object it was called at the end of.
(defadvice transpose-subr (after bubble-back activate)
  (when (< arg 0)
    (if special
        (goto-char (car (funcall mover arg)))
        (funcall mover arg))))


;;;; User Interface
;;;;
(setq inhibit-startup-message t
      default-frame-alist '((font . "Tamsyn-10"))
      column-number-mode t)
(set-default-font "Tamsyn-10")
(mouse-avoidance-mode 'exile)
(global-linum-mode t)
(show-paren-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(global-unset-key (kbd "M-o"))


;;;; Whitespace and indent
;;;;
;; Automatically break long lines
;; use spaces instead of tabs
;; Don't show lines wrapped if longer than screen width
(setq-default auto-fill-function 'do-auto-fill
              indent-tabs-mode nil
              fill-column 80
              tab-width 4
              truncate-lines t
              visual-line-mode nil)
(setq indent-line-function 'insert-tab)

(defun cleanup-buffer-safe ()
  "Perform a bunch of safe operations on the whitespace content of a buffer.
Does not indent buffer, because it is used for a before-save-hook, and that
might be bad."
  (interactive)
  (untabify (point-min) (point-max))
  (delete-trailing-whitespace)
  (set-buffer-file-coding-system 'utf-8))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer.
Including indent-buffer, which should not be called automatically on save."
  (interactive)
  (cleanup-buffer-safe)
  (indent-region (point-min) (point-max)))

(global-set-key (kbd "C-c w") 'cleanup-buffer)
(add-hook 'before-save-hook 'cleanup-buffer-safe)


;;;; Window Layout
;;;;
(define-key ctl-x-map "+" 'what-cursor-position)
(define-key ctl-x-map "=" 'balance-windows)

(defun fix-window-horizontal-size (&optional num-columns)
  "Set the window's size to 80 (or prefix arg WIDTH) columns wide."
  (interactive)
  (enlarge-window (- (or num-columns 82) (window-width)) 'horizontal))

(define-key ctl-x-4-map "w" 'fix-window-horizontal-size)
(define-key ctl-x-4-map "g" 'delete-other-windows-vertically)

;; Keep window size evenly spread
(setq window-combination-resize t)

;;; Make it more likely that split-window-sensibly will split vertically
(setq fit-window-to-buffer-horizontally t)
(setq split-height-threshold 27
      split-width-threshold 175      ; 2 * 80 columns of text + line numbers etc
      compilation-window-height 10)

;;; Splice current windows into parent tree
(defun splice-window--get-all-window-siblings (&optional direction window)
  "Return a list of WINDOW's siblings in given DIRECTION.
Default direction is forward.
If any siblings don't satisfy `window-live-p', throw an error."
  (catch 'dead-window
    (let ((current-sibling (or window (selected-window)))
         (window-iterator-function (case direction
                                     (prev 'window-prev-sibling)
                                     (t 'window-next-sibling)))
         return-list)
     (while (setq current-sibling
                  (funcall window-iterator-function current-sibling))
       (unless (window-live-p current-sibling)
         (throw 'dead-window 'subtrees-exist))
       (push (list
              (window-buffer current-sibling)
              (window-start current-sibling)
              (window-point current-sibling)
              (window-hscroll current-sibling)
              (window-dedicated-p current-sibling)
              (window-redisplay-end-trigger)
              current-sibling) return-list))
     return-list)))

(defun splice-window--get-current-split-type (&optional window)
  "Return the configuration (vertical/horizontal) WINDOW is in.
Returns nil if WINDOW is either the root window or the minibuffer window."
  (catch 'configured
    (when (window-combined-p window)
      (throw 'configured 'vertical))
    (when (window-combined-p window t)
      (throw 'configured 'horizontal))))

(defun splice-window--add-back-window (base-window to-add forwards)
  "Add window specification TO-ADD into the BASE-WINDOW's config."
  (let ((direction
         (case (splice-window--get-current-split-type)
           (vertical (if forwards 'below 'above))
           (horizontal (if forwards 'right 'left))
           (t (if (>= (/ (window-body-width base-window) split-width-threshold)
                      (/ (window-body-height base-window) split-height-threshold))
                  (if forwards 'right 'left)
                (if forwards 'below 'above))))))
    (let ((window (split-window base-window nil direction))
          (buffer (pop to-add)))
      (set-window-buffer window buffer)
      (set-window-start window (pop to-add))
      (set-window-point window (pop to-add))
      (set-window-hscroll window (pop to-add))
      (set-window-dedicated-p window (pop to-add))
      (set-window-redisplay-end-trigger window (pop to-add))
      (let ((orig-window (pop to-add))
            (ol-func (lambda (ol)
                       (if (eq (overlay-get ol 'window) orig-window)
                           (overlay-put ol 'window window))))
            (ol-lists (with-current-buffer buffer
                        (overlay-lists))))
        (mapc ol-func (car ol-lists))
        (mapc ol-func (cdr ol-lists))))))

(defun splice-window-upwards (&optional window)
  "Move the current window level up one, and splice windows into parents level"
  (interactive)
  (let ((forward-siblings (splice-window--get-all-window-siblings 'next))
        (backward-siblings (splice-window--get-all-window-siblings 'prev))
        (cur-win (or window (selected-window))))
    ;; Check it makes sense to call this function in the current environment
    (unless (or (frame-root-window-p cur-win)
                (frame-root-window-p (window-parent cur-win))
                (memq 'subtrees-exist (list forward-siblings backward-siblings)))
      ;; Remove current siblings
      ;; once all siblings are closed, emacs automatically splices the remaining
      ;; window into the above level.
      (dolist (cur-sibling (append forward-siblings backward-siblings))
        (delete-window (car (last cur-sibling))))
      (dolist (forward-sibling forward-siblings)
        (splice-window--add-back-window cur-win forward-sibling t))
      (dolist (back-sibling backward-siblings)
        (splice-window--add-back-window cur-win back-sibling nil)))))

(define-key ctl-x-4-map "s" 'splice-window-upwards)


;;;; Plugins and everything not enabled by default
;;;;

;;; Set up packages and load configurations.
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

;;; I keep single file packages in this directory
(add-to-list 'load-path "~/.emacs.d/packages/")

(when (not package-archive-contents)
  (package-refresh-contents))

;;; In a let as I don't like polluting the namespace.
(let
    ((download-only '(monokai-theme tangotango-theme helm))

     (elpa-packages
      '(undo-tree paredit yasnippet key-chord goto-chg
                  ace-jump-mode wrap-region magit multiple-cursors expand-region
                  elisp-slime-nav jump-char quack monky python-pylint
                  smart-window projectile helm-projectile arduino-mode
                  list-register vimrc-mode xcscope smart-tab helm-descbinds
                  smartscan window-number
                  ;; I occasionally use this, but not usually -- shows currently
                  ;; unbound keys, which is useful for deciding on a keybinding.
                  ;; unbound
                  ))

     (require-only
      '(epa-file eldoc desktop uniquify
                 buffer-move transpose-frame
                 eshell em-smart
                 nameses le-eval-and-insert-results)))

  (let
      ((require-packages
        (append require-only elpa-packages)))

    ;; Install packages, require packages
    (dolist (p (append elpa-packages download-only))
      (unless (package-installed-p p)
        (package-install p)))

    (dolist (p require-packages)
      (require p))))

;;; Load all files in the directory plugin_configurations
;;; Name of file denotes order it's loaded in.
;;; Note order matters in way here:
;;;    wrap-region after paredit to not overwrite '('
(dolist (conf-file
         (directory-files "~/.emacs.d/plugin_configurations" t "^.+\\.elc?$"))
  (load conf-file))
