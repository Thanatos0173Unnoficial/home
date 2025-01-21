(add-to-list 'package-archives '("melpa"."https://melpa.org/packages/"))
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ccls org-preview-html org-modern clang-format powerline-evil dap-mode company flycheck lsp-mode which-key s powerline evil dash badwolf-theme)))
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

;; clang-format
(require 'clang-format)
(setq clang-format-style "~/.clang-format")

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
)

;; ============================== LSP ==============================

(require 'lsp-mode)
(add-hook 'c-mode-hook 'lsp)

;; ------------------------------ CCLS ------------------------------

(require 'ccls)
(setq ccls-executable "/usr/bin/ccls")

;; ============================== ORG ==============================

(setq org-agenda-files '("/home/thanatos/Sync/todo.org"))
(setq org-agenda-prefix-format '((agenda . "- %c : %b")))
(setq org-agenda-prefix-format '((todo . "- %c : %b")))

;; ============================== FLYCHECK ==============================

(global-flycheck-mode) 

;; ============================== MUTT ==============================

(server-start)
(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))

(defun mutt-launcher (file)
  (interactive)
  (read-answer "Foo "
     '(("yes"  ?y "perform the action")
       ("no"   ?n "skip to the next")
       ("all"  ?! "perform for the rest without more questions")
       ("help" ?h "show help")
       ("quit" ?q "exit"))))

      
 

(provide '.emacs)
