;;; macs.el --- My EMACS config -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; Extension of my emacs configuration just for org mode

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

;; @note default-binding
(global-set-key (kbd "C-c c") #'org-capture)

;; @note presentation
(add-hook 'org-mode-hook #'visual-line-mode)

(defun my/daily-file ()
  (expand-file-name
    (format-time-string "journal/%Y-%m-%d.org")
    "~/notes"))

(with-eval-after-load 'org-capture
  (add-to-list 'org-capture-templates
               '("j" "Journal" entry
                 (file my/daily-file)
                 "\n* %?\n")))

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)

(use-package org-bullets
  :ensure t
  :after org)

(add-hook 'org-mode-hook 'org-bullets-mode)

(require 'ob-clojure)
(setq org-babel-clojure-backend 'babashka)
(with-eval-after-load 'org
(org-babel-do-load-languages
 'org-babel-load-languages
 '((sql . t)
   (clojure . t)
   (shell . t))))

(nvmap :keymaps 'org-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")
  "m e e" '(org-babel-execute-src-block :which-key "Execute source block"))

(setq browse-url-browser-function #'eww-browse-url)
