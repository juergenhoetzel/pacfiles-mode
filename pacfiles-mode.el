;;; pacfiles-mode.el --- Definition of the pacfiles Major mode -*- lexical-binding: t; -*-

;;; Commentary:
;;; Code:

(require 'pacfiles-win)

(defvar pacfiles-search-command "find /etc -name '*.pacnew' 2>/dev/null"
  "Command to find .pacnew files.")

(defun pacfiles ()
  "Find and manage pacman backup files in an Arch-based GNU/Linux system."
  (interactive)
  ;; Save the current window configuration so that it can be restored when we are finished.
  (pacfiles//save-window-conf)
  (let ((buffer (get-buffer-create pacfiles--files-buffer-name)))
    (display-buffer buffer '(pacfiles//display-buffer-fullscreen))
    (with-current-buffer buffer
      (pacfiles-mode)
      (pacfiles-revert-buffer t t))))

(defun pacfiles-revert-buffer (&optional ignore-auto noconfirm)
  "Revert the buffer by finding .pacnew files. Ignore IGNORE-AUTO but take into account NOCONFIRM."
  (interactive)
  (with-current-buffer (get-buffer-create pacfiles--files-buffer-name)
    (when (or noconfirm
              (y-or-n-p (format "Reload list of backup pacman files? ")))
      ;; The actual revert mechanism starts here
      (run-hooks 'before-revert-hook)
      (let ((inhibit-read-only t)
            (files (split-string (shell-command-to-string pacfiles-search-command) "\n" t)))
        (delete-region (point-min) (point-max))
        (dolist (file files)
          (insert file "\n"))))))

(define-derived-mode pacfiles-mode special-mode "pacfiles"
  :syntax-table nil
  :abbrev-table nil
  "Major mode for managing .pacnew and. pacsave files."
  (buffer-disable-undo)
  (setq show-trailing-whitespace nil)
  ;; Disable lines numbers.
  (when (bound-and-true-p global-linum-mode)
    (linum-mode -1))
  (when (and (fboundp 'nlinum-mode)
             (bound-and-true-p global-nlinum-mode))
    (nlinum-mode -1))
  (when (and (fboundp 'display-line-numbers-mode)
             (bound-and-true-p global-display-line-numbers-mode))
    (display-line-numbers-mode -1))
  (setq revert-buffer-function #'pacfiles-revert-buffer)
  ;; Set our key-bindings
  (define-key pacfiles-mode-map (kbd "q") #'pacfiles/quit))


(provide 'pacfiles-mode)
;;; pacfiles-mode.el ends here
