;;; pacfiles-buttons.el --- the buttons of pacfiles-mode --- -*- lexical-binding: t; -*-

;;; Commentary:
;;; Code:


(defun pacfiles--insert-merge-button (file-pair)
  "Insert a button to merge FILE-PAIR.

To determine the file-pair against which FILE will be merged, the extension of FILE is removed."
  (let* ((update-file (car file-pair))
         (base-file (file-name-sans-extension update-file)))
    (insert-text-button "[merge]"
                        'help-echo (format "Start merging '%s' and '%s'."
                                           (file-name-nondirectory update-file)
                                           (file-name-nondirectory base-file))
                        'action `(lambda (_)
                                   (ediff-merge-files ,update-file ,base-file nil
                                                      ;; location of the merged file-pair
                                                      ,(cdr file-pair)))
                        'face 'font-lock-keyword-face
                        'follow-link t)))

(defun pacfiles--insert-view-merge-button (file-pair)
  "Insert a button that displays the merge in FILE-PAIR."
  (let* ((file-update (car file-pair))
         (file-base (file-name-sans-extension file-update))
         (file-merge (cdr file-pair)))
    (insert-text-button "[view]"
                        'help-echo (format "View the merge of '%s' with '%s'."
                                           (file-name-nondirectory file-update)
                                           (file-name-nondirectory file-base))
                        'action `(lambda (_)
                                   (let ((window (split-window-right)))
                                     (select-window window)
                                     (set-window-buffer window
                                      (pacfiles--create-view-buffer
                                       (file-name-nondirectory ,file-base) ,file-merge))))
                        'face 'font-lock-keyword-face
                        'follow-link t)))

(defun pacfiles--insert-diff-button (file-update)
  "Insert a button that displays a diff of the update FILE-UPDATE and its base file."
  (let ((file-base (file-name-sans-extension file-update)))
    (when (file-exists-p file-base)
      (insert-text-button "[diff]"
                          'help-echo (format "Diff '%s' with '%s'."
                                             (file-name-nondirectory file-update)
                                             (file-name-nondirectory file-base))
                          'action `(lambda (_) (ediff-files ,file-update ,file-base))
                          'face 'font-lock-keyword-face
                          'follow-link t))))

(defun pacfiles--insert-apply-button (file-pair)
  "Insert a button that copies the `cdr' of FILE-PAIR to its `car'."
  (let ((merge-file (cdr file-pair))
        (destination-file (car file-pair)))
    (insert-text-button "[merge]"
                        'help-echo (format "Apply the merge of `%s' to the file system."
                                           (file-name-sans-extension (file-name-nondirectory destination-file)))
                        'action `(lambda (_) (message "TODO: Copy `%s' to `%s'" ,merge-file ,destination-file))
                        'face 'font-lock-keyword-face
                        'follow-link t)))

(defun pacfiles--insert-discard-button (file-pair)
  "Insert button that deletes the `cdr' of FILE-PAIR from the file system."
  (let ((merge-file (cdr file-pair))
        (update-file (car file-pair)))
    (insert-text-button "[discard]"
                        'help-echo (format "Delete the merge of `%s' from the file system."
                                           (file-name-sans-extension (file-name-nondirectory update-file)))
                        'action `(lambda (_)
                                   (let ((del-file (pacfiles--add-sudo-maybe ,merge-file :write)))
                                     (when (y-or-n-p (format  "Discard the merge between '%s' and '%s'? "
                                                              ,update-file
                                                              ,(file-name-sans-extension update-file)))
                                       (delete-file del-file)
                                       (message "Merge discarded!")))
                                   (revert-buffer t t))
                        'face 'font-lock-keyword-face
                        'follow-link t)))

(defun pacfiles--insert-footer-buttons ()
  "Insert the `apply all' and `discard all' buttons."
  (insert-text-button "[Apply All]"
                      'help-echo "Write all merged files into the system."
                      'follow-link t
                      'face 'font-lock-keyword-face
                      'action (lambda (_) (message "TODO: implement me")))
  (insert "  ")
  (insert-text-button "[Discard All]"
                      'help-echo "Discard all merged files."
                      'follow-link t
                      'face 'font-lock-keyword-face)
  'action (lambda (_) (message "TODO: implement me")))


(provide 'pacfiles-buttons)
;;; pacfiles-buttons.el ends here
