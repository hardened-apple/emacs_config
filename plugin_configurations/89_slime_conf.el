;; Load slime, the extra contrib's and put some settings up.
(add-to-list 'load-path "~/.emacs.d/packages/slime")
(require 'slime-autoloads)
(setq slime-contribs '(slime-fancy slime-highlight-edits))

(define-key global-map (kbd "C-c s") 'slime-selector)
(setq slime-autodoc-use-multiline-p t)