;;; simp-project-rgrep.el --- simp project enhanced rgrepping

;; Copyright (C) 2011-2013 @re5et

;; Author: atom smith
;; URL: https://github.com/re5et/simp
;; Created: 22 Dec 2011
;; Version: 0.4.0
;; Keywords: project grep find

;; This file is NOT part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 3, or (at your option) any later
;; version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs; see the file COPYING, or type `C-h C-c'. If not,
;; write to the Free Software Foundation at this address:

;; Free Software Foundation
;; 51 Franklin Street, Fifth Floor
;; Boston, MA 02110-1301
;; USA

;;; Commentary

;; Provides a better project rgrepping experience by pushing the project's
;; ignored paths into the excluded paths the rgrep find command uses.

;; The simp-project-rgrep-thing-at-point is especially handy for quickly
;; navigating projects with rgrep.

(require 'simp-project)

(defun simp-project-buffer-rgrep (fn)
  "add project's ignored paths to the rgrep's ignored"
  (let* ((default-directory (simp-project-root))
         (original-ignored-dirs grep-find-ignored-directories)
         (original-ignored-files grep-find-ignored-files)
         (grep-find-ignored-directories
          (condition-case nil
              (append original-ignored-dirs
                      (mapcar
                       (lambda (dir)
                         (symbol-name dir))
                       (simp-project-ignored-directories)))
            (error original-ignored-dirs)))
         (grep-find-ignored-files
          (condition-case nil
              (append original-ignored-files
                      (mapcar
                       (lambda (file)
                         (symbol-name file))
                       (simp-project-ignored-files)))
            (error original-ignored-files))))
    (funcall fn)))

(defun simp-project-rgrep ()
  "Interactively call rgrep with the project's ignored
directories excluded"
  (interactive)
  (simp-project-buffer-rgrep
   (lambda ()
     (call-interactively 'rgrep))))

(defun simp-project-rgrep-dwim ()
  "Interactively call rgrep with the project's ignored
directories excluded, search all file types for the
current region, or the (symbol) thing at point"
  (interactive)
  (simp-project-buffer-rgrep
   (lambda ()
     (grep-compute-defaults)
     (let ((search-for (if (region-active-p)
                           (buffer-substring (region-beginning) (region-end))
                         (thing-at-point 'symbol))))
       (if search-for
           (rgrep search-for "*" (simp-project-root))
         (message "Failed to rgrep. No active region, and point not near a symbol"))))))

(defalias 'simp-project-rgrep-thing-at-point 'simp-project-rgrep-dwim)

(provide 'simp-project-rgrep)

;;; simp-project-rgrep.el ends here
