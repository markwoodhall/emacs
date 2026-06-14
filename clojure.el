;;; clojure.el --- My EMACS Clojure setup  -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; Setup cider and various other clojure related bindings and funtions

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

(use-package clojure-mode
  :ensure t)

(require 'project)

(setq project-vc-extra-root-markers
      '("deps.edn" "project.clj" "bb.edn" "build.boot" "shadow-cljs.edn"))

;; Stop marginalia annotating cider's "Select ClojureScript REPL type:" prompt
;; with face/variable docstrings (e.g. `shadow' → "Basic face for shadowed text").
(with-eval-after-load 'marginalia
  (add-to-list 'marginalia-prompt-categories
               '("\\`Select ClojureScript REPL type" . cider-cljs-repl-type))
  (add-to-list 'marginalia-annotators
               '(cider-cljs-repl-type none)))

(use-package cider
  :ensure t
  :defer t
  :functions
  cider-interactive-eval
  cider-connected-p
  :config
  (setq cider-completion-style 'flex
        cider-eldoc-display-for-symbol-at-point nil
        cider-repl-display-help-banner nil))

(defun mw/nrepl-reset ()
  "Run nrepl dev/reset."
  (interactive)
  (cider-interactive-eval
   "(dev/reset)"))

(defun mw/nrepl-dev ()
  "Run nrepl dev."
  (interactive)
  (cider-interactive-eval
   "(user/dev)"))

(defun mw/nrepl-go ()
  "Run nrepl dev/go."
  (interactive)
  (cider-interactive-eval
   "(dev/go)"))

(defun mw/nrepl-init-db ()
  "Run nrepl DB init."
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/init-schema)"))

(defun mw/nrepl-migrate-db ()
  "Run nrepl DB migrate."
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/migrate-schema)"))
;;; clojure.el ends here
