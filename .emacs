(add-to-list 'package-archives '("melpa"."https://melpa.org/packages/"))
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(yasnippet-snippets yasnippet-classic-snippets clang-format powerline-evil dap-mode company flycheck lsp-mode which-key s powerline evil dash badwolf-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ============================== PACKAGES LOADING ==============================

;; general.el
(add-to-list 'load-path "~/.emacs.d/packages")
(load "general.el")

;; ============================== YASNIPPETS ==============================
(require 'yasnippet)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(setq yas-snippet-dirs
      '(
	"~/.emacs.d/snippets"
	"~/.emacs.d/elpa/yasnippet-snippets-20241207.2221/snippets"
	)
      )

(yas-global-mode 1)

;; ============================== NAVIGATION ==============================

;; Vim navigation mode
(require 'evil)
(evil-mode 1)


;; ============================== COSMETICS ==============================

(setq-default truncate-lines nil)

(require 'whitespace)

;; clang-format
(require 'clang-format)
(setq clang-format-style "file")
(setq clang-format+-context 'modification)

;; Don't show startup message
(setq inhibit-startup-message t)

;; Remove UI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Theme
(load-theme 'badwolf t)

;; which-key
(require 'which-key)
(which-key-mode)

;; Line numbers
(global-display-line-numbers-mode 1)

(defun flycheck-error-count ()
  (interactive)
  (if (not (bound-and-true-p flycheck-mode))
    -1
    (let* ((errors (flycheck-count-errors flycheck-current-errors))
	   (error-count (or (cdr (assq 'error errors)) 0)))
      error-count
  )))

(defun flycheck-warning-count ()
  (interactive)
  (if (not (bound-and-true-p flycheck-mode))
    -1
    (let* ((errors (flycheck-count-errors flycheck-current-errors))
	   (warning-count (or (cdr (assq 'warning errors)) 0)))
      warning-count
  )))

(defun flycheck-info-count ()
  (interactive)
  (if (not (bound-and-true-p flycheck-mode))
    -1
    (let* ((errors (flycheck-count-errors flycheck-current-errors))
	   (info-count (or (cdr (assq 'warning errors)) 0)))
      info-count
  )))




;; Modeline
(setq-default mode-line-format 
                '((:eval
                   (format-mode-line
		    (list
                     evil-mode-line-tag
		     "%* %f %l:%c "
		     '(:eval (number-to-string(/
			(* (line-number-at-pos nil) 100)
		        (+ (count-lines (point-min) (point-max)) 1)
		       )))
		     "%% "
		     " (E:"
		     '(:eval (number-to-string (flycheck-error-count))) 
		     "-W:"
		     '(:eval (number-to-string (flycheck-warning-count)))
		     "-I:"
		     '(:eval (number-to-string (flycheck-info-count)))
		     ")"
 )))))

(electric-pair-mode 1)
(add-hook 'c-mode 'lsp)


;; ============================== FUNCTIONS ==============================


(defun config-file-opener ()
  (interactive)
  (find-file "~/.emacs")
)

(defun config-file-reload ()
  (interactive)
  (load-file "~/.emacs")
)

(defun import-from-header (file)
    (interactive "fHeader file:")
    (let ((buffer (current-buffer)))
      (message "%s" buffer)
      (let (( extension (file-name-extension file)))
        (if (string= "h" extension)
            (progn
        
                (insert-file-contents file)
                (let ((content (split-string (buffer-string) "\n" t)))
                  (setq content  (cl-delete-if (lambda (k) (not (string-match-p "[a-zA-z]+\** [^\s\\]+\(.*\);" k))) content))
                  (map-y-or-n-p "Insert \"%s\" "
                                (lambda (x) (with-current-buffer buffer
                                              (insert x "\n")))
                                content)
                  )
                )
              )
          (progn (message "Bad extension : Was asking for h, got %s" extension))
          )
        )
      )
    
  


;; ============================== SHORTCUTS ==============================

(require 'general)

(general-create-definer config-layer
  :prefix "SPC"
)

(config-layer
  :keymaps 'normal
  "c" #'config-file-opener
  "R" #'config-file-reload 
  "i" #'import-from-header
  "f" 'clang-format-buffer
  "p" 'flycheck-previous-error
  "n" 'flycheck-next-error
  "l" 'goto-line
)


;; ============================== LSP ==============================

(require 'lsp-mode)
(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(setq lsp-pyright-python-executable-cmd "/home/thanatos/bin/python3.13/bin/python")
;; ------------------------------ CCLS ------------------------------

(require 'ccls)
(setq ccls-executable "/usr/bin/ccls")

;; ============================== ORG ==============================

(setq org-agenda-files '("/home/thanatos/todo.org"))
(setq org-agenda-prefix-format '((agenda . "- %c : %b")))
(setq org-agenda-prefix-format '((todo . "- %c : %b")))

;; ============================== FLYCHECK ==============================

(global-flycheck-mode) 

;; ============================== MUTT ==============================

(server-start)
(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))

(defun mutt-launcher ()
  (interactive)
  (let ((xlist '("Perso" "Work" "Unistra"))) 
  (ansi-term (format "/usr/bin/mutt -F ~/.mutt/%s" (downcase (completing-read "Which mail:" xlist nil t))) 
   )))

      
(defun +lsp/uninstall-server (dir)
  "Delete a LSP server from `lsp-server-install-dir'."
  (interactive
   (list (read-directory-name "Uninstall LSP server: " lsp-server-install-dir nil t)))
  (unless (file-directory-p dir)
    (user-error "Couldn't find %S directory" dir))
  (delete-directory dir 'recursive)
  (message "Uninstalled %S" (file-name-nondirectory dir)))
 
(require 'color)

(defun csv-highlight (&optional separator)
  (interactive (list (when current-prefix-arg (read-char "Separator: "))))
  (font-lock-mode 1)
  (let* ((separator (or separator ?\,))
         (n (count-matches (string separator) (pos-bol) (pos-eol)))
         (colors (cl-loop for i from 0 to 1.0 by (/ 2.0 n)
                          collect (apply #'color-rgb-to-hex 
                                         (color-hsl-to-rgb i 0.3 0.5)))))
    (cl-loop for i from 2 to n by 2 
             for c in colors
             for r = (format "^\\([^%c\n]+%c\\)\\{%d\\}" separator separator i)
             do (font-lock-add-keywords nil `((,r (1 '(face (:foreground ,c)))))))))


(add-hook 'csv-mode-hook 'csv-highlight)
(add-hook 'csv-mode-hook 'csv-align-mode)
(add-hook 'csv-mode-hook '(lambda () (interactive) (toggle-truncate-lines nil)))

(setq-default major-mode 'shell-script-mode)


  (defun markdown-html (buffer)
    (princ (with-current-buffer buffer
      (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://ndossougbe.github.io/strapdown/dist/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
    (current-buffer)))

(provide '.emacs)

