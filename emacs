;; -*- mode: elisp
(setq emacs-lib-folder "~/.emacs.d/lisp")
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
(global-unset-key (kbd "C-/"))

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


(require 'flymake)
;; (flymake-mode 0)
(delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)
(load-library "flymake-cursor")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-errline ((((class color)) (:underline "OrangeRed"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))


(add-to-list 'load-path "~/.emacs.d/yasnippet/")
(require 'yasnippet)
;; (yas-reload-all)

; enable minor modes
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
(tool-bar-mode 0)
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
            (column-marker-1 99)
            (setq coding-system-for-write 'utf-8)
            (local-set-key "\C-c\C-a" 'show-all)
            (local-set-key "\C-c\C-q" 'hide-sublevels)
            (local-set-key "\C-c\C-t" 'hide-body)
            (local-set-key "\C-c\C-s" 'outline-toggle-children)
            (define-key python-mode-map "\C-m" 'newline-and-indent)))


;; flymake with pyflakes:
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "~/repos/misc/bin/pychecker" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))
(global-set-key [(control f10)] 'flymake-mode)


(defun flymake-erlang-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name temp-file
                                         (file-name-directory buffer-file-name))))
    (list "eflymake.sh"
          (list local-file))))
(add-to-list 'flymake-allowed-file-name-masks '("\\.erl\\'" flymake-erlang-init))
(setq flymake-log-level 3)
(add-hook 'erlang-mode-hook
          '(lambda ()
             (flymake-mode t)
             (define-key erlang-mode-map "\C-m" 'newline-and-indent)))


;; (require 'go-mode-load)
(defun flymake-golang-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name temp-file
                                         (file-name-directory buffer-file-name))))
    (list "go"
          (list "build" local-file))))
(add-to-list 'flymake-allowed-file-name-masks '("\\.go\\'" flymake-golang-init))
(add-hook 'go-mode-hook
          '(lambda ()
             (flymake-mode t)
             (define-key go-mode-map "\C-m" 'newline-and-indent)))

(server-start)
;; (put 'upcase-region 'disabled nil)
