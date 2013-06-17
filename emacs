; color theme
(require 'color-theme)
(require 'uniquify)
(setq
 uniquify-buffer-name-style 'forward
 uniquify-separator "/")

; dinamically add to load-path all folders from emacs-lib-folder
(setq emacs-lib-folder "~/.emacs.d")
(add-to-list 'load-path emacs-lib-folder)


(global-set-key [(control f3)] 'highlight-symbol-at-point)
;; (global-set-key (kbd "M-f3") 'highlight-symbol-next)
(global-set-key (kbd "M-.") 'highlight-symbol-at-point)
(global-set-key (kbd "M-,") 'highlight-symbol-next)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "M-?") 'mark-paragraph)
(global-set-key (kbd "C-z") 'undo-only)
(global-unset-key (kbd "C-/"))

;; (require 'light-symbol)
(require 'highlight-symbol)

(add-to-list 'load-path "~/.emacs.d/flymake-python/")
(require 'flymake)
(load-library "flymake-cursor")
(delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)

(add-to-list 'load-path "~/.emacs.d/yasnippet")
(require 'yasnippet)
(yas-reload-all)

; enable minor modes
(ido-mode 1)
(tabbar-mode 1)
(iswitchb-mode 1)
(desktop-save-mode 1)
(transient-mark-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(visual-line-mode t)
(global-linum-mode 1)

; misc settings
(setq scroll-step 1)
(setq default-tab-width 2)
(tool-bar-mode (quote toggle))
(delete-selection-mode (quote toggle))
(setq inhibit-splash-screen t)
(cua-selection-mode nil)
(setq-default indent-tabs-mode nil)
(show-ws-toggle-show-trailing-whitespace)


; separate customize init file
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

; load required libraries
; (require 'pymacs)
;; (require 'column-marker)

; ropemacs
; (pymacs-load "ropemacs" "rope-")
; (setq ropemacs-enable-autoimport 't)
; (setenv "PYTHONPATH" "$PYTHONPATH:/usr/share/pyshared/rope:/usr/share/pyshared/ropemacs:/usr/share/pyshared/ropemode" t)
; (define-key ropemacs-local-keymap [(meta /)] 'dabbrev-expand)
; (define-key ropemacs-local-keymap [(control /)] 'hippie-expand)
; (define-key ropemacs-local-keymap [(control c) (control /)] 'rope-code-assist)

;; python mode combined with outline minor mode:
(add-hook 'python-mode-hook
          (lambda ()
            (interactive)
            ;; (column-marker-2 79)
;            (setq show-trailing-whitespace t)
            (which-function-mode t)
            (outline-minor-mode 1)
            (yas/minor-mode t)
            ;; (linum-mode t)
            ;; (auto-fill-mode t)
            ;; (require 'ipython)
            ;; (setq py-python-command-args '("-pylab" "-colors" "LightBG"))
            ;; (interactive)
            ;; (column-marker-1 80)
            (setq coding-system-for-write 'utf-8)
            (local-set-key "\C-c\C-a" 'show-all)
            (local-set-key "\C-c\C-q" 'hide-sublevels)
            (local-set-key "\C-c\C-t" 'hide-body)
            (local-set-key "\C-c\C-s" 'outline-toggle-children)))

(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-m" 'newline-and-indent)))

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


;; (when (load "flymake" t)
;;   (defun flymake-pylint-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "~/.emacs.d/flymake-python/pyflymake.py" (list local-file))))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pylint-init)))
;; (add-hook 'find-file-hook 'flymake-find-file-hook)


;; flymake with pyflakes:
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "pychecker" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))
(add-hook 'find-file-hook 'flymake-find-file-hook)

;; enable ipython
;; (setq python-python-command "ipython")
;; (setq python-python-command-args '("-cl" "-colors" "Linux"))
;; (setq ipython-completion-command-string "print(';'.join(__IP.Completer.all_completions('%s')))\n")


;; (when (locate-library "ipython")
;;   (require 'ipython)
;;   (setq py-python-command-args '("-colors" "Linux")))

(setq load-path (cons  "/home/rciorba/erl/r15b02/lib/tools-2.6.8/emacs"
                       load-path))
(setq erlang-root-dir "/home/rciorba/erl/r15b02")
(setq exec-path (cons "/home/rciorba/erl/r15b02/bin" exec-path))
(require 'erlang-start)

;; (defun flymake-erlang-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-create-temp-inplace))
;;          (local-file (file-relative-name temp-file
;;                                          (file-name-directory buffer-file-name))))
;;     (list "eflymake.erl"
;;           (list local-file))))
;; (add-to-list 'flymake-allowed-file-name-masks '("\\.erl\\'" flymake-erlang-init))
;; (setq flymake-log-level 3)
;; (add-hook 'erlang-mode-hook
;;           '(lambda ()
;;              (flymake-mode t)
;;              (define-key erlang-mode-map "\C-m" 'newline-and-indent)))


;; (require 'go-mode-load)
;; (defun flymake-goang-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-create-temp-inplace))
;;          (local-file (file-relative-name temp-file
;;                                          (file-name-directory buffer-file-name))))
;;     (list "6g"
;;           (list local-file))))
;; (add-to-list 'flymake-allowed-file-name-masks '("\\.go\\'" flymake-goang-init))
;; (add-hook 'go-mode-hook
;;           '(lambda ()
;;              (flymake-mode t)
;;              (define-key go-mode-map "\C-m" 'newline-and-indent)))

(server-start)