(defvar mw/chatgpt-cache-dir
  (expand-file-name "~/.cache/mimis/"))

(defun mw/chatgpt--slugify (s)
  "Convert whitespace to dashes for filenames."
  (replace-regexp-in-string "[[:space:]]+" "-" s))

(defun mw/chatgpt--org-path (prompt)
  "Return cache path for PROMPT."
  (expand-file-name
   (concat "chatgpt"
           (mw/chatgpt--slugify prompt)
           ".org")
   mw/chatgpt-cache-dir))

(defun mw/chatgpt--run (prompt output-org)
  "Run chatgpt-cli and convert result to org."
  (let ((tmp-md (make-temp-file "chatgpt-" nil ".md")))

    ;; chatgpt-cli
    (shell-command
     (format
      "echo %s | chatgpt-cli chat > %s"
      (shell-quote-argument prompt)
      (shell-quote-argument tmp-md)))

    ;; markdown -> org
    (shell-command
     (format
      "pandoc -f markdown -t org -o %s %s"
      (shell-quote-argument output-org)
      (shell-quote-argument tmp-md)))

    (delete-file tmp-md)))

(defun mw/truncate-filename (filename max-length)
  "Return FILENAME truncated to MAX-LENGTH characters, keeping start and end.
For example, if file path is long, we keep both the directory start and the basename end."
  (let* ((len (length filename)))
    (if (<= len max-length)
        filename
      (let* ((keep (/ (- max-length 3) 2))
             (start (substring filename 0 keep))
             (end (substring filename (- len keep))))
        (format "%s...%s" start end)))))

(defun mw/chatgpt-open (prompt)
  "Generate or open cached ChatGPT org buffer."
  (interactive "sPrompt: ")

  (let ((org-file (mw/chatgpt--org-path (mw/truncate-filename prompt 100))))

    ;; Ensure cache dir exists
    (make-directory mw/chatgpt-cache-dir t)

    ;; Generate file if missing
    (unless (file-exists-p org-file)
      (mw/chatgpt--run prompt org-file))

    ;; Open file in bottom window
    (let ((buffer (find-file-noselect org-file)))
      (display-buffer buffer))))
