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
