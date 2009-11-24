;;
;; Keyword classification tables for Isabelle/Isar.
;; Generated from Pure + Pure-ProofGeneral + HOL + HOLCF + IOA + HOL-Boogie + HOL-Nominal + HOL-Statespace.
;; *** DO NOT EDIT *** DO NOT EDIT *** DO NOT EDIT ***
;;

(defconst isar-keywords-major
  '("\\."
    "\\.\\."
    "Isabelle\\.command"
    "Isar\\.begin_document"
    "Isar\\.define_command"
    "Isar\\.edit_document"
    "Isar\\.end_document"
    "ML"
    "ML_command"
    "ML_prf"
    "ML_val"
    "ProofGeneral\\.inform_file_processed"
    "ProofGeneral\\.inform_file_retracted"
    "ProofGeneral\\.kill_proof"
    "ProofGeneral\\.pr"
    "ProofGeneral\\.process_pgip"
    "ProofGeneral\\.restart"
    "ProofGeneral\\.undo"
    "abbreviation"
    "also"
    "apply"
    "apply_end"
    "arities"
    "assume"
    "atom_decl"
    "atp_info"
    "atp_kill"
    "atp_messages"
    "atp_minimize"
    "attribute_setup"
    "automaton"
    "ax_specification"
    "axclass"
    "axiomatization"
    "axioms"
    "back"
    "boogie_end"
    "boogie_open"
    "boogie_status"
    "boogie_vc"
    "by"
    "cannot_undo"
    "case"
    "cd"
    "chapter"
    "class"
    "class_deps"
    "classes"
    "classrel"
    "code_abort"
    "code_class"
    "code_const"
    "code_datatype"
    "code_deps"
    "code_include"
    "code_instance"
    "code_library"
    "code_module"
    "code_modulename"
    "code_monad"
    "code_pred"
    "code_reserved"
    "code_thms"
    "code_type"
    "coinductive"
    "coinductive_set"
    "commit"
    "constdefs"
    "consts"
    "consts_code"
    "context"
    "corollary"
    "cpodef"
    "datatype"
    "declaration"
    "declare"
    "def"
    "defaultsort"
    "defer"
    "defer_recdef"
    "definition"
    "defs"
    "disable_pr"
    "display_drafts"
    "domain"
    "domain_isomorphism"
    "done"
    "enable_pr"
    "end"
    "equivariance"
    "exit"
    "export_code"
    "extract"
    "extract_type"
    "finalconsts"
    "finally"
    "find_consts"
    "find_theorems"
    "fix"
    "fixpat"
    "fixrec"
    "from"
    "full_prf"
    "fun"
    "function"
    "global"
    "guess"
    "have"
    "header"
    "help"
    "hence"
    "hide"
    "inductive"
    "inductive_cases"
    "inductive_set"
    "init_toplevel"
    "instance"
    "instantiation"
    "interpret"
    "interpretation"
    "judgment"
    "kill"
    "kill_thy"
    "lemma"
    "lemmas"
    "let"
    "linear_undo"
    "local"
    "local_setup"
    "locale"
    "method_setup"
    "moreover"
    "new_domain"
    "next"
    "nitpick"
    "nitpick_params"
    "no_notation"
    "no_syntax"
    "no_translations"
    "nominal_datatype"
    "nominal_inductive"
    "nominal_inductive2"
    "nominal_primrec"
    "nonterminals"
    "normal_form"
    "notation"
    "note"
    "obtain"
    "oops"
    "oracle"
    "overloading"
    "parse_ast_translation"
    "parse_translation"
    "pcpodef"
    "pr"
    "prefer"
    "presume"
    "pretty_setmargin"
    "prf"
    "primrec"
    "print_abbrevs"
    "print_antiquotations"
    "print_ast_translation"
    "print_atps"
    "print_attributes"
    "print_binds"
    "print_cases"
    "print_claset"
    "print_classes"
    "print_codeproc"
    "print_codesetup"
    "print_commands"
    "print_configs"
    "print_context"
    "print_drafts"
    "print_facts"
    "print_induct_rules"
    "print_interps"
    "print_locale"
    "print_locales"
    "print_methods"
    "print_orders"
    "print_rules"
    "print_simpset"
    "print_statement"
    "print_syntax"
    "print_theorems"
    "print_theory"
    "print_trans_rules"
    "print_translation"
    "proof"
    "prop"
    "pwd"
    "qed"
    "quickcheck"
    "quickcheck_params"
    "quit"
    "realizability"
    "realizers"
    "recdef"
    "recdef_tc"
    "record"
    "refute"
    "refute_params"
    "remove_thy"
    "rep_datatype"
    "repdef"
    "sect"
    "section"
    "setup"
    "show"
    "simproc_setup"
    "sledgehammer"
    "sorry"
    "specification"
    "statespace"
    "subclass"
    "sublocale"
    "subsect"
    "subsection"
    "subsubsect"
    "subsubsection"
    "syntax"
    "term"
    "termination"
    "text"
    "text_raw"
    "then"
    "theorem"
    "theorems"
    "theory"
    "thm"
    "thm_deps"
    "thus"
    "thy_deps"
    "touch_thy"
    "translations"
    "txt"
    "txt_raw"
    "typ"
    "typed_print_translation"
    "typedecl"
    "typedef"
    "types"
    "types_code"
    "ultimately"
    "undo"
    "undos_proof"
    "unfolding"
    "unused_thms"
    "use"
    "use_thy"
    "using"
    "value"
    "values"
    "welcome"
    "with"
    "{"
    "}"))

(defconst isar-keywords-minor
  '("actions"
    "advanced"
    "and"
    "assumes"
    "attach"
    "avoids"
    "begin"
    "binder"
    "compose"
    "congs"
    "constrains"
    "contains"
    "defines"
    "file"
    "fixes"
    "for"
    "hide_action"
    "hints"
    "identifier"
    "if"
    "imports"
    "in"
    "infix"
    "infixl"
    "infixr"
    "initially"
    "inputs"
    "internals"
    "is"
    "lazy"
    "module_name"
    "monos"
    "morphisms"
    "notes"
    "obtains"
    "open"
    "output"
    "outputs"
    "overloaded"
    "permissive"
    "pervasive"
    "post"
    "pre"
    "rename"
    "restrict"
    "shows"
    "signature"
    "states"
    "structure"
    "to"
    "transitions"
    "transrel"
    "unchecked"
    "uses"
    "where"))

(defconst isar-keywords-control
  '("Isabelle\\.command"
    "Isar\\.begin_document"
    "Isar\\.define_command"
    "Isar\\.edit_document"
    "Isar\\.end_document"
    "ProofGeneral\\.inform_file_processed"
    "ProofGeneral\\.inform_file_retracted"
    "ProofGeneral\\.kill_proof"
    "ProofGeneral\\.process_pgip"
    "ProofGeneral\\.restart"
    "ProofGeneral\\.undo"
    "cannot_undo"
    "exit"
    "init_toplevel"
    "kill"
    "linear_undo"
    "quit"
    "undo"
    "undos_proof"))

(defconst isar-keywords-diag
  '("ML_command"
    "ML_val"
    "ProofGeneral\\.pr"
    "atp_info"
    "atp_kill"
    "atp_messages"
    "atp_minimize"
    "boogie_status"
    "cd"
    "class_deps"
    "code_deps"
    "code_thms"
    "commit"
    "disable_pr"
    "display_drafts"
    "enable_pr"
    "export_code"
    "find_consts"
    "find_theorems"
    "full_prf"
    "header"
    "help"
    "kill_thy"
    "nitpick"
    "normal_form"
    "pr"
    "pretty_setmargin"
    "prf"
    "print_abbrevs"
    "print_antiquotations"
    "print_atps"
    "print_attributes"
    "print_binds"
    "print_cases"
    "print_claset"
    "print_classes"
    "print_codeproc"
    "print_codesetup"
    "print_commands"
    "print_configs"
    "print_context"
    "print_drafts"
    "print_facts"
    "print_induct_rules"
    "print_interps"
    "print_locale"
    "print_locales"
    "print_methods"
    "print_orders"
    "print_rules"
    "print_simpset"
    "print_statement"
    "print_syntax"
    "print_theorems"
    "print_theory"
    "print_trans_rules"
    "prop"
    "pwd"
    "quickcheck"
    "refute"
    "remove_thy"
    "sledgehammer"
    "term"
    "thm"
    "thm_deps"
    "thy_deps"
    "touch_thy"
    "typ"
    "unused_thms"
    "use_thy"
    "value"
    "values"
    "welcome"))

(defconst isar-keywords-theory-begin
  '("theory"))

(defconst isar-keywords-theory-switch
  '())

(defconst isar-keywords-theory-end
  '("end"))

(defconst isar-keywords-theory-heading
  '("chapter"
    "section"
    "subsection"
    "subsubsection"))

(defconst isar-keywords-theory-decl
  '("ML"
    "abbreviation"
    "arities"
    "atom_decl"
    "attribute_setup"
    "automaton"
    "axclass"
    "axiomatization"
    "axioms"
    "boogie_end"
    "boogie_open"
    "class"
    "classes"
    "classrel"
    "code_abort"
    "code_class"
    "code_const"
    "code_datatype"
    "code_include"
    "code_instance"
    "code_library"
    "code_module"
    "code_modulename"
    "code_monad"
    "code_reserved"
    "code_type"
    "coinductive"
    "coinductive_set"
    "constdefs"
    "consts"
    "consts_code"
    "context"
    "datatype"
    "declaration"
    "declare"
    "defaultsort"
    "defer_recdef"
    "definition"
    "defs"
    "domain"
    "domain_isomorphism"
    "equivariance"
    "extract"
    "extract_type"
    "finalconsts"
    "fixpat"
    "fixrec"
    "fun"
    "global"
    "hide"
    "inductive"
    "inductive_set"
    "instantiation"
    "judgment"
    "lemmas"
    "local"
    "local_setup"
    "locale"
    "method_setup"
    "new_domain"
    "nitpick_params"
    "no_notation"
    "no_syntax"
    "no_translations"
    "nominal_datatype"
    "nonterminals"
    "notation"
    "oracle"
    "overloading"
    "parse_ast_translation"
    "parse_translation"
    "primrec"
    "print_ast_translation"
    "print_translation"
    "quickcheck_params"
    "realizability"
    "realizers"
    "recdef"
    "record"
    "refute_params"
    "repdef"
    "setup"
    "simproc_setup"
    "statespace"
    "syntax"
    "text"
    "text_raw"
    "theorems"
    "translations"
    "typed_print_translation"
    "typedecl"
    "types"
    "types_code"
    "use"))

(defconst isar-keywords-theory-script
  '("inductive_cases"))

(defconst isar-keywords-theory-goal
  '("ax_specification"
    "boogie_vc"
    "code_pred"
    "corollary"
    "cpodef"
    "function"
    "instance"
    "interpretation"
    "lemma"
    "nominal_inductive"
    "nominal_inductive2"
    "nominal_primrec"
    "pcpodef"
    "recdef_tc"
    "rep_datatype"
    "specification"
    "subclass"
    "sublocale"
    "termination"
    "theorem"
    "typedef"))

(defconst isar-keywords-qed
  '("\\."
    "\\.\\."
    "by"
    "done"
    "sorry"))

(defconst isar-keywords-qed-block
  '("qed"))

(defconst isar-keywords-qed-global
  '("oops"))

(defconst isar-keywords-proof-heading
  '("sect"
    "subsect"
    "subsubsect"))

(defconst isar-keywords-proof-goal
  '("have"
    "hence"
    "interpret"))

(defconst isar-keywords-proof-block
  '("next"
    "proof"))

(defconst isar-keywords-proof-open
  '("{"))

(defconst isar-keywords-proof-close
  '("}"))

(defconst isar-keywords-proof-chain
  '("finally"
    "from"
    "then"
    "ultimately"
    "with"))

(defconst isar-keywords-proof-decl
  '("ML_prf"
    "also"
    "let"
    "moreover"
    "note"
    "txt"
    "txt_raw"
    "unfolding"
    "using"))

(defconst isar-keywords-proof-asm
  '("assume"
    "case"
    "def"
    "fix"
    "presume"))

(defconst isar-keywords-proof-asm-goal
  '("guess"
    "obtain"
    "show"
    "thus"))

(defconst isar-keywords-proof-script
  '("apply"
    "apply_end"
    "back"
    "defer"
    "prefer"))

(provide 'isar-keywords)
