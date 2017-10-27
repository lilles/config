;; Find debug build of content_shell in the source tree of the current buffer
;; and run it in gdb. Command line parameters to content_shell can be passed
;; through 'args'.
(defun chromium-root-dir ()
  (setq current-dir (file-name-directory (buffer-file-name)))
  (while (and (string< "/" (directory-file-name current-dir))
	      (not (file-exists-p (concat current-dir "out"))))
    (setq current-dir (file-name-directory (directory-file-name current-dir))))
   current-dir)

(defun blink-debug (args)
  (setq exe-file (concat (chromium-root-dir) "out/Debug/content_shell"))
  (if (file-exists-p exe-file)
      (progn
	(split-window-vertically)
	(gdb (concat "gdb -i=mi --args " exe-file " " args)))
    (message "Executable not found!")))

(defun chrome-debug (args)
  (setq exe-file (concat (chromium-root-dir) "out/Debug/chrome"))
  (if (file-exists-p exe-file)
      (progn
	(split-window-vertically)
	(gdb (concat "gdb -i=mi --args " exe-file " " args)))
    (message "Executable not found!")))

;; Debug content_shell in single-process mode.
(defun blink ()
  (interactive)
  (blink-debug "--single-process --no-sandbox"))

;; Debug content_shell with @viewport and <meta viewport> enabled in
;; single-process mode.
(defun blink-vp ()
  (interactive)
  (blink-debug "--single-process --disable-gpu --ignore-gpu-blacklist --enable-experimental-web-platform-features --enable-viewport --enable-fixed-layout --enable-meta-viewport"))

;; Debug content_shell --run-layout-test in single-process mode with a file
;; parameter that specifies which test to run.
(defun blink-test (args)
  (interactive "fFilename: ")
  (blink-debug (concat "--single-process --run-layout-test --no-sandbox " args)))

;; Debug webkit_unit_tests with a filter parameter that specifies which test
;; to run.
(defun blink-unit-test (args)
  (interactive "sFilter: ")
  (setq exe-file (concat (chromium-root-dir) "out/Debug/webkit_unit_tests"))
  (if (file-exists-p exe-file)
      (progn
	(split-window-vertically)
	(gdb (concat "gdb -i=mi --args " exe-file " --gtest_filter=" args)))
    (message "Executable not found!")))

;; MINIDOM BELOW
(defun chromium-root-dir-minidom ()
  (setq current-dir (file-name-directory (buffer-file-name)))
  (while (and (string< "/" (directory-file-name current-dir))
	      (not (file-exists-p (concat current-dir "out_mdom_server"))))
    (setq current-dir (file-name-directory (directory-file-name current-dir))))
   current-dir)

;; Debug webkit_unit_tests with a filter parameter that specifies which test
;; to run.
(defun minidom-unit-test (args)
  (interactive "sFilter: ")
  (setq exe-file (concat (chromium-root-dir-minidom) "out_mdom_server/Debug/browser_web_unit_tests"))
  (if (file-exists-p exe-file)
      (progn
	(split-window-vertically)
	(gdb (concat "gdb -i=mi --args " exe-file " --gtest_filter=" args)))
    (message "Executable not found!")))

(defun blink-filter ()
  (interactive)
  (blink-debug "--single-process --disable-gpu --ignore-gpu-blacklist --force-compositing-mode --enable-accelerated-overflow-scroll --show-composited-layer-borders"))

;; Debug chrome in single-process mode.
(defun chrome ()
  (interactive)
  (chrome-debug "--single-process --no-sandbox"))

;; Debugging keys
(global-set-key (kbd "<f5>") 'gud-cont)
(global-set-key (kbd "<S-f5>") 'gud-kill)
(global-set-key (kbd "<C-S-f5>") 'gud-run)
(global-set-key (kbd "<f8>") 'gud-print)
(global-set-key (kbd "<S-f8>") 'gud-pstar)
(global-set-key (kbd "<f9>") 'gud-break)
(global-set-key (kbd "<S-f9>") 'gud-remove)
(global-set-key (kbd "<f10>") 'gud-next)
(global-set-key (kbd "<C-f10>") 'gud-until)
(global-set-key (kbd "<f11>") 'gud-step)
(global-set-key (kbd "<S-f11>") 'gud-finish)

(setq line-number-mode t)
(setq column-number-mode t)
(setq show-trailing-whitespace t)

(add-hook 'html-mode-hook
	  (lambda ()
	    ;; Default indentation is usually 2 spaces, changing to 4.
	    (set (make-local-variable 'sgml-basic-offset) 4)
	    (set (make-local-variable 'indent-tabs-mode) nil)))

(setq shell-file-name "/bin/bash")
(setq shell-command-switch "-ic")

(defun my-gud-mode-hook ()
  (setq truncate-lines t))

(add-hook 'gud-mode-hook 'my-gud-mode-hook)

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.bs\\'" . html-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Droid Sans Mono" :foundry "unknown" :slant normal :weight normal :height 98 :width normal)))))


;; Morten's stuff below
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-m" 'match-paren)
(global-set-key "\M-p" 'beginning-of-defun)
(global-set-key "\M-n" 'end-of-defun)
(global-set-key "\M-o" 'ff-get-other-file)

(setq cc-other-file-alist
      '(("\\-expected.html$" (".html"))
	("\\-expected.txt$" (".html"))
	("\\.html$" ("-expected.html""-expected.txt"))
	("\\.rej$" (""))
	("\\.c$" (".h"))
	("\\.cc$" (".h"))
	("\\.cpp$" (".h"))
	("\\.h$" (".cpp"".cc"".c"))))

(defun match-paren-insert (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert char."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis"
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))))

(defun git-blame-region (p1 p2)
  "Git-blames the current region."
  (interactive "r")
  (load-library "vc-annotate")
  (let ((filename (buffer-file-name))
	(startline (line-number-at-pos p1))
	(endline (line-number-at-pos p2)))
    (get-buffer-create "*git-blame*")
    (set-buffer "*git-blame*")
    (vc-annotate-mode)
    (shell-command (format "git blame -L%d,%d %s" startline endline filename) "*git-blame*")))

(defun vc-git-annotate-command (file buf &optional rev)
  (let ((name (file-relative-name file)))
    (vc-git-command buf 'async nil "blame" "--date=iso" rev "--" name)))

(load-file "~/config/google-c-style.el")
(add-hook 'c-mode-common-hook 'google-set-c-style)
