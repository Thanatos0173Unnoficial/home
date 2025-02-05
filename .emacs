(add-to-list 'package-archives '("melpa"."https://melpa.org/packages/"))
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("9d8e98cceba8c9ad161a9ab5d308068f803d78654dc2316dcb663ff0cb449b1f" "f5afc583c5d343097a121687061e670d0f2693472986ab3a5aa320b7c5705e70" "bc0698ac308a518402ca525890e80c7b70379fe422f260942d55aeb4d4352ce3" "be5a73d9463b9a45a9889bcc860b26c390eca59be7702f80d2beb1401da6031e" "bb8415092e2feaaa1d189efd0fa8b37696764246dbe06e6e6f048e9838ff23e4" default))
 '(package-selected-packages
   '(highlight-numbers elisp-format backup-each-save latex-preview-pane auctex impatient-mode whitespace-cleanup-mode lsp-ui yasnippet-snippets yasnippet-classic-snippets clang-format powerline-evil dap-mode company flycheck lsp-mode which-key s powerline evil dash)))
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
(load "pim-advise-display-warning.el")
(load "custom-badwolf-theme")

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


(which-key-mode)

(setq-default backup-inhibited nil)
(setq-default vc-make-backup-files t)
(setq

   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . ".~"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
 )       ; use versioned backups

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
(global-font-lock-mode t)
(load-theme 'tartarus-theme t)
(add-hook 'prog-mode-hook 'highlight-numbers-mode)
(font-lock-add-keywords
 'c-mode
 '(("\\<\\(\\sw+\\) ?(" 1 'font-lock-function-name-face)))

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

(defun cpp-hooks ()
  (lsp)
  (setq flycheck-gcc-language-standard "c++17")
  (message "test")
  )

(add-hook 'lsp-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook #'cpp-hooks)

(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") #'company-select-next)
  (define-key company-active-map (kbd "<tab>") #'company-select-next)
  (define-key company-active-map (kbd "S-TAB") #'company-select-previous)
  (define-key company-active-map (kbd "<backtab>") #'company-select-previous)) ;; Shift+Tab moves backwards

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (yas-global-mode)
  )


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
  "C" #'latex-compile-current
  "L" #'latex_compile
)


;; ============================== LSP ==============================

(setq pim-warning-suppress-message-regexps '("rulesRefreshed"))

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

(defun yes-or-no-p->-y-or-n-p (orig-fun &rest r)
  (cl-letf (((symbol-function 'yes-or-no-p) #'y-or-n-p))
    (apply orig-fun r)))

(advice-add 'projectile-kill-buffers :around #'yes-or-no-p->-y-or-n-p)
(advice-add 'project-kill-buffers :around #'yes-or-no-p->-y-or-n-p)

;; ============================== LATEX ==============================
(defun sentinel_output (process event)
    (message "%s : %s " process event )
    )

  (defun filter_function (process event)
    (message "Filter %s : %s" process event)
    (with-current-buffer "*Latex-Compilation-Output*"
      (insert event)
      )
    )

  (defun latex_compile ()
    (interactive)
    (let ((tex-file (buffer-file-name)))
      (let (( status (process-status "Latex-Compilation-Process")))
        (if(string= "run" status)
            (progn
              (kill-process "Latex-Compilation-Process")
              (message "Old process of compilation was still alive : killed")
              )
          (message "No old process found"))
        )
      (sleep-for 0.05)

      (make-process
       :name "Latex-Compilation-Process"
       :buffer "*Latex-Compilation-Output*"
       :command (split-string (format "/usr/local/texlive/2024/bin/x86_64-linux/pdflatex -shell-escape %s"  tex-file))
       :sentinel #'sentinel_output
       :filter #'filter_function
       )
      ))
  (defun rm_sentinel (process event)
    (if (string= "finished\n" event)
        (progn
          (sleep-for 1)
          (latex_compile)))
    )

  (defun latex-compile-current ()
    (interactive)
    (make-process
     :name "Latex-rm-aux"
     :command (split-string (format "rm -f %s.aux" (file-name-sans-extension (buffer-file-name))) )
     :sentinel #'rm_sentinel
     :filter #'filter_function
     )
    )




(provide '.emacs)
