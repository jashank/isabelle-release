;;; packages.el --- isabelle layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Mathias Fleury, Sophie
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `isabelle-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `isabelle/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `isabelle/pre-init-PACKAGE' and/or
;;   `isabelle/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst isabelle-packages
  '(
    dash
    yasnippet
    (isar-mode :location local)
    (lsp-isar :location local))
  "The list of Lisp packages required by the isabelle layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")


(defun isabelle/init-dash ()
  (use-package dash
    :defer t))

(defun isabelle/post-init-yasnippet ()
  (push (concat lsp-isar-path-to-isabelle "/src/Tools/emacs-lsp/yasnippet") yas-snippet-dirs))

(defun isabelle/init-isar-mode ()
  (use-package isar-mode
    :mode ("\\.thy\\'" . isar-mode)))

(defun isabelle/pre-init-lsp-isar ()
  ;;(setq lsp-isabelle-options (list "-d" "$AFP" "-d" "$ISAFOL/Saturation_Framework" "-S" "Saturation_Framework"
  ;;                                 "-v" "-L" "/tmp/isabelle"))
  ;;(setq lsp-isar-path-to-isabelle "/home/zmaths/Documents/isabelle/isabelle2018-vsce")
  (setq isar-symbol-shortcuts
  '(("\\/" . "\\<or>")
    ("/\\" . "\\<and>")
    ("+O" . "\\<oplus>")
    ("-O" . "\\<ominus>")
    ("xO" . "\\<otimes>")
    ("/O" . "\\<oslash>")
    (".O" . "\\<odot>")
    ("|+" . "\\<dagger>")
    ("|++" . "\\<ddagger>")
    ("<=" . "\\<le>")
    ("|-" . "\\<turnstile>")
    (">=" . "\\<ge>")
    ("-|" . "\\<stileturn>")
    ("||" . "\\<parallel>")
    ("==" . "\\<equiv>")
    ("~=" . "\\<noteq>")
    ("~:" . "\\<notin>")
    ("~~~" . "\\<notapprox>")
    ("~~" . "\\<approx>")
    ("~==" . "\\<cong>")
    ("|<>|" . "\\<bowtie>")
    ("|=" . "\\<Turnstile>")
    ("=." . "\\<doteq>")
    ("_|_" . "\\<bottom>")
    ("</" . "\\<notle>")
    ("~>=" . "\\<notge>")
    ("==/" . "\\<notequiv>")
    ("~/" . "\\<notsim>")
    ("~=/" . "\\<notsimeq>")
    ("~~/" . "\\<notsimeq>")
    ("<-" . "\\<leftarrow>")
    ("<=" . "\\<Leftarrow>")
    ("->" . "\\<rightarrow>")
    ;;("=>" . "\\<Rightarrow>")
    ("<->" . "\\<leftrightarrow>")
    ("<-->" . "\\<longleftrightarrow>")
    ("<=>" . "\\<Leftrightarrow>")
    ("|->" . "\\<mapsto>")
    ("<--" . "\\<longleftarrow>")
    ("<==" . "\\<Longleftarrow>")
    ("-->" . "\\<longrightarrow>")
    ;;("==>" . "\\<Longrightarrow>")
    ("<==>" . "\\<Longleftrightarrow>")
    ("|-->" . "\\<longmapsto>")
    ("<->" . "\\<longleftrightarrow>")
    ("<<" . "\\<guillemotleft>")
    (">>" . "\\<guillemotright>")
    ("<>" . "\\<diamond>")
    ("[|" . "\\<lbrakk>")
    ("|]" . "\\<rbrakk>")
    ("{|" . "\\<lbrace>")
    ("|}" . "\\<rbrace>")
    ("(|" . "\\<lparr>")
    ("|)" . "\\<rparr>")
    ;; useful for unicode-tokens-replace-shortcuts
    ("ALL" . "\\<forall>")
    ("EX"  . "\\<exists>")
    ("!!"  . "\\<And>")
    ("~"  . "\\<not>")
    ;("!"  . "\\<forall>") makes it impossible to type ! as in intro!:
    ;("?"  . "\\<exists>")
    ("(="  . "\\<subseteq>")
    ("__"  . "\\<^sub>")
    ("^^"  . "\\<^sup>")
    ;; extra misc, switch them off if you don't like them
    ;("|>" . "\\<triangleright>") ; clashes with ML parsing combinator
    ("<|" . "\\<triangleleft>")))
  )

(defun isabelle/init-lsp-isar ()
  (use-package lsp-isar
    ;:hook
    ;((isar-mode-hook . lsp-isar-enable))
    :config
    (setq lsp-response-timeout 1200)
    (setq lsp-restart 'ignore)
    (setq lsp-prefer-flymake nil)
    )
  (add-hook 'isar-mode-hook 'flycheck-mode)
  (add-hook 'isar-mode-hook 'lsp-isar-define-client-and-start)

  (add-hook 'lsp-isar-init-hook 'lsp-isar-open-output-and-progress-right-spacemacs)
 )


;;; packages.el ends here
