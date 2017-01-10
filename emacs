;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq emacs-lib-folder "~/.emacs.d/lisp")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(add-to-list 'load-path emacs-lib-folder)
(delete 'Git vc-handled-backends)

;; package repositories
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
       ))


;; general keybindings
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "M-?") 'mark-paragraph)
(global-set-key (kbd "C-z") 'undo-only)
(global-set-key (kbd "<f6>") 'whitespace-cleanup)
(global-unset-key (kbd "C-/"))

(require 'midnight)

(require 'uniquify)
(setq
 uniquify-buffer-name-style 'post-forward
 uniquify-separator ":")
;; ;; (linum ((,class (:foreground, black :background, white))))

(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol-at-point)
;; (global-set-key (kbd "M-f3") 'highlight-symbol-next)
(global-set-key (kbd "M-.") 'highlight-symbol-at-point)
(global-set-key (kbd "M-,") 'highlight-symbol-next)

(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))


(add-hook 'after-init-hook #'global-flycheck-mode)
;; (require 'flymake)
;; (flymake-mode 0)
;; (delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)
;; (load-library "flymake-cursor")

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(flymake-errline ((((class color)) (:underline "OrangeRed"))))
;;  '(flymake-warnline ((((class color)) (:underline "yellow")))))


(setq yas-snippet-dirs "~/.emacs.d/snip")
(require 'yasnippet)
;; (yas-reload-all)

; enable minor modes
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(electric-pair-mode 0)
(ido-mode 1)
(tool-bar-mode 0)
(scroll-bar-mode 0)
;; (tabbar-mode 1)
;; (iswitchb-mode 0)
(desktop-save-mode 1)
(transient-mark-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(visual-line-mode 0)
(global-linum-mode 0)

;; ; misc settings
;; (setq scroll-step 1)
;; (setq default-tab-width 2)
;; (tool-bar-mode (quote toggle))
(delete-selection-mode 1)
;; (setq inhibit-splash-screen t)
(cua-selection-mode nil)
(setq-default indent-tabs-mode nil)
;; (show-ws-toggle-show-trailing-whitespace)


;; ; separate customize init file
(setq custom-file "~/.emacs-custom")
(load custom-file)

;; Don't make backup files next to the source, put them in a single place
(setq backup-directory-alist
      (quote (("." . "~/.emacs-backups"))))


(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
         (buffer (car list)))
    (while buffer
      (when (and (buffer-file-name buffer)
                 (not (buffer-modified-p buffer)))
        (set-buffer buffer)
        (revert-buffer t t t))
      (setq list (cdr list))
      (setq buffer (car list))))
  (message "Refreshed open files"))
(global-set-key [(control shift f5)] 'revert-all-buffers)


; move selected text up/down
(defun move-text-internal (arg)
   (cond
    ((and mark-active transient-mark-mode)
     (if (> (point) (mark))
        (exchange-point-and-mark))
     (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
       (forward-line arg)
       (move-to-column column t)
       (set-mark (point))
       (insert text)
       (exchange-point-and-mark)
       (setq deactivate-mark nil)))
    (t
     (beginning-of-line)
     (when (or (> arg 0) (not (bobp)))
       (forward-line)
       (when (or (< arg 0) (not (eobp)))
        (transpose-lines arg))
       (forward-line -1)))))
(defun move-text-down (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines down."
   (interactive "*p")
   (move-text-internal arg))
(defun move-text-up (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines up."
   (interactive "*p")
   (move-text-internal (- arg)))
(global-set-key [\M-\S-up] 'move-text-up)
(global-set-key [\M-\S-down] 'move-text-down)


;; (defun electric-pair ()
;;   "If at end of line, insert character pair without surrounding spaces.
;;     Otherwise, just insert the typed character."
;;   (interactive)
;;   (let (parens-require-spaces) (insert-pair)))

(require 'virtualenvwrapper)
(venv-initialize-interactive-shells) ;; if you want interactive shell support
(venv-initialize-eshell) ;; if you want eshell support
(setq venv-location "/home/rciorba/.venvs/")


(defun project-directory (buffer-name)
  "Returns the root directory of the project that contains the
given buffer. Any directory with a .git or .jedi file/directory
is considered to be a project root."
  (interactive)
  (let ((root-dir (file-name-directory buffer-name)))
    (while (and root-dir
                (not (file-exists-p (concat root-dir ".git")))
                (not (file-exists-p (concat root-dir ".jedi"))))
      (setq root-dir
            (if (equal root-dir "/")
                nil
              (file-name-directory (directory-file-name root-dir)))))
    root-dir))

(defun project-name (buffer-name)
  "Returns the name of the project that contains the given buffer."
  (let ((root-dir (project-directory buffer-name)))
    (if root-dir
        (file-name-nondirectory
         (directory-file-name root-dir))
      nil)))

(defun jedi-setup-venv ()
  "Activates the virtualenv of the current buffer."
  (let ((project-name (project-name buffer-file-name)))
    (when project-name (venv-workon project-name))))

(setq jedi:setup-keys t)
;; (setq jedi:complete-on-dot t)
(add-hook 'python-mode-hook 'jedi-setup-venv)
(add-hook 'python-mode-hook 'jedi:setup)


;; python mode combined with outline minor mode:
(add-hook 'python-mode-hook
          (lambda ()
            (interactive)
            ;; (column-marker-2 79)
            (which-function-mode t)
            (outline-minor-mode 1)
            (yas/minor-mode t)
            ;; (linum-mode t)
            ;; (auto-fill-mode t)
            ;; (require 'ipython)
            ;; (setq py-python-command-args '("-pylab" "-colors" "LightBG"))
            ;; (interactive)
            ;; (column-marker-1 99)
            (setq coding-system-for-write 'utf-8)
            (local-set-key (kbd "C-c C-a") 'show-all)
            (local-set-key (kbd "C-c C-q") 'hide-sublevels)
            (local-set-key (kbd "C-c C-t") 'hide-body)
            (local-set-key (kbd "C-c C-s") 'hide-subtree)
            (local-set-key (kbd "C-c C-v") 'show-subtree)
            ;; electric pair for python
            ;; (define-key python-mode-map "\"" 'electric-pair)
            ;; (define-key python-mode-map "\'" 'electric-pair)
            ;; (define-key python-mode-map "(" 'electric-pair)
            ;; (define-key python-mode-map "[" 'electric-pair)
            ;; (define-key python-mode-map "{" 'electric-pair)

            (define-key python-mode-map "\C-j" 'newline-and-indent)))


;; ;; flymake with pyflakes:
;; (when (load "flymake" t)
;;   (defun flymake-pyflakes-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "~/repos/misc/bin/pychecker" (list local-file))))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pyflakes-init)))
(global-set-key [(control f10)] 'flycheck-mode)


;; (defun flymake-erlang-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-create-temp-inplace))
;;          (local-file (file-relative-name temp-file
;;                                          (file-name-directory buffer-file-name))))
;;     (list "eflymake.sh"
;;           (list local-file))))
;; (add-to-list 'flymake-allowed-file-name-masks '("\\.erl\\'" flymake-erlang-init))
;; (setq flymake-log-level 3)
;; (add-hook 'erlang-mode-hook
;;           '(lambda ()
;;              (flymake-mode t)
;;              (define-key erlang-mode-map "\C-m" 'newline-and-indent)))

(setq erlang-mode-hook
    (function (lambda ()
                (setq electric-indent-inhibit t))))

;; ;; (require 'go-mode-load)
;; (defun flymake-golang-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-create-temp-inplace))
;;          (local-file (file-relative-name temp-file
;;                                          (file-name-directory buffer-file-name))))
;;     (list "go"
;;           (list "build" local-file))))
;; (add-to-list 'flymake-allowed-file-name-masks '("\\.go\\'" flymake-golang-init))
(add-hook 'go-mode-hook
          '(lambda ()
             ;; (flymake-mode t)
             (define-key go-mode-map "\C-m" 'newline-and-indent)))

(server-start)
(put 'downcase-region 'disabled nil)


;; (defun erlang-indent-line ()
;;   "Indent current line as Erlang code.
;; Return the amount the indentation changed by."
;;   (let ((pos (- (point-max) (point)))
;; 	indent beg
;; 	shift-amt)
;;     (beginning-of-line 1)
;;     (setq beg (point))
;;     (skip-chars-forward " \t")
;;     (cond ((looking-at "%")
;; 	   (setq indent (funcall comment-indent-function))
;; 	   (setq shift-amt (- indent (current-column))))
;; 	  (t
;; 	   (setq indent (erlang-calculate-indent))
;; 	   (cond ((null indent)
;; 		  (setq indent (current-indentation)))
;; 		 ((eq indent t)
;; 		  ;; This should never occur here.
;; 		  (error "Erlang mode error"))
;; 		 ;;((= (char-syntax (following-char)) ?\))
;; 		 ;; (setq indent (1- indent)))
;; 		 )
;; 	   (setq shift-amt (- indent (current-column)))))
;;     (if (zerop shift-amt)
;; 	nil
;;       (delete-region beg (point))
;;       (indent-to indent))
;;     ;; If initial point was within line's indentation, position
;;     ;; after the indentation. Else stay at same point in text.
;;     (if (> (- (point-max) pos) (point))
;; 	(goto-char (- (point-max) pos)))
;;     shift-amt))

(setq latex-run-command "pdflatex")

(setq php-template-compatibility nil)
(put 'upcase-region 'disabled nil)
