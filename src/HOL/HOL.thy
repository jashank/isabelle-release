(*  Title:      HOL/HOL.thy
    ID:         $Id$
    Author:     Tobias Nipkow, Markus Wenzel, and Larry Paulson
*)

header {* The basis of Higher-Order Logic *}

theory HOL
imports CPure
uses ("simpdata.ML") "Tools/res_atpset.ML"
begin

subsection {* Primitive logic *}

subsubsection {* Core syntax *}

classes type
defaultsort type

global

typedecl bool

arities
  bool :: type
  "fun" :: (type, type) type

judgment
  Trueprop      :: "bool => prop"                   ("(_)" 5)

consts
  Not           :: "bool => bool"                   ("~ _" [40] 40)
  True          :: bool
  False         :: bool
  arbitrary     :: 'a
  undefined     :: 'a

  The           :: "('a => bool) => 'a"
  All           :: "('a => bool) => bool"           (binder "ALL " 10)
  Ex            :: "('a => bool) => bool"           (binder "EX " 10)
  Ex1           :: "('a => bool) => bool"           (binder "EX! " 10)
  Let           :: "['a, 'a => 'b] => 'b"

  "="           :: "['a, 'a] => bool"               (infixl 50)
  &             :: "[bool, bool] => bool"           (infixr 35)
  "|"           :: "[bool, bool] => bool"           (infixr 30)
  -->           :: "[bool, bool] => bool"           (infixr 25)

local

consts
  If            :: "[bool, 'a, 'a] => 'a"           ("(if (_)/ then (_)/ else (_))" 10)


subsubsection {* Additional concrete syntax *}

notation (output)
  "op ="  (infix "=" 50)

abbreviation
  not_equal     :: "['a, 'a] => bool"               (infixl "~=" 50)
  "x ~= y == ~ (x = y)"

notation (output)
  not_equal  (infix "~=" 50)

notation (xsymbols)
  Not  ("\<not> _" [40] 40)
  "op &"  (infixr "\<and>" 35)
  "op |"  (infixr "\<or>" 30)
  "op -->"  (infixr "\<longrightarrow>" 25)
  not_equal  (infix "\<noteq>" 50)

notation (HTML output)
  Not  ("\<not> _" [40] 40)
  "op &"  (infixr "\<and>" 35)
  "op |"  (infixr "\<or>" 30)
  not_equal  (infix "\<noteq>" 50)

abbreviation (iff)
  iff :: "[bool, bool] => bool"  (infixr "<->" 25)
  "A <-> B == A = B"

notation (xsymbols)
  iff  (infixr "\<longleftrightarrow>" 25)


nonterminals
  letbinds  letbind
  case_syn  cases_syn

syntax
  "_The"        :: "[pttrn, bool] => 'a"                 ("(3THE _./ _)" [0, 10] 10)

  "_bind"       :: "[pttrn, 'a] => letbind"              ("(2_ =/ _)" 10)
  ""            :: "letbind => letbinds"                 ("_")
  "_binds"      :: "[letbind, letbinds] => letbinds"     ("_;/ _")
  "_Let"        :: "[letbinds, 'a] => 'a"                ("(let (_)/ in (_))" 10)

  "_case_syntax":: "['a, cases_syn] => 'b"               ("(case _ of/ _)" 10)
  "_case1"      :: "['a, 'b] => case_syn"                ("(2_ =>/ _)" 10)
  ""            :: "case_syn => cases_syn"               ("_")
  "_case2"      :: "[case_syn, cases_syn] => cases_syn"  ("_/ | _")

translations
  "THE x. P"              == "The (%x. P)"
  "_Let (_binds b bs) e"  == "_Let b (_Let bs e)"
  "let x = a in e"        == "Let a (%x. e)"

print_translation {*
(* To avoid eta-contraction of body: *)
[("The", fn [Abs abs] =>
     let val (x,t) = atomic_abs_tr' abs
     in Syntax.const "_The" $ x $ t end)]
*}

syntax (xsymbols)
  "ALL "        :: "[idts, bool] => bool"                ("(3\<forall>_./ _)" [0, 10] 10)
  "EX "         :: "[idts, bool] => bool"                ("(3\<exists>_./ _)" [0, 10] 10)
  "EX! "        :: "[idts, bool] => bool"                ("(3\<exists>!_./ _)" [0, 10] 10)
  "_case1"      :: "['a, 'b] => case_syn"                ("(2_ \<Rightarrow>/ _)" 10)
(*"_case2"      :: "[case_syn, cases_syn] => cases_syn"  ("_/ \<orelse> _")*)

syntax (HTML output)
  "ALL "        :: "[idts, bool] => bool"                ("(3\<forall>_./ _)" [0, 10] 10)
  "EX "         :: "[idts, bool] => bool"                ("(3\<exists>_./ _)" [0, 10] 10)
  "EX! "        :: "[idts, bool] => bool"                ("(3\<exists>!_./ _)" [0, 10] 10)

syntax (HOL)
  "ALL "        :: "[idts, bool] => bool"                ("(3! _./ _)" [0, 10] 10)
  "EX "         :: "[idts, bool] => bool"                ("(3? _./ _)" [0, 10] 10)
  "EX! "        :: "[idts, bool] => bool"                ("(3?! _./ _)" [0, 10] 10)


subsubsection {* Axioms and basic definitions *}

axioms
  eq_reflection:  "(x=y) ==> (x==y)"

  refl:           "t = (t::'a)"

  ext:            "(!!x::'a. (f x ::'b) = g x) ==> (%x. f x) = (%x. g x)"
    -- {*Extensionality is built into the meta-logic, and this rule expresses
         a related property.  It is an eta-expanded version of the traditional
         rule, and similar to the ABS rule of HOL*}

  the_eq_trivial: "(THE x. x = a) = (a::'a)"

  impI:           "(P ==> Q) ==> P-->Q"
  mp:             "[| P-->Q;  P |] ==> Q"


defs
  True_def:     "True      == ((%x::bool. x) = (%x. x))"
  All_def:      "All(P)    == (P = (%x. True))"
  Ex_def:       "Ex(P)     == !Q. (!x. P x --> Q) --> Q"
  False_def:    "False     == (!P. P)"
  not_def:      "~ P       == P-->False"
  and_def:      "P & Q     == !R. (P-->Q-->R) --> R"
  or_def:       "P | Q     == !R. (P-->R) --> (Q-->R) --> R"
  Ex1_def:      "Ex1(P)    == ? x. P(x) & (! y. P(y) --> y=x)"

axioms
  iff:          "(P-->Q) --> (Q-->P) --> (P=Q)"
  True_or_False:  "(P=True) | (P=False)"

defs
  Let_def:      "Let s f == f(s)"
  if_def:       "If P x y == THE z::'a. (P=True --> z=x) & (P=False --> z=y)"

finalconsts
  "op ="
  "op -->"
  The
  arbitrary
  undefined


subsubsection {* Generic algebraic operations *}

class zero =
  fixes zero :: "'a"                       ("\<^loc>0")

class one =
  fixes one  :: "'a"                       ("\<^loc>1")

hide (open) const zero one

class plus =
  fixes plus :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"   (infixl "\<^loc>+" 65)

class minus =
  fixes uminus :: "'a \<Rightarrow> 'a" 
  fixes minus  :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" (infixl "\<^loc>-" 65)
  fixes abs    :: "'a \<Rightarrow> 'a"

class times =
  fixes times :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"  (infixl "\<^loc>*" 70)

class inverse = 
  fixes inverse :: "'a \<Rightarrow> 'a"
  fixes divide :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" (infixl "\<^loc>'/" 70)

syntax
  "_index1"  :: index    ("\<^sub>1")
translations
  (index) "\<^sub>1" => (index) "\<^bsub>\<struct>\<^esub>"

typed_print_translation {*
let
  val syntax_name = Sign.const_syntax_name (the_context ());
  fun tr' c = (c, fn show_sorts => fn T => fn ts =>
    if T = dummyT orelse not (! show_types) andalso can Term.dest_Type T then raise Match
    else Syntax.const Syntax.constrainC $ Syntax.const c $ Syntax.term_of_typ show_sorts T);
in map (tr' o Sign.const_syntax_name (the_context ())) ["HOL.one", "HOL.zero"] end;
*} -- {* show types that are presumably too general *}

notation
  uminus  ("- _" [81] 80)

notation (xsymbols)
  abs  ("\<bar>_\<bar>")
notation (HTML output)
  abs  ("\<bar>_\<bar>")


subsection {* Fundamental rules *}

subsubsection {* Equality *}

text {* Thanks to Stephan Merz *}
lemma subst:
  assumes eq: "s = t" and p: "P s"
  shows "P t"
proof -
  from eq have meta: "s \<equiv> t"
    by (rule eq_reflection)
  from p show ?thesis
    by (unfold meta)
qed

lemma sym: "s = t ==> t = s"
  by (erule subst) (rule refl)

lemma ssubst: "t = s ==> P s ==> P t"
  by (drule sym) (erule subst)

lemma trans: "[| r=s; s=t |] ==> r=t"
  by (erule subst)

lemma def_imp_eq:
  assumes meq: "A == B"
  shows "A = B"
  by (unfold meq) (rule refl)

(*a mere copy*)
lemma meta_eq_to_obj_eq: 
  assumes meq: "A == B"
  shows "A = B"
  by (unfold meq) (rule refl)

text {* Useful with eresolve\_tac for proving equalties from known equalities. *}
     (* a = b
        |   |
        c = d   *)
lemma box_equals: "[| a=b;  a=c;  b=d |] ==> c=d"
apply (rule trans)
apply (rule trans)
apply (rule sym)
apply assumption+
done

text {* For calculational reasoning: *}

lemma forw_subst: "a = b ==> P b ==> P a"
  by (rule ssubst)

lemma back_subst: "P a ==> a = b ==> P b"
  by (rule subst)


subsubsection {*Congruence rules for application*}

(*similar to AP_THM in Gordon's HOL*)
lemma fun_cong: "(f::'a=>'b) = g ==> f(x)=g(x)"
apply (erule subst)
apply (rule refl)
done

(*similar to AP_TERM in Gordon's HOL and FOL's subst_context*)
lemma arg_cong: "x=y ==> f(x)=f(y)"
apply (erule subst)
apply (rule refl)
done

lemma arg_cong2: "\<lbrakk> a = b; c = d \<rbrakk> \<Longrightarrow> f a c = f b d"
apply (erule ssubst)+
apply (rule refl)
done

lemma cong: "[| f = g; (x::'a) = y |] ==> f(x) = g(y)"
apply (erule subst)+
apply (rule refl)
done


subsubsection {*Equality of booleans -- iff*}

lemma iffI: assumes prems: "P ==> Q" "Q ==> P" shows "P=Q"
  by (iprover intro: iff [THEN mp, THEN mp] impI prems)

lemma iffD2: "[| P=Q; Q |] ==> P"
  by (erule ssubst)

lemma rev_iffD2: "[| Q; P=Q |] ==> P"
  by (erule iffD2)

lemmas iffD1 = sym [THEN iffD2, standard]
lemmas rev_iffD1 = sym [THEN [2] rev_iffD2, standard]

lemma iffE:
  assumes major: "P=Q"
      and minor: "[| P --> Q; Q --> P |] ==> R"
  shows R
  by (iprover intro: minor impI major [THEN iffD2] major [THEN iffD1])


subsubsection {*True*}

lemma TrueI: "True"
  by (unfold True_def) (rule refl)

lemma eqTrueI: "P ==> P=True"
  by (iprover intro: iffI TrueI)

lemma eqTrueE: "P=True ==> P"
apply (erule iffD2)
apply (rule TrueI)
done


subsubsection {*Universal quantifier*}

lemma allI: assumes p: "!!x::'a. P(x)" shows "ALL x. P(x)"
apply (unfold All_def)
apply (iprover intro: ext eqTrueI p)
done

lemma spec: "ALL x::'a. P(x) ==> P(x)"
apply (unfold All_def)
apply (rule eqTrueE)
apply (erule fun_cong)
done

lemma allE:
  assumes major: "ALL x. P(x)"
      and minor: "P(x) ==> R"
  shows "R"
by (iprover intro: minor major [THEN spec])

lemma all_dupE:
  assumes major: "ALL x. P(x)"
      and minor: "[| P(x); ALL x. P(x) |] ==> R"
  shows "R"
by (iprover intro: minor major major [THEN spec])


subsubsection {*False*}
(*Depends upon spec; it is impossible to do propositional logic before quantifiers!*)

lemma FalseE: "False ==> P"
apply (unfold False_def)
apply (erule spec)
done

lemma False_neq_True: "False=True ==> P"
by (erule eqTrueE [THEN FalseE])


subsubsection {*Negation*}

lemma notI:
  assumes p: "P ==> False"
  shows "~P"
apply (unfold not_def)
apply (iprover intro: impI p)
done

lemma False_not_True: "False ~= True"
apply (rule notI)
apply (erule False_neq_True)
done

lemma True_not_False: "True ~= False"
apply (rule notI)
apply (drule sym)
apply (erule False_neq_True)
done

lemma notE: "[| ~P;  P |] ==> R"
apply (unfold not_def)
apply (erule mp [THEN FalseE])
apply assumption
done

(* Alternative ~ introduction rule: [| P ==> ~ Pa; P ==> Pa |] ==> ~ P *)
lemmas notI2 = notE [THEN notI, standard]


subsubsection {*Implication*}

lemma impE:
  assumes "P-->Q" "P" "Q ==> R"
  shows "R"
by (iprover intro: prems mp)

(* Reduces Q to P-->Q, allowing substitution in P. *)
lemma rev_mp: "[| P;  P --> Q |] ==> Q"
by (iprover intro: mp)

lemma contrapos_nn:
  assumes major: "~Q"
      and minor: "P==>Q"
  shows "~P"
by (iprover intro: notI minor major [THEN notE])

(*not used at all, but we already have the other 3 combinations *)
lemma contrapos_pn:
  assumes major: "Q"
      and minor: "P ==> ~Q"
  shows "~P"
by (iprover intro: notI minor major notE)

lemma not_sym: "t ~= s ==> s ~= t"
  by (erule contrapos_nn) (erule sym)

lemma eq_neq_eq_imp_neq: "[| x = a ; a ~= b; b = y |] ==> x ~= y"
  by (erule subst, erule ssubst, assumption)

(*still used in HOLCF*)
lemma rev_contrapos:
  assumes pq: "P ==> Q"
      and nq: "~Q"
  shows "~P"
apply (rule nq [THEN contrapos_nn])
apply (erule pq)
done

subsubsection {*Existential quantifier*}

lemma exI: "P x ==> EX x::'a. P x"
apply (unfold Ex_def)
apply (iprover intro: allI allE impI mp)
done

lemma exE:
  assumes major: "EX x::'a. P(x)"
      and minor: "!!x. P(x) ==> Q"
  shows "Q"
apply (rule major [unfolded Ex_def, THEN spec, THEN mp])
apply (iprover intro: impI [THEN allI] minor)
done


subsubsection {*Conjunction*}

lemma conjI: "[| P; Q |] ==> P&Q"
apply (unfold and_def)
apply (iprover intro: impI [THEN allI] mp)
done

lemma conjunct1: "[| P & Q |] ==> P"
apply (unfold and_def)
apply (iprover intro: impI dest: spec mp)
done

lemma conjunct2: "[| P & Q |] ==> Q"
apply (unfold and_def)
apply (iprover intro: impI dest: spec mp)
done

lemma conjE:
  assumes major: "P&Q"
      and minor: "[| P; Q |] ==> R"
  shows "R"
apply (rule minor)
apply (rule major [THEN conjunct1])
apply (rule major [THEN conjunct2])
done

lemma context_conjI:
  assumes prems: "P" "P ==> Q" shows "P & Q"
by (iprover intro: conjI prems)


subsubsection {*Disjunction*}

lemma disjI1: "P ==> P|Q"
apply (unfold or_def)
apply (iprover intro: allI impI mp)
done

lemma disjI2: "Q ==> P|Q"
apply (unfold or_def)
apply (iprover intro: allI impI mp)
done

lemma disjE:
  assumes major: "P|Q"
      and minorP: "P ==> R"
      and minorQ: "Q ==> R"
  shows "R"
by (iprover intro: minorP minorQ impI
                 major [unfolded or_def, THEN spec, THEN mp, THEN mp])


subsubsection {*Classical logic*}

lemma classical:
  assumes prem: "~P ==> P"
  shows "P"
apply (rule True_or_False [THEN disjE, THEN eqTrueE])
apply assumption
apply (rule notI [THEN prem, THEN eqTrueI])
apply (erule subst)
apply assumption
done

lemmas ccontr = FalseE [THEN classical, standard]

(*notE with premises exchanged; it discharges ~R so that it can be used to
  make elimination rules*)
lemma rev_notE:
  assumes premp: "P"
      and premnot: "~R ==> ~P"
  shows "R"
apply (rule ccontr)
apply (erule notE [OF premnot premp])
done

(*Double negation law*)
lemma notnotD: "~~P ==> P"
apply (rule classical)
apply (erule notE)
apply assumption
done

lemma contrapos_pp:
  assumes p1: "Q"
      and p2: "~P ==> ~Q"
  shows "P"
by (iprover intro: classical p1 p2 notE)


subsubsection {*Unique existence*}

lemma ex1I:
  assumes prems: "P a" "!!x. P(x) ==> x=a"
  shows "EX! x. P(x)"
by (unfold Ex1_def, iprover intro: prems exI conjI allI impI)

text{*Sometimes easier to use: the premises have no shared variables.  Safe!*}
lemma ex_ex1I:
  assumes ex_prem: "EX x. P(x)"
      and eq: "!!x y. [| P(x); P(y) |] ==> x=y"
  shows "EX! x. P(x)"
by (iprover intro: ex_prem [THEN exE] ex1I eq)

lemma ex1E:
  assumes major: "EX! x. P(x)"
      and minor: "!!x. [| P(x);  ALL y. P(y) --> y=x |] ==> R"
  shows "R"
apply (rule major [unfolded Ex1_def, THEN exE])
apply (erule conjE)
apply (iprover intro: minor)
done

lemma ex1_implies_ex: "EX! x. P x ==> EX x. P x"
apply (erule ex1E)
apply (rule exI)
apply assumption
done


subsubsection {*THE: definite description operator*}

lemma the_equality:
  assumes prema: "P a"
      and premx: "!!x. P x ==> x=a"
  shows "(THE x. P x) = a"
apply (rule trans [OF _ the_eq_trivial])
apply (rule_tac f = "The" in arg_cong)
apply (rule ext)
apply (rule iffI)
 apply (erule premx)
apply (erule ssubst, rule prema)
done

lemma theI:
  assumes "P a" and "!!x. P x ==> x=a"
  shows "P (THE x. P x)"
by (iprover intro: prems the_equality [THEN ssubst])

lemma theI': "EX! x. P x ==> P (THE x. P x)"
apply (erule ex1E)
apply (erule theI)
apply (erule allE)
apply (erule mp)
apply assumption
done

(*Easier to apply than theI: only one occurrence of P*)
lemma theI2:
  assumes "P a" "!!x. P x ==> x=a" "!!x. P x ==> Q x"
  shows "Q (THE x. P x)"
by (iprover intro: prems theI)

lemma the1_equality [elim?]: "[| EX!x. P x; P a |] ==> (THE x. P x) = a"
apply (rule the_equality)
apply  assumption
apply (erule ex1E)
apply (erule all_dupE)
apply (drule mp)
apply  assumption
apply (erule ssubst)
apply (erule allE)
apply (erule mp)
apply assumption
done

lemma the_sym_eq_trivial: "(THE y. x=y) = x"
apply (rule the_equality)
apply (rule refl)
apply (erule sym)
done


subsubsection {*Classical intro rules for disjunction and existential quantifiers*}

lemma disjCI:
  assumes "~Q ==> P" shows "P|Q"
apply (rule classical)
apply (iprover intro: prems disjI1 disjI2 notI elim: notE)
done

lemma excluded_middle: "~P | P"
by (iprover intro: disjCI)

text {*
  case distinction as a natural deduction rule.
  Note that @{term "~P"} is the second case, not the first
*}
lemma case_split_thm:
  assumes prem1: "P ==> Q"
      and prem2: "~P ==> Q"
  shows "Q"
apply (rule excluded_middle [THEN disjE])
apply (erule prem2)
apply (erule prem1)
done
lemmas case_split = case_split_thm [case_names True False]

(*Classical implies (-->) elimination. *)
lemma impCE:
  assumes major: "P-->Q"
      and minor: "~P ==> R" "Q ==> R"
  shows "R"
apply (rule excluded_middle [of P, THEN disjE])
apply (iprover intro: minor major [THEN mp])+
done

(*This version of --> elimination works on Q before P.  It works best for
  those cases in which P holds "almost everywhere".  Can't install as
  default: would break old proofs.*)
lemma impCE':
  assumes major: "P-->Q"
      and minor: "Q ==> R" "~P ==> R"
  shows "R"
apply (rule excluded_middle [of P, THEN disjE])
apply (iprover intro: minor major [THEN mp])+
done

(*Classical <-> elimination. *)
lemma iffCE:
  assumes major: "P=Q"
      and minor: "[| P; Q |] ==> R"  "[| ~P; ~Q |] ==> R"
  shows "R"
apply (rule major [THEN iffE])
apply (iprover intro: minor elim: impCE notE)
done

lemma exCI:
  assumes "ALL x. ~P(x) ==> P(a)"
  shows "EX x. P(x)"
apply (rule ccontr)
apply (iprover intro: prems exI allI notI notE [of "\<exists>x. P x"])
done


subsubsection {* Intuitionistic Reasoning *}

lemma impE':
  assumes 1: "P --> Q"
    and 2: "Q ==> R"
    and 3: "P --> Q ==> P"
  shows R
proof -
  from 3 and 1 have P .
  with 1 have Q by (rule impE)
  with 2 show R .
qed

lemma allE':
  assumes 1: "ALL x. P x"
    and 2: "P x ==> ALL x. P x ==> Q"
  shows Q
proof -
  from 1 have "P x" by (rule spec)
  from this and 1 show Q by (rule 2)
qed

lemma notE':
  assumes 1: "~ P"
    and 2: "~ P ==> P"
  shows R
proof -
  from 2 and 1 have P .
  with 1 show R by (rule notE)
qed

lemmas [Pure.elim!] = disjE iffE FalseE conjE exE
  and [Pure.intro!] = iffI conjI impI TrueI notI allI refl
  and [Pure.elim 2] = allE notE' impE'
  and [Pure.intro] = exI disjI2 disjI1

lemmas [trans] = trans
  and [sym] = sym not_sym
  and [Pure.elim?] = iffD1 iffD2 impE


subsubsection {* Atomizing meta-level connectives *}

lemma atomize_all [atomize]: "(!!x. P x) == Trueprop (ALL x. P x)"
proof
  assume "!!x. P x"
  show "ALL x. P x" by (rule allI)
next
  assume "ALL x. P x"
  thus "!!x. P x" by (rule allE)
qed

lemma atomize_imp [atomize]: "(A ==> B) == Trueprop (A --> B)"
proof
  assume r: "A ==> B"
  show "A --> B" by (rule impI) (rule r)
next
  assume "A --> B" and A
  thus B by (rule mp)
qed

lemma atomize_not: "(A ==> False) == Trueprop (~A)"
proof
  assume r: "A ==> False"
  show "~A" by (rule notI) (rule r)
next
  assume "~A" and A
  thus False by (rule notE)
qed

lemma atomize_eq [atomize]: "(x == y) == Trueprop (x = y)"
proof
  assume "x == y"
  show "x = y" by (unfold prems) (rule refl)
next
  assume "x = y"
  thus "x == y" by (rule eq_reflection)
qed

lemma atomize_conj [atomize]:
  includes meta_conjunction_syntax
  shows "(A && B) == Trueprop (A & B)"
proof
  assume conj: "A && B"
  show "A & B"
  proof (rule conjI)
    from conj show A by (rule conjunctionD1)
    from conj show B by (rule conjunctionD2)
  qed
next
  assume conj: "A & B"
  show "A && B"
  proof -
    from conj show A ..
    from conj show B ..
  qed
qed

lemmas [symmetric, rulify] = atomize_all atomize_imp
  and [symmetric, defn] = atomize_all atomize_imp atomize_eq


subsection {* Package setup *}

subsubsection {* Fundamental ML bindings *}

ML {*
structure HOL =
struct
  (*FIXME reduce this to a minimum*)
  val eq_reflection = thm "eq_reflection";
  val def_imp_eq = thm "def_imp_eq";
  val meta_eq_to_obj_eq = thm "meta_eq_to_obj_eq";
  val ccontr = thm "ccontr";
  val impI = thm "impI";
  val impCE = thm "impCE";
  val notI = thm "notI";
  val notE = thm "notE";
  val iffI = thm "iffI";
  val iffCE = thm "iffCE";
  val conjI = thm "conjI";
  val conjE = thm "conjE";
  val disjCI = thm "disjCI";
  val disjE = thm "disjE";
  val TrueI = thm "TrueI";
  val FalseE = thm "FalseE";
  val allI = thm "allI";
  val allE = thm "allE";
  val exI = thm "exI";
  val exE = thm "exE";
  val ex_ex1I = thm "ex_ex1I";
  val the_equality = thm "the_equality";
  val mp = thm "mp";
  val rev_mp = thm "rev_mp"
  val classical = thm "classical";
  val subst = thm "subst";
  val refl = thm "refl";
  val sym = thm "sym";
  val trans = thm "trans";
  val arg_cong = thm "arg_cong";
  val iffD1 = thm "iffD1";
  val iffD2 = thm "iffD2";
  val disjE = thm "disjE";
  val conjE = thm "conjE";
  val exE = thm "exE";
  val contrapos_nn = thm "contrapos_nn";
  val contrapos_pp = thm "contrapos_pp";
  val notnotD = thm "notnotD";
  val conjunct1 = thm "conjunct1";
  val conjunct2 = thm "conjunct2";
  val spec = thm "spec";
  val imp_cong = thm "imp_cong";
  val the_sym_eq_trivial = thm "the_sym_eq_trivial";
  val triv_forall_equality = thm "triv_forall_equality";
  val case_split = thm "case_split_thm";
end
*}


subsubsection {* Classical Reasoner setup *}

lemma thin_refl:
  "\<And>X. \<lbrakk> x=x; PROP W \<rbrakk> \<Longrightarrow> PROP W" .

ML {*
structure Hypsubst = HypsubstFun(
struct
  structure Simplifier = Simplifier
  val dest_eq = HOLogic.dest_eq
  val dest_Trueprop = HOLogic.dest_Trueprop
  val dest_imp = HOLogic.dest_imp
  val eq_reflection = HOL.eq_reflection
  val rev_eq_reflection = HOL.def_imp_eq
  val imp_intr = HOL.impI
  val rev_mp = HOL.rev_mp
  val subst = HOL.subst
  val sym = HOL.sym
  val thin_refl = thm "thin_refl";
end);

structure Classical = ClassicalFun(
struct
  val mp = HOL.mp
  val not_elim = HOL.notE
  val classical = HOL.classical
  val sizef = Drule.size_of_thm
  val hyp_subst_tacs = [Hypsubst.hyp_subst_tac]
end);

structure BasicClassical: BASIC_CLASSICAL = Classical; 
*}

setup {*
let
  (*prevent substitution on bool*)
  fun hyp_subst_tac' i thm = if i <= Thm.nprems_of thm andalso
    Term.exists_Const (fn ("op =", Type (_, [T, _])) => T <> Type ("bool", []) | _ => false)
      (nth (Thm.prems_of thm) (i - 1)) then Hypsubst.hyp_subst_tac i thm else no_tac thm;
in
  Hypsubst.hypsubst_setup
  #> ContextRules.addSWrapper (fn tac => hyp_subst_tac' ORELSE' tac)
  #> Classical.setup
  #> ResAtpset.setup
end
*}

declare iffI [intro!]
  and notI [intro!]
  and impI [intro!]
  and disjCI [intro!]
  and conjI [intro!]
  and TrueI [intro!]
  and refl [intro!]

declare iffCE [elim!]
  and FalseE [elim!]
  and impCE [elim!]
  and disjE [elim!]
  and conjE [elim!]
  and conjE [elim!]

declare ex_ex1I [intro!]
  and allI [intro!]
  and the_equality [intro]
  and exI [intro]

declare exE [elim!]
  allE [elim]

ML {*
structure HOL =
struct

open HOL;

val claset = Classical.claset_of (the_context ());

end;
*}

lemma contrapos_np: "~ Q ==> (~ P ==> Q) ==> P"
  apply (erule swap)
  apply (erule (1) meta_mp)
  done

declare ex_ex1I [rule del, intro! 2]
  and ex1I [intro]

lemmas [intro?] = ext
  and [elim?] = ex1_implies_ex

(*Better then ex1E for classical reasoner: needs no quantifier duplication!*)
lemma alt_ex1E [elim!]:
  assumes major: "\<exists>!x. P x"
      and prem: "\<And>x. \<lbrakk> P x; \<forall>y y'. P y \<and> P y' \<longrightarrow> y = y' \<rbrakk> \<Longrightarrow> R"
  shows R
apply (rule ex1E [OF major])
apply (rule prem)
apply (tactic "ares_tac [HOL.allI] 1")+
apply (tactic "etac (Classical.dup_elim HOL.allE) 1")
by iprover

ML {*
structure Blast = BlastFun(
struct
  type claset = Classical.claset
  val equality_name = "op ="
  val not_name = "Not"
  val notE = HOL.notE
  val ccontr = HOL.ccontr
  val contr_tac = Classical.contr_tac
  val dup_intr = Classical.dup_intr
  val hyp_subst_tac = Hypsubst.blast_hyp_subst_tac
  val claset	= Classical.claset
  val rep_cs = Classical.rep_cs
  val cla_modifiers = Classical.cla_modifiers
  val cla_meth' = Classical.cla_meth'
end);

structure HOL =
struct

open HOL;

val Blast_tac = Blast.Blast_tac;
val blast_tac = Blast.blast_tac;

fun case_tac a = res_inst_tac [("P", a)] case_split;

(* combination of (spec RS spec RS ...(j times) ... spec RS mp) *)
local
  fun wrong_prem (Const ("All", _) $ (Abs (_, _, t))) = wrong_prem t
    | wrong_prem (Bound _) = true
    | wrong_prem _ = false;
  val filter_right = filter (not o wrong_prem o HOLogic.dest_Trueprop o hd o Thm.prems_of);
in
  fun smp i = funpow i (fn m => filter_right ([spec] RL m)) ([mp]);
  fun smp_tac j = EVERY'[dresolve_tac (smp j), atac];
end;

fun strip_tac i = REPEAT (resolve_tac [impI, allI] i);

fun Trueprop_conv conv ct = (case term_of ct of
    Const ("Trueprop", _) $ _ =>
      let val (ct1, ct2) = Thm.dest_comb ct
      in Thm.combination (Thm.reflexive ct1) (conv ct2) end
  | _ => raise TERM ("Trueprop_conv", []));

fun Equals_conv conv ct = (case term_of ct of
    Const ("op =", _) $ _ $ _ =>
      let
        val ((ct1, ct2), ct3) = (apfst Thm.dest_comb o Thm.dest_comb) ct;
      in Thm.combination (Thm.combination (Thm.reflexive ct1) (conv ct2)) (conv ct3) end
  | _ => conv ct);

fun constrain_op_eq_thms thy thms =
  let
    fun add_eq (Const ("op =", ty)) =
          fold (insert (eq_fst (op =)))
            (Term.add_tvarsT ty [])
      | add_eq _ =
          I
    val eqs = fold (fold_aterms add_eq o Thm.prop_of) thms [];
    val instT = map (fn (v_i, sort) =>
      (Thm.ctyp_of thy (TVar (v_i, sort)),
         Thm.ctyp_of thy (TVar (v_i, Sorts.inter_sort (Sign.classes_of thy) (sort, [HOLogic.class_eq]))))) eqs;
  in
    thms
    |> map (Thm.instantiate (instT, []))
  end;

end;
*}

setup Blast.setup


subsubsection {* Simplifier *}

lemma eta_contract_eq: "(%s. f s) = f" ..

lemma simp_thms:
  shows not_not: "(~ ~ P) = P"
  and Not_eq_iff: "((~P) = (~Q)) = (P = Q)"
  and
    "(P ~= Q) = (P = (~Q))"
    "(P | ~P) = True"    "(~P | P) = True"
    "(x = x) = True"
  and not_True_eq_False: "(\<not> True) = False"
  and not_False_eq_True: "(\<not> False) = True"
  and
    "(~P) ~= P"  "P ~= (~P)"
    "(True=P) = P"
  and eq_True: "(P = True) = P"
  and "(False=P) = (~P)"
  and eq_False: "(P = False) = (\<not> P)"
  and
    "(True --> P) = P"  "(False --> P) = True"
    "(P --> True) = True"  "(P --> P) = True"
    "(P --> False) = (~P)"  "(P --> ~P) = (~P)"
    "(P & True) = P"  "(True & P) = P"
    "(P & False) = False"  "(False & P) = False"
    "(P & P) = P"  "(P & (P & Q)) = (P & Q)"
    "(P & ~P) = False"    "(~P & P) = False"
    "(P | True) = True"  "(True | P) = True"
    "(P | False) = P"  "(False | P) = P"
    "(P | P) = P"  "(P | (P | Q)) = (P | Q)" and
    "(ALL x. P) = P"  "(EX x. P) = P"  "EX x. x=t"  "EX x. t=x"
    -- {* needed for the one-point-rule quantifier simplification procs *}
    -- {* essential for termination!! *} and
    "!!P. (EX x. x=t & P(x)) = P(t)"
    "!!P. (EX x. t=x & P(x)) = P(t)"
    "!!P. (ALL x. x=t --> P(x)) = P(t)"
    "!!P. (ALL x. t=x --> P(x)) = P(t)"
  by (blast, blast, blast, blast, blast, iprover+)

lemma disj_absorb: "(A | A) = A"
  by blast

lemma disj_left_absorb: "(A | (A | B)) = (A | B)"
  by blast

lemma conj_absorb: "(A & A) = A"
  by blast

lemma conj_left_absorb: "(A & (A & B)) = (A & B)"
  by blast

lemma eq_ac:
  shows eq_commute: "(a=b) = (b=a)"
    and eq_left_commute: "(P=(Q=R)) = (Q=(P=R))"
    and eq_assoc: "((P=Q)=R) = (P=(Q=R))" by (iprover, blast+)
lemma neq_commute: "(a~=b) = (b~=a)" by iprover

lemma conj_comms:
  shows conj_commute: "(P&Q) = (Q&P)"
    and conj_left_commute: "(P&(Q&R)) = (Q&(P&R))" by iprover+
lemma conj_assoc: "((P&Q)&R) = (P&(Q&R))" by iprover

lemmas conj_ac = conj_commute conj_left_commute conj_assoc

lemma disj_comms:
  shows disj_commute: "(P|Q) = (Q|P)"
    and disj_left_commute: "(P|(Q|R)) = (Q|(P|R))" by iprover+
lemma disj_assoc: "((P|Q)|R) = (P|(Q|R))" by iprover

lemmas disj_ac = disj_commute disj_left_commute disj_assoc

lemma conj_disj_distribL: "(P&(Q|R)) = (P&Q | P&R)" by iprover
lemma conj_disj_distribR: "((P|Q)&R) = (P&R | Q&R)" by iprover

lemma disj_conj_distribL: "(P|(Q&R)) = ((P|Q) & (P|R))" by iprover
lemma disj_conj_distribR: "((P&Q)|R) = ((P|R) & (Q|R))" by iprover

lemma imp_conjR: "(P --> (Q&R)) = ((P-->Q) & (P-->R))" by iprover
lemma imp_conjL: "((P&Q) -->R)  = (P --> (Q --> R))" by iprover
lemma imp_disjL: "((P|Q) --> R) = ((P-->R)&(Q-->R))" by iprover

text {* These two are specialized, but @{text imp_disj_not1} is useful in @{text "Auth/Yahalom"}. *}
lemma imp_disj_not1: "(P --> Q | R) = (~Q --> P --> R)" by blast
lemma imp_disj_not2: "(P --> Q | R) = (~R --> P --> Q)" by blast

lemma imp_disj1: "((P-->Q)|R) = (P--> Q|R)" by blast
lemma imp_disj2: "(Q|(P-->R)) = (P--> Q|R)" by blast

lemma imp_cong: "(P = P') ==> (P' ==> (Q = Q')) ==> ((P --> Q) = (P' --> Q'))"
  by iprover

lemma de_Morgan_disj: "(~(P | Q)) = (~P & ~Q)" by iprover
lemma de_Morgan_conj: "(~(P & Q)) = (~P | ~Q)" by blast
lemma not_imp: "(~(P --> Q)) = (P & ~Q)" by blast
lemma not_iff: "(P~=Q) = (P = (~Q))" by blast
lemma disj_not1: "(~P | Q) = (P --> Q)" by blast
lemma disj_not2: "(P | ~Q) = (Q --> P)"  -- {* changes orientation :-( *}
  by blast
lemma imp_conv_disj: "(P --> Q) = ((~P) | Q)" by blast

lemma iff_conv_conj_imp: "(P = Q) = ((P --> Q) & (Q --> P))" by iprover


lemma cases_simp: "((P --> Q) & (~P --> Q)) = Q"
  -- {* Avoids duplication of subgoals after @{text split_if}, when the true and false *}
  -- {* cases boil down to the same thing. *}
  by blast

lemma not_all: "(~ (! x. P(x))) = (? x.~P(x))" by blast
lemma imp_all: "((! x. P x) --> Q) = (? x. P x --> Q)" by blast
lemma not_ex: "(~ (? x. P(x))) = (! x.~P(x))" by iprover
lemma imp_ex: "((? x. P x) --> Q) = (! x. P x --> Q)" by iprover

lemma ex_disj_distrib: "(? x. P(x) | Q(x)) = ((? x. P(x)) | (? x. Q(x)))" by iprover
lemma all_conj_distrib: "(!x. P(x) & Q(x)) = ((! x. P(x)) & (! x. Q(x)))" by iprover

text {*
  \medskip The @{text "&"} congruence rule: not included by default!
  May slow rewrite proofs down by as much as 50\% *}

lemma conj_cong:
    "(P = P') ==> (P' ==> (Q = Q')) ==> ((P & Q) = (P' & Q'))"
  by iprover

lemma rev_conj_cong:
    "(Q = Q') ==> (Q' ==> (P = P')) ==> ((P & Q) = (P' & Q'))"
  by iprover

text {* The @{text "|"} congruence rule: not included by default! *}

lemma disj_cong:
    "(P = P') ==> (~P' ==> (Q = Q')) ==> ((P | Q) = (P' | Q'))"
  by blast


text {* \medskip if-then-else rules *}

lemma if_True: "(if True then x else y) = x"
  by (unfold if_def) blast

lemma if_False: "(if False then x else y) = y"
  by (unfold if_def) blast

lemma if_P: "P ==> (if P then x else y) = x"
  by (unfold if_def) blast

lemma if_not_P: "~P ==> (if P then x else y) = y"
  by (unfold if_def) blast

lemma split_if: "P (if Q then x else y) = ((Q --> P(x)) & (~Q --> P(y)))"
  apply (rule case_split [of Q])
   apply (simplesubst if_P)
    prefer 3 apply (simplesubst if_not_P, blast+)
  done

lemma split_if_asm: "P (if Q then x else y) = (~((Q & ~P x) | (~Q & ~P y)))"
by (simplesubst split_if, blast)

lemmas if_splits = split_if split_if_asm

lemma if_cancel: "(if c then x else x) = x"
by (simplesubst split_if, blast)

lemma if_eq_cancel: "(if x = y then y else x) = x"
by (simplesubst split_if, blast)

lemma if_bool_eq_conj: "(if P then Q else R) = ((P-->Q) & (~P-->R))"
  -- {* This form is useful for expanding @{text "if"}s on the RIGHT of the @{text "==>"} symbol. *}
  by (rule split_if)

lemma if_bool_eq_disj: "(if P then Q else R) = ((P&Q) | (~P&R))"
  -- {* And this form is useful for expanding @{text "if"}s on the LEFT. *}
  apply (simplesubst split_if, blast)
  done

lemma Eq_TrueI: "P ==> P == True" by (unfold atomize_eq) iprover
lemma Eq_FalseI: "~P ==> P == False" by (unfold atomize_eq) iprover

text {* \medskip let rules for simproc *}

lemma Let_folded: "f x \<equiv> g x \<Longrightarrow>  Let x f \<equiv> Let x g"
  by (unfold Let_def)

lemma Let_unfold: "f x \<equiv> g \<Longrightarrow>  Let x f \<equiv> g"
  by (unfold Let_def)

text {*
  The following copy of the implication operator is useful for
  fine-tuning congruence rules.  It instructs the simplifier to simplify
  its premise.
*}

constdefs
  simp_implies :: "[prop, prop] => prop"  (infixr "=simp=>" 1)
  "simp_implies \<equiv> op ==>"

lemma simp_impliesI:
  assumes PQ: "(PROP P \<Longrightarrow> PROP Q)"
  shows "PROP P =simp=> PROP Q"
  apply (unfold simp_implies_def)
  apply (rule PQ)
  apply assumption
  done

lemma simp_impliesE:
  assumes PQ:"PROP P =simp=> PROP Q"
  and P: "PROP P"
  and QR: "PROP Q \<Longrightarrow> PROP R"
  shows "PROP R"
  apply (rule QR)
  apply (rule PQ [unfolded simp_implies_def])
  apply (rule P)
  done

lemma simp_implies_cong:
  assumes PP' :"PROP P == PROP P'"
  and P'QQ': "PROP P' ==> (PROP Q == PROP Q')"
  shows "(PROP P =simp=> PROP Q) == (PROP P' =simp=> PROP Q')"
proof (unfold simp_implies_def, rule equal_intr_rule)
  assume PQ: "PROP P \<Longrightarrow> PROP Q"
  and P': "PROP P'"
  from PP' [symmetric] and P' have "PROP P"
    by (rule equal_elim_rule1)
  hence "PROP Q" by (rule PQ)
  with P'QQ' [OF P'] show "PROP Q'" by (rule equal_elim_rule1)
next
  assume P'Q': "PROP P' \<Longrightarrow> PROP Q'"
  and P: "PROP P"
  from PP' and P have P': "PROP P'" by (rule equal_elim_rule1)
  hence "PROP Q'" by (rule P'Q')
  with P'QQ' [OF P', symmetric] show "PROP Q"
    by (rule equal_elim_rule1)
qed

lemma uncurry:
  assumes "P \<longrightarrow> Q \<longrightarrow> R"
  shows "P \<and> Q \<longrightarrow> R"
  using prems by blast

lemma iff_allI:
  assumes "\<And>x. P x = Q x"
  shows "(\<forall>x. P x) = (\<forall>x. Q x)"
  using prems by blast

lemma iff_exI:
  assumes "\<And>x. P x = Q x"
  shows "(\<exists>x. P x) = (\<exists>x. Q x)"
  using prems by blast

lemma all_comm:
  "(\<forall>x y. P x y) = (\<forall>y x. P x y)"
  by blast

lemma ex_comm:
  "(\<exists>x y. P x y) = (\<exists>y x. P x y)"
  by blast

use "simpdata.ML"
setup {*
  Simplifier.method_setup Splitter.split_modifiers
  #> (fn thy => (change_simpset_of thy (fn _ => HOL.simpset_simprocs); thy))
  #> Splitter.setup
  #> Clasimp.setup
  #> EqSubst.setup
*}

lemma True_implies_equals: "(True \<Longrightarrow> PROP P) \<equiv> PROP P"
proof
  assume prem: "True \<Longrightarrow> PROP P"
  from prem [OF TrueI] show "PROP P" . 
next
  assume "PROP P"
  show "PROP P" .
qed

lemma ex_simps:
  "!!P Q. (EX x. P x & Q)   = ((EX x. P x) & Q)"
  "!!P Q. (EX x. P & Q x)   = (P & (EX x. Q x))"
  "!!P Q. (EX x. P x | Q)   = ((EX x. P x) | Q)"
  "!!P Q. (EX x. P | Q x)   = (P | (EX x. Q x))"
  "!!P Q. (EX x. P x --> Q) = ((ALL x. P x) --> Q)"
  "!!P Q. (EX x. P --> Q x) = (P --> (EX x. Q x))"
  -- {* Miniscoping: pushing in existential quantifiers. *}
  by (iprover | blast)+

lemma all_simps:
  "!!P Q. (ALL x. P x & Q)   = ((ALL x. P x) & Q)"
  "!!P Q. (ALL x. P & Q x)   = (P & (ALL x. Q x))"
  "!!P Q. (ALL x. P x | Q)   = ((ALL x. P x) | Q)"
  "!!P Q. (ALL x. P | Q x)   = (P | (ALL x. Q x))"
  "!!P Q. (ALL x. P x --> Q) = ((EX x. P x) --> Q)"
  "!!P Q. (ALL x. P --> Q x) = (P --> (ALL x. Q x))"
  -- {* Miniscoping: pushing in universal quantifiers. *}
  by (iprover | blast)+

declare triv_forall_equality [simp] (*prunes params*)
  and True_implies_equals [simp] (*prune asms `True'*)
  and if_True [simp]
  and if_False [simp]
  and if_cancel [simp]
  and if_eq_cancel [simp]
  and imp_disjL [simp]
  (*In general it seems wrong to add distributive laws by default: they
    might cause exponential blow-up.  But imp_disjL has been in for a while
    and cannot be removed without affecting existing proofs.  Moreover,
    rewriting by "(P|Q --> R) = ((P-->R)&(Q-->R))" might be justified on the
    grounds that it allows simplification of R in the two cases.*)
  and conj_assoc [simp]
  and disj_assoc [simp]
  and de_Morgan_conj [simp]
  and de_Morgan_disj [simp]
  and imp_disj1 [simp]
  and imp_disj2 [simp]
  and not_imp [simp]
  and disj_not1 [simp]
  and not_all [simp]
  and not_ex [simp]
  and cases_simp [simp]
  and the_eq_trivial [simp]
  and the_sym_eq_trivial [simp]
  and ex_simps [simp]
  and all_simps [simp]
  and simp_thms [simp]
  and imp_cong [cong]
  and simp_implies_cong [cong]
  and split_if [split]

ML {*
structure HOL =
struct

open HOL;

val simpset = Simplifier.simpset_of (the_context ());

end;
*}

text {* Simplifies x assuming c and y assuming ~c *}
lemma if_cong:
  assumes "b = c"
      and "c \<Longrightarrow> x = u"
      and "\<not> c \<Longrightarrow> y = v"
  shows "(if b then x else y) = (if c then u else v)"
  unfolding if_def using prems by simp

text {* Prevents simplification of x and y:
  faster and allows the execution of functional programs. *}
lemma if_weak_cong [cong]:
  assumes "b = c"
  shows "(if b then x else y) = (if c then x else y)"
  using prems by (rule arg_cong)

text {* Prevents simplification of t: much faster *}
lemma let_weak_cong:
  assumes "a = b"
  shows "(let x = a in t x) = (let x = b in t x)"
  using prems by (rule arg_cong)

text {* To tidy up the result of a simproc.  Only the RHS will be simplified. *}
lemma eq_cong2:
  assumes "u = u'"
  shows "(t \<equiv> u) \<equiv> (t \<equiv> u')"
  using prems by simp

lemma if_distrib:
  "f (if c then x else y) = (if c then f x else f y)"
  by simp

text {* For expand\_case\_tac *}
lemma expand_case:
  assumes "P \<Longrightarrow> Q True"
      and "~P \<Longrightarrow> Q False"
  shows "Q P"
proof (tactic {* HOL.case_tac "P" 1 *})
  assume P
  then show "Q P" by simp
next
  assume "\<not> P"
  then have "P = False" by simp
  with prems show "Q P" by simp
qed

text {* This lemma restricts the effect of the rewrite rule u=v to the left-hand
  side of an equality.  Used in {Integ,Real}/simproc.ML *}
lemma restrict_to_left:
  assumes "x = y"
  shows "(x = z) = (y = z)"
  using prems by simp


subsubsection {* Generic cases and induction *}

text {* Rule projections: *}

ML {*
structure ProjectRule = ProjectRuleFun
(struct
  val conjunct1 = thm "conjunct1";
  val conjunct2 = thm "conjunct2";
  val mp = thm "mp";
end)
*}

constdefs
  induct_forall where "induct_forall P == \<forall>x. P x"
  induct_implies where "induct_implies A B == A \<longrightarrow> B"
  induct_equal where "induct_equal x y == x = y"
  induct_conj where "induct_conj A B == A \<and> B"

lemma induct_forall_eq: "(!!x. P x) == Trueprop (induct_forall (\<lambda>x. P x))"
  by (unfold atomize_all induct_forall_def)

lemma induct_implies_eq: "(A ==> B) == Trueprop (induct_implies A B)"
  by (unfold atomize_imp induct_implies_def)

lemma induct_equal_eq: "(x == y) == Trueprop (induct_equal x y)"
  by (unfold atomize_eq induct_equal_def)

lemma induct_conj_eq:
  includes meta_conjunction_syntax
  shows "(A && B) == Trueprop (induct_conj A B)"
  by (unfold atomize_conj induct_conj_def)

lemmas induct_atomize = induct_forall_eq induct_implies_eq induct_equal_eq induct_conj_eq
lemmas induct_rulify [symmetric, standard] = induct_atomize
lemmas induct_rulify_fallback =
  induct_forall_def induct_implies_def induct_equal_def induct_conj_def


lemma induct_forall_conj: "induct_forall (\<lambda>x. induct_conj (A x) (B x)) =
    induct_conj (induct_forall A) (induct_forall B)"
  by (unfold induct_forall_def induct_conj_def) iprover

lemma induct_implies_conj: "induct_implies C (induct_conj A B) =
    induct_conj (induct_implies C A) (induct_implies C B)"
  by (unfold induct_implies_def induct_conj_def) iprover

lemma induct_conj_curry: "(induct_conj A B ==> PROP C) == (A ==> B ==> PROP C)"
proof
  assume r: "induct_conj A B ==> PROP C" and A B
  show "PROP C" by (rule r) (simp add: induct_conj_def `A` `B`)
next
  assume r: "A ==> B ==> PROP C" and "induct_conj A B"
  show "PROP C" by (rule r) (simp_all add: `induct_conj A B` [unfolded induct_conj_def])
qed

lemmas induct_conj = induct_forall_conj induct_implies_conj induct_conj_curry

hide const induct_forall induct_implies induct_equal induct_conj

text {* Method setup. *}

ML {*
  structure InductMethod = InductMethodFun
  (struct
    val cases_default = thm "case_split"
    val atomize = thms "induct_atomize"
    val rulify = thms "induct_rulify"
    val rulify_fallback = thms "induct_rulify_fallback"
  end);
*}

setup InductMethod.setup



subsection {* Other simple lemmas and lemma duplicates *}

lemmas eq_sym_conv = eq_commute
lemmas if_def2 = if_bool_eq_conj

lemma ex1_eq [iff]: "EX! x. x = t" "EX! x. t = x"
  by blast+

lemma choice_eq: "(ALL x. EX! y. P x y) = (EX! f. ALL x. P x (f x))"
  apply (rule iffI)
  apply (rule_tac a = "%x. THE y. P x y" in ex1I)
  apply (fast dest!: theI')
  apply (fast intro: ext the1_equality [symmetric])
  apply (erule ex1E)
  apply (rule allI)
  apply (rule ex1I)
  apply (erule spec)
  apply (erule_tac x = "%z. if z = x then y else f z" in allE)
  apply (erule impE)
  apply (rule allI)
  apply (rule_tac P = "xa = x" in case_split_thm)
  apply (drule_tac [3] x = x in fun_cong, simp_all)
  done

text {* Needs only HOL-lemmas *}
lemma mk_left_commute:
  assumes a: "\<And>x y z. f (f x y) z = f x (f y z)" and
          c: "\<And>x y. f x y = f y x"
  shows "f x (f y z) = f y (f x z)"
  by (rule trans [OF trans [OF c a] arg_cong [OF c, of "f y"]])

end
