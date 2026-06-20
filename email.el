;;; email.el --- mu4e over an mbsync maildir, sending via smtpmail -*- lexical-binding: t; -*-

(use-package mu4e
  :ensure nil
  :commands (mu4e mu4e-compose-new)
  :config

  ;; ── Fetching: mbsync syncs, mu4e re-indexes ──────────────────────
  (setq mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300
        mu4e-change-filenames-when-moving t)   ; REQUIRED with mbsync

  ;; ── List view ────────────────────────────────────────────────────
  (setq mu4e-headers-fields '((:human-date . 12)
                              (:flags       .  6)
                              (:from        . 22)
                              (:subject     . nil))
        mu4e-confirm-quit nil)

  ;; ── Sending via Emacs' built-in SMTP ─────────────────────────────
  (setq message-send-mail-function #'smtpmail-send-it)

  ;; ── Three accounts, switched by maildir, creds keyed by login ─────
  ;; NOTE: the Sent/Drafts/Trash/refile names below are Gmail's IMAP
  ;; defaults. If your mbsync renames them, set each to whatever actually
  ;; appears under `ls ~/mail/<account>'.
  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "personal"
          :match-func
          (lambda (msg)
            (when msg (string-prefix-p "/personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address     . "mark.woodhall@gmail.com")
                  (user-full-name        . "Mark Woodhall")
                  (mu4e-sent-folder      . "/personal/[Gmail]/Sent Mail")
                  (mu4e-drafts-folder    . "/personal/[Gmail]/Drafts")
                  (mu4e-trash-folder     . "/personal/[Gmail]/Trash")
                  (mu4e-refile-folder    . "/personal/[Gmail]/All Mail")
                  (smtpmail-smtp-server  . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type  . starttls)
                  (smtpmail-smtp-user    . "mark.woodhall@gmail.com")))

         (make-mu4e-context
          :name "jhj"
          :match-func
          (lambda (msg)
            (when msg (string-prefix-p "/jhj" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address     . "mark@jhj.ltd")
                  (user-full-name        . "Mark Woodhall")
                  (mu4e-sent-folder      . "/jhj/[Gmail]/Sent Mail")
                  (mu4e-drafts-folder    . "/jhj/[Gmail]/Drafts")
                  (mu4e-trash-folder     . "/jhj/[Gmail]/Bin")
                  (mu4e-refile-folder    . "/jhj/[Gmail]/All Mail")
                  (smtpmail-smtp-server  . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type  . starttls)
                  (smtpmail-smtp-user    . "mark@jhj.ltd")))

         (make-mu4e-context
          :name "pelly"
          :match-func
          (lambda (msg)
            (when msg (string-prefix-p "/pelly" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address     . "mark@pelly.pro")
                  (user-full-name        . "Mark Woodhall")
                  (mu4e-sent-folder      . "/pelly/[Gmail]/Sent Mail")
                  (mu4e-drafts-folder    . "/pelly/[Gmail]/Drafts")
                  (mu4e-trash-folder     . "/pelly/[Gmail]/Bin")
                  (mu4e-refile-folder    . "/pelly/[Gmail]/All Mail")
                  (smtpmail-smtp-server  . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type  . starttls)
                  (smtpmail-smtp-user    . "mark@pelly.pro")))))

  (setq mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask)

  ;; ── Folder jump-keys (the chars are arbitrary — pick what you like) ─
  (setq mu4e-maildir-shortcuts '((:maildir "/personal/Inbox" :key ?p)
                                 (:maildir "/jhj/Inbox"      :key ?j)
                                 (:maildir "/pelly/Inbox"    :key ?y)))

  ;; ── Compose like your aerc work account: no hard wrap, let the
  ;;    recipient reflow (matches textwidth=0) ────────────────────────
  (add-hook 'mu4e-compose-mode-hook (lambda () (auto-fill-mode -1))))

(use-package org-mime
  :after org
  :ensure t)

(provide 'email)
;;; email.el ends here
