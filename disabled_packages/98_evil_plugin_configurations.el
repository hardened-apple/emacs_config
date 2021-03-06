;;;; Evil plugin settings
;;;; (key bindings for non-evil plugins here)
;; Packages to get:
;;      evil-args
;;      evil-commentary
;;      evil-exchange
;;      evil-leader
;;      evil-surround

;;; Ace jump mode keybindings
(define-key evil-normal-state-map "s" nil)
(define-key evil-motion-state-map "s" 'ace-jump-word-mode)

;;; Buffer Move keybindings
(evil-leader/set-key
  "wh" 'buf-move-left
  "wj" 'buf-move-down
  "wk" 'buf-move-up
  "wl" 'buf-move-right)

;;; Mogit keybindings
(evil-leader/set-key
  "gg" 'magit-log
  "gw" 'magit-stage-this-file
  "gd" 'magit-diff-unstaged
  "gp" 'magit-push
  "gf" 'magit-pull
  "gs" 'magit-status)

;;; Window Number keybindings
(dotimes (winnum 5)
  (define-key evil-motion-state-map
    (format "g%d" (1+ winnum))
    (window-number-select-call (1+ winnum))))

;;;; Evil Leader Settings
;;;;
;; Has to be initialised before evil-mode so is available in *scratch*,
;; *Messages* etc (i.e. in initial buffers)

(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "nh" 'evil-ex-nohighlight
  "s"  'save-buffer
  "bs" 'helm-mini
  "fr" 'remove-buffer-and-file
  "fm" 'rename-buffer-and-file
  "fd" 'ediff-current-file
  "z"  'evil-ex
  "'"  'evil-ex)


;;;; Evil Mode Settings
;;;;
(evil-mode 0)

;; Mappings because of my specific keyboard layout
(define-key evil-motion-state-map "," 'evil-repeat-find-char)
(define-key evil-motion-state-map ";" 'evil-repeat-find-char-reverse)

(evil-define-motion evil-four-lines-down (count)
  "Mave the cursor COUNT*4 lines down"
  :type line
  (let (line-move-visual)
    (evil-line-move (* (or count 1) 4))))

(evil-define-motion evil-four-lines-up (count)
  "Mave the cursor COUNT*4 lines up"
  :type line
  (let (line-move-visual)
    (evil-line-move (- (* (or count 1) 4)))))

(define-key evil-motion-state-map "gj" 'evil-four-lines-down)
(define-key evil-motion-state-map "gk" 'evil-four-lines-up)

;;; Variables
(setq evil-cross-lines t)
(setq evil-flash-delay 5)
(setq evil-search-module 'evil-search)
(setq evil-want-C-i-jump t)
(setq evil-want-C-u-scroll t)
(setq evil-want-change-word-to-end nil)
(setq evil-move-cursor-back t) ; Unset this for paredit to work well.

;;; Set the default mode for certain buffers
(dolist (mode-state-pair '((git-commit-mode . insert)
                           (git-rebase-mode . emacs)
                           (helm-grep-mode . emacs)
                           (paredit-mode . emacs)))
  (evil-set-initial-state (car mode-state-pair) (cdr mode-state-pair)))

;;; Mappings
(define-key evil-motion-state-map " " nil)
(define-key evil-motion-state-map (kbd "RET") nil)

;; Normal mode mappings
(defun copy-to-end-of-line ()
  (interactive)
  (evil-yank (point) (point-at-eol)))

(define-key evil-normal-state-map "Y" 'copy-to-end-of-line)

(define-key evil-motion-state-map "'" 'evil-goto-mark)
(define-key evil-motion-state-map "`" 'evil-goto-mark-line)
(define-key evil-normal-state-map (kbd "<f10>" )'delete-trailing-whitespace)

;; C-6 go to previous buffer
(defun switch-to-last-seen-buffer ()
  "Switch to last open buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(define-key evil-motion-state-map (kbd "C-6") 'switch-to-last-seen-buffer)


;;; Visual state mappings
;;; indent keeping selection
(defun indent-keeping-selection (beg end)
  "Using > or < in visual mode indents and keeps selection at the same time"
  (interactive "r")
  (let (deactivate-mark)
    (evil-shift-right beg end)))

(defun dedent-keeping-selection (beg end)
  "Using > or < in visual mode indents and keeps selection at the same time"
  (interactive "r")
  (let (deactivate-mark)
    (evil-shift-left beg end)))

(define-key evil-visual-state-map ">" 'indent-keeping-selection)
(define-key evil-visual-state-map "<" 'dedent-keeping-selection)

;; Insert mode mappings
(define-key evil-insert-state-map (kbd "C-u")
  (lambda () (interactive) (kill-line 0)))

;; Ex Mode Mappings
(define-key evil-ex-map "e" 'helm-find-files)
(define-key evil-ex-map "b" 'helm-mini)

;; Remove keychords and wrap-region when in evil-mode
(add-hook 'evil-normal-state-entry-hook
          (lambda ()
            (key-chord-mode -1)
            (wrap-region-mode -1)))
(add-hook 'evil-emacs-state-entry-hook
          (lambda ()
            (key-chord-mode 1)
            (wrap-region-mode 1)))

(evil-define-motion evil-little-word (count)
  :type exclusive
  (let* ((case-fold-search nil)
         (count (if count count 1)))
    (while (> count 0)
      (forward-char)
      (search-forward-regexp "[_A-Z]\\|\\W" nil t)
      (backward-char)
      (decf count))))

(define-key evil-operator-state-map "lw" 'evil-little-word)

(defun whitespace-only-p (string)
  (equal "" (replace-regexp-in-string "[ \t\n]" "" string)))

(defadvice evil-delete (around evil-delete-yank activate)
  (if (whitespace-only-p (buffer-substring beg end))
      (ad-set-arg 3 ?_))
  ad-do-it)

;;;; Evil Unimpaired Settings
;;;;
;;; maybe evil-define-command for these
(defun evil-unimpaired-newline-below (numlines)
  "Insert a new line below the point without moving it."
  (interactive "p")
  (save-excursion
    (progn
      (end-of-line)
      (dotimes (nullvar numlines)
        (newline)))))

(defun evil-unimpaired-newline-above (numlines)
  "Insert a new line below the point without moving it."
  (interactive "p")
  (let ((save-col (current-column)))
    (progn
      (beginning-of-line)
      (dotimes (nullvar numlines)
        (newline)))
    (move-to-column save-col)))


(define-key evil-normal-state-map "] " 'evil-unimpaired-newline-below)
(define-key evil-normal-state-map "[ " 'evil-unimpaired-newline-above)
(define-key evil-normal-state-map "[b" 'next-buffer)
(define-key evil-normal-state-map "]b" 'previous-buffer)
(define-key evil-normal-state-map "]e" 'move-this-line-down)
(define-key evil-normal-state-map "[e" 'move-this-line-up)
(define-key evil-normal-state-map "]q" 'next-error)
(define-key evil-normal-state-map "[q" 'previous-error)
(define-key evil-normal-state-map "[Q" 'first-error)


;;;; Evil Args Settings
;;;;
;;; Text objects
(define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
(define-key evil-outer-text-objects-map "a" 'evil-outer-arg)

;;; Leader mappings
(evil-leader/set-key
  "ah" 'evil-backward-arg
  "al" 'evil-forward-arg
  "ak" 'evil-jump-out-args)


;;;; Evil Exchange Settings
;;;;
;; (use gx<motion> to select a range, once selected two ranges they are swapped
(evil-exchange-install)


;;;; Evil Surround Settings
;;;;
(global-evil-surround-mode 1)
