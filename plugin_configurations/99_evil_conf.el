;; Evil-mode, I hate the emacs keybindings
;; Move <Return> and <Space> from the "motion" keymap to the normal one.
;; This allows other emacs plugins to remap them if they ever want to.
(evil-mode 0)

;;; Variables
(setq evil-want-C-u-scroll t)
(setq evil-find-skip-newlines t)
(setq evil-flash-delay 5)

;; Set the default mode for certain buffers
(dolist (mode-state-pair '((inferior-emacs-lisp-mode . emacs)
                           (nrepl-mode . insert)
                           (pylookup-mode . emacs)
                           (comint-mode . normal)
                           (shell-mode . insert)
                           (git-commit-mode . insert)
                           (git-rebase-mode . emacs)
                           (term-mode . emacs)
                           (help-mode . emacs)
                           (helm-grep-mode . emacs)
                           (grep-mode . emacs)
                           (bc-menu-mode . emacs)
                           (magit-mode . emacs)
                           (magit-branch-manager-mode . emacs)
                           (rdictcc-buffer-mode . emacs)
                           (dired-mode . emacs)
                           (wdired-mode . normal)))
  (evil-set-initial-state (car mode-state-pair) (cdr mode-state-pair)))



;;; Mappings
(define-key evil-motion-state-map " " nil)
(define-key evil-motion-state-map (kbd "RET") nil)

;; Normal mode mappings
(defun copy-to-end-of-line ()
  (interactive)
  (evil-yank (point) (point-at-eol)))

(define-key evil-normal-state-map "Y" 'copy-to-end-of-line)

;; Remove some of the scrolling commands in evil to leave the default emacs ones
(define-key evil-motion-state-map (kbd "'") 'evil-goto-mark)
(define-key evil-motion-state-map (kbd "`") 'evil-goto-mark-line)

;;; Remove keychords when in evil-mode
(add-hook 'evil-normal-state-entry-hook (lambda () (key-chord-mode nil)))

;; All below will be moved into an "evil-unimpaired.el" plugin with extras.
;; Remember to add counts to this function.
(defun evil-unimpaired-newline-below (numlines)
  "Insert a new line below the point without moving it."
  (interactive "P")
  (save-excursion
    (if numlines
        (dotimes (nullvar numlines)
          (evil-insert-newline-below))
      (evil-insert-newline-below))))

(defun evil-unimpaired-newline-above (numlines)
  "Insert a new line below the point without moving it."
  (interactive "P")
  (save-excursion
    (if numlines
        (dotimes (nullvar numlines)
          (evil-insert-newline-above))
      (evil-insert-newline-above))))


(defun evil-unimpaired-move-line-down (numlines)
  (interactive "P")
  (let ((col (current-column)))
    (save-excursion
      (forward-line)
      (if numlines
          (dotimes (nullvar numlines)
            (transpose-lines 1))
       (transpose-lines 1)))
    (forward-line)
    (move-to-column col)))

(defun evil-unimpaired-move-line-up (numlines)
  (interactive "P")
  (let ((col (current-column)))
    (save-excursion
      (forward-line)
      (if numlines
          (dotimes (nullvar numlines)
            (transpose-lines -1))
       (transpose-lines -1)))
    (move-to-column col)))

(global-set-key (kbd "<C-s-up>") 'evil-unimpaired-move-line-up)
(global-set-key (kbd "<C-s-down>") 'evil-unimpaired-move-line-down)
;; (defun evil-unimpaired-swap-lines ()
;;   (interactive)
;;   (evil-delete-line)
;;   (evil-paste-after 1))

(define-key evil-normal-state-map "] " 'evil-unimpaired-newline-below)
(define-key evil-normal-state-map "[ " 'evil-unimpaired-newline-above)
(define-key evil-normal-state-map "]e" 'evil-unimpaired-move-line-down)
(define-key evil-normal-state-map "[e" 'evil-unimpaired-move-line-up)

;; (define-key evil-normal-state-map "]e" 'evil-unimpaired-swap-lines)
