(setq sql-connection-alist
      '((local (sql-product 'postgres)
               (sql-port 5432)
               (sql-server "localhost"))
        (local-5431 (sql-product 'postgres)
                    (sql-port 5431)
                    (sql-server "localhost"))
        (local-5432 (sql-product 'postgres)
                    (sql-port 5432)
                    (sql-server "localhost"))
        (local-5433 (sql-product 'postgres)
                   (sql-port 5433)
                   (sql-server "localhost"))))

(setq sql-ms-program "sqlcmd")
(setq sql-ms-options '("-w" "400" "-y" "10" "-Y" "10" "-k"))

(with-eval-after-load 'company
  (require 'company-keywords)
  (unless (assq 'sql-interactive-mode company-keywords-alist)
    (push '(sql-interactive-mode . sql-mode) company-keywords-alist))
  (defun mw/sqli-company-setup ()
    (setq-local company-backends
                '((company-keywords company-dabbrev-code company-dabbrev))))
  (add-hook 'sql-interactive-mode-hook #'mw/sqli-company-setup))

(defun mw/auth-source--add-password (host port user password &optional force)
  "Add a netrc entry for HOST/PORT/USER/PASSWORD to ~/.authinfo.gpg.
If FORCE is non-nil, replace any existing entry for the same host/port/user.
Otherwise no-op if an entry already exists."
  (let* ((file (expand-file-name "~/.authinfo.gpg"))
         (port-str (if (numberp port) (number-to-string port) port))
         (line (format "machine %s port %s login %s password %s\n"
                       host port-str user password))
         (pattern (format "^machine %s\\s-+port %s\\s-+login %s\\s-.*\n?"
                          (regexp-quote host)
                          (regexp-quote port-str)
                          (regexp-quote user))))
    (with-temp-buffer
      (when (file-exists-p file)
        (insert-file-contents file))
      (goto-char (point-min))
      (let ((existing (re-search-forward pattern nil t)))
        (cond
         ((and existing (not force))
          (message "Auth entry for %s@%s:%s already in %s — leaving alone"
                   user host port-str file))
         (t
          (when existing
            (delete-region (match-beginning 0) (match-end 0)))
          (goto-char (point-max))
          (unless (or (bobp) (eq (char-before) ?\n))
            (insert "\n"))
          (insert line)
          (let ((epa-file-encrypt-to (or epa-file-encrypt-to user-mail-address)))
            (write-region (point-min) (point-max) file nil 'silent))
          (message "%s password for %s@%s:%s in %s"
                   (if existing "Updated" "Saved") user host port-str file)))))))

(defun mw/sql--connection-form-p (form name)
  "True if FORM is an eval form we generated for sql connection NAME."
  (and (consp form)
       (string-match-p
        (format "(assq '%s sql-connection-alist)"
                (regexp-quote (symbol-name name)))
        (prin1-to-string form))))

(defun mw/sql--dir-locals-has-connection-p (file name)
  "Return non-nil if FILE (a .dir-locals.el) already defines connection NAME."
  (and file
       (file-exists-p file)
       (let ((data (with-temp-buffer
                     (insert-file-contents file)
                     (ignore-errors (read (current-buffer))))))
         (seq-some (lambda (kv)
                     (and (consp kv)
                          (eq (car kv) 'eval)
                          (mw/sql--connection-form-p (cdr kv) name)))
                   (cdr (assq nil data))))))

(defun mw/sql--remove-dir-local-connection (file name)
  "Remove any eval form for connection NAME from FILE."
  (when (file-exists-p file)
    (let* ((data (with-temp-buffer
                   (insert-file-contents file)
                   (read (current-buffer))))
           (nil-cell (assq nil data)))
      (when nil-cell
        (setcdr nil-cell
                (seq-remove
                 (lambda (kv)
                   (and (consp kv)
                        (eq (car kv) 'eval)
                        (mw/sql--connection-form-p (cdr kv) name)))
                 (cdr nil-cell)))
        (when (null (cdr nil-cell))
          (setq data (assq-delete-all nil data))))
      (with-temp-file file
        (let ((print-length nil) (print-level nil))
          (pp data (current-buffer)))))))

;; @note sql-save-connection
(defun mw/sql-save-connection (name)
  "Save the current *SQL* buffer's connection under NAME.
Writes connection metadata (no password) to the project's .dir-locals.el
as an `eval' form that augments `sql-connection-alist', and the password
to ~/.authinfo.gpg via auth-source.

If a connection named NAME already exists in the dir-locals file, prompt
to overwrite (replacing both the dir-locals entry and the auth-source
entry)."
  (interactive
   (list (intern
          (read-string
           "Connection name: "
           (when-let* ((p (project-current))
                       (root (project-root p)))
             (file-name-nondirectory (directory-file-name root)))))))
  (unless (derived-mode-p 'sql-interactive-mode)
    (user-error "Run this from a SQL interactive (*SQL*) buffer"))
  (let* ((product sql-product)
         (server sql-server)
         (port sql-port)
         (database sql-database)
         (user sql-user)
         (password (or sql-password
                       (read-passwd
                        (format "Password for %s@%s:%s (blank to skip): "
                                user server port))))
         (root (or (when-let ((p (project-current))) (project-root p))
                   default-directory))
         (dir-locals-path (expand-file-name dir-locals-file root))
         (exists (mw/sql--dir-locals-has-connection-p dir-locals-path name))
         ;; @note entry
         (entry `(,name
                  (sql-product ',product)
                  ,@(when server   `((sql-server ,server)))
                  ,@(when port     `((sql-port ,port)))
                  ,@(when database `((sql-database ,database)))
                  ,@(when user     `((sql-user ,user)))))
         (form `(let ((conn ',entry))
                  (unless (assq ',name sql-connection-alist)
                    (setq-local sql-connection-alist
                                (cons conn sql-connection-alist))))))
    (when exists
      (unless (yes-or-no-p
               (format "Connection `%s' already saved in %s. Overwrite? "
                       name dir-locals-path))
        (user-error "Aborted — connection not saved"))
      (mw/sql--remove-dir-local-connection dir-locals-path name))
    (let ((default-directory root))
      (save-window-excursion
        (add-dir-local-variable nil 'eval form)
        (save-buffer)
        (kill-buffer)))
    (when (and password (not (string-empty-p password)))
      (mw/auth-source--add-password server port user password exists))
    (message "Connection `%s' %s under %s"
             name (if exists "overwritten" "saved") root)))
