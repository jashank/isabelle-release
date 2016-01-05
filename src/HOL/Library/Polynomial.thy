(*  Title:      HOL/Library/Polynomial.thy
    Author:     Brian Huffman
    Author:     Clemens Ballarin
    Author:     Florian Haftmann
*)

section \<open>Polynomials as type over a ring structure\<close>

theory Polynomial
imports Main "~~/src/HOL/GCD" "~~/src/HOL/Library/More_List" "~~/src/HOL/Library/Infinite_Set"
begin

subsection \<open>Auxiliary: operations for lists (later) representing coefficients\<close>

definition cCons :: "'a::zero \<Rightarrow> 'a list \<Rightarrow> 'a list"  (infixr "##" 65)
where
  "x ## xs = (if xs = [] \<and> x = 0 then [] else x # xs)"

lemma cCons_0_Nil_eq [simp]:
  "0 ## [] = []"
  by (simp add: cCons_def)

lemma cCons_Cons_eq [simp]:
  "x ## y # ys = x # y # ys"
  by (simp add: cCons_def)

lemma cCons_append_Cons_eq [simp]:
  "x ## xs @ y # ys = x # xs @ y # ys"
  by (simp add: cCons_def)

lemma cCons_not_0_eq [simp]:
  "x \<noteq> 0 \<Longrightarrow> x ## xs = x # xs"
  by (simp add: cCons_def)

lemma strip_while_not_0_Cons_eq [simp]:
  "strip_while (\<lambda>x. x = 0) (x # xs) = x ## strip_while (\<lambda>x. x = 0) xs"
proof (cases "x = 0")
  case False then show ?thesis by simp
next
  case True show ?thesis
  proof (induct xs rule: rev_induct)
    case Nil with True show ?case by simp
  next
    case (snoc y ys) then show ?case
      by (cases "y = 0") (simp_all add: append_Cons [symmetric] del: append_Cons)
  qed
qed

lemma tl_cCons [simp]:
  "tl (x ## xs) = xs"
  by (simp add: cCons_def)

subsection \<open>Definition of type \<open>poly\<close>\<close>

typedef (overloaded) 'a poly = "{f :: nat \<Rightarrow> 'a::zero. \<forall>\<^sub>\<infinity> n. f n = 0}"
  morphisms coeff Abs_poly by (auto intro!: ALL_MOST)

setup_lifting type_definition_poly

lemma poly_eq_iff: "p = q \<longleftrightarrow> (\<forall>n. coeff p n = coeff q n)"
  by (simp add: coeff_inject [symmetric] fun_eq_iff)

lemma poly_eqI: "(\<And>n. coeff p n = coeff q n) \<Longrightarrow> p = q"
  by (simp add: poly_eq_iff)

lemma MOST_coeff_eq_0: "\<forall>\<^sub>\<infinity> n. coeff p n = 0"
  using coeff [of p] by simp


subsection \<open>Degree of a polynomial\<close>

definition degree :: "'a::zero poly \<Rightarrow> nat"
where
  "degree p = (LEAST n. \<forall>i>n. coeff p i = 0)"

lemma coeff_eq_0:
  assumes "degree p < n"
  shows "coeff p n = 0"
proof -
  have "\<exists>n. \<forall>i>n. coeff p i = 0"
    using MOST_coeff_eq_0 by (simp add: MOST_nat)
  then have "\<forall>i>degree p. coeff p i = 0"
    unfolding degree_def by (rule LeastI_ex)
  with assms show ?thesis by simp
qed

lemma le_degree: "coeff p n \<noteq> 0 \<Longrightarrow> n \<le> degree p"
  by (erule contrapos_np, rule coeff_eq_0, simp)

lemma degree_le: "\<forall>i>n. coeff p i = 0 \<Longrightarrow> degree p \<le> n"
  unfolding degree_def by (erule Least_le)

lemma less_degree_imp: "n < degree p \<Longrightarrow> \<exists>i>n. coeff p i \<noteq> 0"
  unfolding degree_def by (drule not_less_Least, simp)


subsection \<open>The zero polynomial\<close>

instantiation poly :: (zero) zero
begin

lift_definition zero_poly :: "'a poly"
  is "\<lambda>_. 0" by (rule MOST_I) simp

instance ..

end

lemma coeff_0 [simp]:
  "coeff 0 n = 0"
  by transfer rule

lemma degree_0 [simp]:
  "degree 0 = 0"
  by (rule order_antisym [OF degree_le le0]) simp

lemma leading_coeff_neq_0:
  assumes "p \<noteq> 0"
  shows "coeff p (degree p) \<noteq> 0"
proof (cases "degree p")
  case 0
  from \<open>p \<noteq> 0\<close> have "\<exists>n. coeff p n \<noteq> 0"
    by (simp add: poly_eq_iff)
  then obtain n where "coeff p n \<noteq> 0" ..
  hence "n \<le> degree p" by (rule le_degree)
  with \<open>coeff p n \<noteq> 0\<close> and \<open>degree p = 0\<close>
  show "coeff p (degree p) \<noteq> 0" by simp
next
  case (Suc n)
  from \<open>degree p = Suc n\<close> have "n < degree p" by simp
  hence "\<exists>i>n. coeff p i \<noteq> 0" by (rule less_degree_imp)
  then obtain i where "n < i" and "coeff p i \<noteq> 0" by fast
  from \<open>degree p = Suc n\<close> and \<open>n < i\<close> have "degree p \<le> i" by simp
  also from \<open>coeff p i \<noteq> 0\<close> have "i \<le> degree p" by (rule le_degree)
  finally have "degree p = i" .
  with \<open>coeff p i \<noteq> 0\<close> show "coeff p (degree p) \<noteq> 0" by simp
qed

lemma leading_coeff_0_iff [simp]:
  "coeff p (degree p) = 0 \<longleftrightarrow> p = 0"
  by (cases "p = 0", simp, simp add: leading_coeff_neq_0)


subsection \<open>List-style constructor for polynomials\<close>

lift_definition pCons :: "'a::zero \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
  is "\<lambda>a p. case_nat a (coeff p)"
  by (rule MOST_SucD) (simp add: MOST_coeff_eq_0)

lemmas coeff_pCons = pCons.rep_eq

lemma coeff_pCons_0 [simp]:
  "coeff (pCons a p) 0 = a"
  by transfer simp

lemma coeff_pCons_Suc [simp]:
  "coeff (pCons a p) (Suc n) = coeff p n"
  by (simp add: coeff_pCons)

lemma degree_pCons_le:
  "degree (pCons a p) \<le> Suc (degree p)"
  by (rule degree_le) (simp add: coeff_eq_0 coeff_pCons split: nat.split)

lemma degree_pCons_eq:
  "p \<noteq> 0 \<Longrightarrow> degree (pCons a p) = Suc (degree p)"
  apply (rule order_antisym [OF degree_pCons_le])
  apply (rule le_degree, simp)
  done

lemma degree_pCons_0:
  "degree (pCons a 0) = 0"
  apply (rule order_antisym [OF _ le0])
  apply (rule degree_le, simp add: coeff_pCons split: nat.split)
  done

lemma degree_pCons_eq_if [simp]:
  "degree (pCons a p) = (if p = 0 then 0 else Suc (degree p))"
  apply (cases "p = 0", simp_all)
  apply (rule order_antisym [OF _ le0])
  apply (rule degree_le, simp add: coeff_pCons split: nat.split)
  apply (rule order_antisym [OF degree_pCons_le])
  apply (rule le_degree, simp)
  done

lemma pCons_0_0 [simp]:
  "pCons 0 0 = 0"
  by (rule poly_eqI) (simp add: coeff_pCons split: nat.split)

lemma pCons_eq_iff [simp]:
  "pCons a p = pCons b q \<longleftrightarrow> a = b \<and> p = q"
proof safe
  assume "pCons a p = pCons b q"
  then have "coeff (pCons a p) 0 = coeff (pCons b q) 0" by simp
  then show "a = b" by simp
next
  assume "pCons a p = pCons b q"
  then have "\<forall>n. coeff (pCons a p) (Suc n) =
                 coeff (pCons b q) (Suc n)" by simp
  then show "p = q" by (simp add: poly_eq_iff)
qed

lemma pCons_eq_0_iff [simp]:
  "pCons a p = 0 \<longleftrightarrow> a = 0 \<and> p = 0"
  using pCons_eq_iff [of a p 0 0] by simp

lemma pCons_cases [cases type: poly]:
  obtains (pCons) a q where "p = pCons a q"
proof
  show "p = pCons (coeff p 0) (Abs_poly (\<lambda>n. coeff p (Suc n)))"
    by transfer
       (simp_all add: MOST_inj[where f=Suc and P="\<lambda>n. p n = 0" for p] fun_eq_iff Abs_poly_inverse
                 split: nat.split)
qed

lemma pCons_induct [case_names 0 pCons, induct type: poly]:
  assumes zero: "P 0"
  assumes pCons: "\<And>a p. a \<noteq> 0 \<or> p \<noteq> 0 \<Longrightarrow> P p \<Longrightarrow> P (pCons a p)"
  shows "P p"
proof (induct p rule: measure_induct_rule [where f=degree])
  case (less p)
  obtain a q where "p = pCons a q" by (rule pCons_cases)
  have "P q"
  proof (cases "q = 0")
    case True
    then show "P q" by (simp add: zero)
  next
    case False
    then have "degree (pCons a q) = Suc (degree q)"
      by (rule degree_pCons_eq)
    then have "degree q < degree p"
      using \<open>p = pCons a q\<close> by simp
    then show "P q"
      by (rule less.hyps)
  qed
  have "P (pCons a q)"
  proof (cases "a \<noteq> 0 \<or> q \<noteq> 0")
    case True
    with \<open>P q\<close> show ?thesis by (auto intro: pCons)
  next
    case False
    with zero show ?thesis by simp
  qed
  then show ?case
    using \<open>p = pCons a q\<close> by simp
qed

lemma degree_eq_zeroE:
  fixes p :: "'a::zero poly"
  assumes "degree p = 0"
  obtains a where "p = pCons a 0"
proof -
  obtain a q where p: "p = pCons a q" by (cases p)
  with assms have "q = 0" by (cases "q = 0") simp_all
  with p have "p = pCons a 0" by simp
  with that show thesis .
qed


subsection \<open>List-style syntax for polynomials\<close>

syntax
  "_poly" :: "args \<Rightarrow> 'a poly"  ("[:(_):]")

translations
  "[:x, xs:]" == "CONST pCons x [:xs:]"
  "[:x:]" == "CONST pCons x 0"
  "[:x:]" <= "CONST pCons x (_constrain 0 t)"


subsection \<open>Representation of polynomials by lists of coefficients\<close>

primrec Poly :: "'a::zero list \<Rightarrow> 'a poly"
where
  [code_post]: "Poly [] = 0"
| [code_post]: "Poly (a # as) = pCons a (Poly as)"

lemma Poly_replicate_0 [simp]:
  "Poly (replicate n 0) = 0"
  by (induct n) simp_all

lemma Poly_eq_0:
  "Poly as = 0 \<longleftrightarrow> (\<exists>n. as = replicate n 0)"
  by (induct as) (auto simp add: Cons_replicate_eq)
  
lemma degree_Poly: "degree (Poly xs) \<le> length xs"
  by (induction xs) simp_all
  
definition coeffs :: "'a poly \<Rightarrow> 'a::zero list"
where
  "coeffs p = (if p = 0 then [] else map (\<lambda>i. coeff p i) [0 ..< Suc (degree p)])"

lemma coeffs_eq_Nil [simp]:
  "coeffs p = [] \<longleftrightarrow> p = 0"
  by (simp add: coeffs_def)

lemma not_0_coeffs_not_Nil:
  "p \<noteq> 0 \<Longrightarrow> coeffs p \<noteq> []"
  by simp

lemma coeffs_0_eq_Nil [simp]:
  "coeffs 0 = []"
  by simp

lemma coeffs_pCons_eq_cCons [simp]:
  "coeffs (pCons a p) = a ## coeffs p"
proof -
  { fix ms :: "nat list" and f :: "nat \<Rightarrow> 'a" and x :: "'a"
    assume "\<forall>m\<in>set ms. m > 0"
    then have "map (case_nat x f) ms = map f (map (\<lambda>n. n - 1) ms)"
      by (induct ms) (auto split: nat.split)
  }
  note * = this
  show ?thesis
    by (simp add: coeffs_def * upt_conv_Cons coeff_pCons map_decr_upt del: upt_Suc)
qed

lemma length_coeffs: "p \<noteq> 0 \<Longrightarrow> length (coeffs p) = degree p + 1"
  by (simp add: coeffs_def)
  
lemma coeffs_nth:
  assumes "p \<noteq> 0" "n \<le> degree p"
  shows   "coeffs p ! n = coeff p n"
  using assms unfolding coeffs_def by (auto simp del: upt_Suc)

lemma not_0_cCons_eq [simp]:
  "p \<noteq> 0 \<Longrightarrow> a ## coeffs p = a # coeffs p"
  by (simp add: cCons_def)

lemma Poly_coeffs [simp, code abstype]:
  "Poly (coeffs p) = p"
  by (induct p) auto

lemma coeffs_Poly [simp]:
  "coeffs (Poly as) = strip_while (HOL.eq 0) as"
proof (induct as)
  case Nil then show ?case by simp
next
  case (Cons a as)
  have "(\<forall>n. as \<noteq> replicate n 0) \<longleftrightarrow> (\<exists>a\<in>set as. a \<noteq> 0)"
    using replicate_length_same [of as 0] by (auto dest: sym [of _ as])
  with Cons show ?case by auto
qed

lemma last_coeffs_not_0:
  "p \<noteq> 0 \<Longrightarrow> last (coeffs p) \<noteq> 0"
  by (induct p) (auto simp add: cCons_def)

lemma strip_while_coeffs [simp]:
  "strip_while (HOL.eq 0) (coeffs p) = coeffs p"
  by (cases "p = 0") (auto dest: last_coeffs_not_0 intro: strip_while_not_last)

lemma coeffs_eq_iff:
  "p = q \<longleftrightarrow> coeffs p = coeffs q" (is "?P \<longleftrightarrow> ?Q")
proof
  assume ?P then show ?Q by simp
next
  assume ?Q
  then have "Poly (coeffs p) = Poly (coeffs q)" by simp
  then show ?P by simp
qed

lemma coeff_Poly_eq:
  "coeff (Poly xs) n = nth_default 0 xs n"
  apply (induct xs arbitrary: n) apply simp_all
  by (metis nat.case not0_implies_Suc nth_default_Cons_0 nth_default_Cons_Suc pCons.rep_eq)

lemma nth_default_coeffs_eq:
  "nth_default 0 (coeffs p) = coeff p"
  by (simp add: fun_eq_iff coeff_Poly_eq [symmetric])

lemma [code]:
  "coeff p = nth_default 0 (coeffs p)"
  by (simp add: nth_default_coeffs_eq)

lemma coeffs_eqI:
  assumes coeff: "\<And>n. coeff p n = nth_default 0 xs n"
  assumes zero: "xs \<noteq> [] \<Longrightarrow> last xs \<noteq> 0"
  shows "coeffs p = xs"
proof -
  from coeff have "p = Poly xs" by (simp add: poly_eq_iff coeff_Poly_eq)
  with zero show ?thesis by simp (cases xs, simp_all)
qed

lemma degree_eq_length_coeffs [code]:
  "degree p = length (coeffs p) - 1"
  by (simp add: coeffs_def)

lemma length_coeffs_degree:
  "p \<noteq> 0 \<Longrightarrow> length (coeffs p) = Suc (degree p)"
  by (induct p) (auto simp add: cCons_def)

lemma [code abstract]:
  "coeffs 0 = []"
  by (fact coeffs_0_eq_Nil)

lemma [code abstract]:
  "coeffs (pCons a p) = a ## coeffs p"
  by (fact coeffs_pCons_eq_cCons)

instantiation poly :: ("{zero, equal}") equal
begin

definition
  [code]: "HOL.equal (p::'a poly) q \<longleftrightarrow> HOL.equal (coeffs p) (coeffs q)"

instance
  by standard (simp add: equal equal_poly_def coeffs_eq_iff)

end

lemma [code nbe]: "HOL.equal (p :: _ poly) p \<longleftrightarrow> True"
  by (fact equal_refl)

definition is_zero :: "'a::zero poly \<Rightarrow> bool"
where
  [code]: "is_zero p \<longleftrightarrow> List.null (coeffs p)"

lemma is_zero_null [code_abbrev]:
  "is_zero p \<longleftrightarrow> p = 0"
  by (simp add: is_zero_def null_def)


subsection \<open>Fold combinator for polynomials\<close>

definition fold_coeffs :: "('a::zero \<Rightarrow> 'b \<Rightarrow> 'b) \<Rightarrow> 'a poly \<Rightarrow> 'b \<Rightarrow> 'b"
where
  "fold_coeffs f p = foldr f (coeffs p)"

lemma fold_coeffs_0_eq [simp]:
  "fold_coeffs f 0 = id"
  by (simp add: fold_coeffs_def)

lemma fold_coeffs_pCons_eq [simp]:
  "f 0 = id \<Longrightarrow> fold_coeffs f (pCons a p) = f a \<circ> fold_coeffs f p"
  by (simp add: fold_coeffs_def cCons_def fun_eq_iff)

lemma fold_coeffs_pCons_0_0_eq [simp]:
  "fold_coeffs f (pCons 0 0) = id"
  by (simp add: fold_coeffs_def)

lemma fold_coeffs_pCons_coeff_not_0_eq [simp]:
  "a \<noteq> 0 \<Longrightarrow> fold_coeffs f (pCons a p) = f a \<circ> fold_coeffs f p"
  by (simp add: fold_coeffs_def)

lemma fold_coeffs_pCons_not_0_0_eq [simp]:
  "p \<noteq> 0 \<Longrightarrow> fold_coeffs f (pCons a p) = f a \<circ> fold_coeffs f p"
  by (simp add: fold_coeffs_def)


subsection \<open>Canonical morphism on polynomials -- evaluation\<close>

definition poly :: "'a::comm_semiring_0 poly \<Rightarrow> 'a \<Rightarrow> 'a"
where
  "poly p = fold_coeffs (\<lambda>a f x. a + x * f x) p (\<lambda>x. 0)" \<comment> \<open>The Horner Schema\<close>

lemma poly_0 [simp]:
  "poly 0 x = 0"
  by (simp add: poly_def)

lemma poly_pCons [simp]:
  "poly (pCons a p) x = a + x * poly p x"
  by (cases "p = 0 \<and> a = 0") (auto simp add: poly_def)

lemma poly_altdef: 
  "poly p (x :: 'a :: {comm_semiring_0, semiring_1}) = (\<Sum>i\<le>degree p. coeff p i * x ^ i)"
proof (induction p rule: pCons_induct)
  case (pCons a p)
    show ?case
    proof (cases "p = 0")
      case False
      let ?p' = "pCons a p"
      note poly_pCons[of a p x]
      also note pCons.IH
      also have "a + x * (\<Sum>i\<le>degree p. coeff p i * x ^ i) =
                 coeff ?p' 0 * x^0 + (\<Sum>i\<le>degree p. coeff ?p' (Suc i) * x^Suc i)"
          by (simp add: field_simps setsum_right_distrib coeff_pCons)
      also note setsum_atMost_Suc_shift[symmetric]
      also note degree_pCons_eq[OF `p \<noteq> 0`, of a, symmetric]
      finally show ?thesis .
   qed simp
qed simp


subsection \<open>Monomials\<close>

lift_definition monom :: "'a \<Rightarrow> nat \<Rightarrow> 'a::zero poly"
  is "\<lambda>a m n. if m = n then a else 0"
  by (simp add: MOST_iff_cofinite)

lemma coeff_monom [simp]:
  "coeff (monom a m) n = (if m = n then a else 0)"
  by transfer rule

lemma monom_0:
  "monom a 0 = pCons a 0"
  by (rule poly_eqI) (simp add: coeff_pCons split: nat.split)

lemma monom_Suc:
  "monom a (Suc n) = pCons 0 (monom a n)"
  by (rule poly_eqI) (simp add: coeff_pCons split: nat.split)

lemma monom_eq_0 [simp]: "monom 0 n = 0"
  by (rule poly_eqI) simp

lemma monom_eq_0_iff [simp]: "monom a n = 0 \<longleftrightarrow> a = 0"
  by (simp add: poly_eq_iff)

lemma monom_eq_iff [simp]: "monom a n = monom b n \<longleftrightarrow> a = b"
  by (simp add: poly_eq_iff)

lemma degree_monom_le: "degree (monom a n) \<le> n"
  by (rule degree_le, simp)

lemma degree_monom_eq: "a \<noteq> 0 \<Longrightarrow> degree (monom a n) = n"
  apply (rule order_antisym [OF degree_monom_le])
  apply (rule le_degree, simp)
  done

lemma coeffs_monom [code abstract]:
  "coeffs (monom a n) = (if a = 0 then [] else replicate n 0 @ [a])"
  by (induct n) (simp_all add: monom_0 monom_Suc)

lemma fold_coeffs_monom [simp]:
  "a \<noteq> 0 \<Longrightarrow> fold_coeffs f (monom a n) = f 0 ^^ n \<circ> f a"
  by (simp add: fold_coeffs_def coeffs_monom fun_eq_iff)

lemma poly_monom:
  fixes a x :: "'a::{comm_semiring_1}"
  shows "poly (monom a n) x = a * x ^ n"
  by (cases "a = 0", simp_all)
    (induct n, simp_all add: mult.left_commute poly_def)

    
subsection \<open>Addition and subtraction\<close>

instantiation poly :: (comm_monoid_add) comm_monoid_add
begin

lift_definition plus_poly :: "'a poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
  is "\<lambda>p q n. coeff p n + coeff q n"
proof -
  fix q p :: "'a poly"
  show "\<forall>\<^sub>\<infinity>n. coeff p n + coeff q n = 0"
    using MOST_coeff_eq_0[of p] MOST_coeff_eq_0[of q] by eventually_elim simp
qed

lemma coeff_add [simp]: "coeff (p + q) n = coeff p n + coeff q n"
  by (simp add: plus_poly.rep_eq)

instance
proof
  fix p q r :: "'a poly"
  show "(p + q) + r = p + (q + r)"
    by (simp add: poly_eq_iff add.assoc)
  show "p + q = q + p"
    by (simp add: poly_eq_iff add.commute)
  show "0 + p = p"
    by (simp add: poly_eq_iff)
qed

end

instantiation poly :: (cancel_comm_monoid_add) cancel_comm_monoid_add
begin

lift_definition minus_poly :: "'a poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
  is "\<lambda>p q n. coeff p n - coeff q n"
proof -
  fix q p :: "'a poly"
  show "\<forall>\<^sub>\<infinity>n. coeff p n - coeff q n = 0"
    using MOST_coeff_eq_0[of p] MOST_coeff_eq_0[of q] by eventually_elim simp
qed

lemma coeff_diff [simp]: "coeff (p - q) n = coeff p n - coeff q n"
  by (simp add: minus_poly.rep_eq)

instance
proof
  fix p q r :: "'a poly"
  show "p + q - p = q"
    by (simp add: poly_eq_iff)
  show "p - q - r = p - (q + r)"
    by (simp add: poly_eq_iff diff_diff_eq)
qed

end

instantiation poly :: (ab_group_add) ab_group_add
begin

lift_definition uminus_poly :: "'a poly \<Rightarrow> 'a poly"
  is "\<lambda>p n. - coeff p n"
proof -
  fix p :: "'a poly"
  show "\<forall>\<^sub>\<infinity>n. - coeff p n = 0"
    using MOST_coeff_eq_0 by simp
qed

lemma coeff_minus [simp]: "coeff (- p) n = - coeff p n"
  by (simp add: uminus_poly.rep_eq)

instance
proof
  fix p q :: "'a poly"
  show "- p + p = 0"
    by (simp add: poly_eq_iff)
  show "p - q = p + - q"
    by (simp add: poly_eq_iff)
qed

end

lemma add_pCons [simp]:
  "pCons a p + pCons b q = pCons (a + b) (p + q)"
  by (rule poly_eqI, simp add: coeff_pCons split: nat.split)

lemma minus_pCons [simp]:
  "- pCons a p = pCons (- a) (- p)"
  by (rule poly_eqI, simp add: coeff_pCons split: nat.split)

lemma diff_pCons [simp]:
  "pCons a p - pCons b q = pCons (a - b) (p - q)"
  by (rule poly_eqI, simp add: coeff_pCons split: nat.split)

lemma degree_add_le_max: "degree (p + q) \<le> max (degree p) (degree q)"
  by (rule degree_le, auto simp add: coeff_eq_0)

lemma degree_add_le:
  "\<lbrakk>degree p \<le> n; degree q \<le> n\<rbrakk> \<Longrightarrow> degree (p + q) \<le> n"
  by (auto intro: order_trans degree_add_le_max)

lemma degree_add_less:
  "\<lbrakk>degree p < n; degree q < n\<rbrakk> \<Longrightarrow> degree (p + q) < n"
  by (auto intro: le_less_trans degree_add_le_max)

lemma degree_add_eq_right:
  "degree p < degree q \<Longrightarrow> degree (p + q) = degree q"
  apply (cases "q = 0", simp)
  apply (rule order_antisym)
  apply (simp add: degree_add_le)
  apply (rule le_degree)
  apply (simp add: coeff_eq_0)
  done

lemma degree_add_eq_left:
  "degree q < degree p \<Longrightarrow> degree (p + q) = degree p"
  using degree_add_eq_right [of q p]
  by (simp add: add.commute)

lemma degree_minus [simp]:
  "degree (- p) = degree p"
  unfolding degree_def by simp

lemma degree_diff_le_max:
  fixes p q :: "'a :: ab_group_add poly"
  shows "degree (p - q) \<le> max (degree p) (degree q)"
  using degree_add_le [where p=p and q="-q"]
  by simp

lemma degree_diff_le:
  fixes p q :: "'a :: ab_group_add poly"
  assumes "degree p \<le> n" and "degree q \<le> n"
  shows "degree (p - q) \<le> n"
  using assms degree_add_le [of p n "- q"] by simp

lemma degree_diff_less:
  fixes p q :: "'a :: ab_group_add poly"
  assumes "degree p < n" and "degree q < n"
  shows "degree (p - q) < n"
  using assms degree_add_less [of p n "- q"] by simp

lemma add_monom: "monom a n + monom b n = monom (a + b) n"
  by (rule poly_eqI) simp

lemma diff_monom: "monom a n - monom b n = monom (a - b) n"
  by (rule poly_eqI) simp

lemma minus_monom: "- monom a n = monom (-a) n"
  by (rule poly_eqI) simp

lemma coeff_setsum: "coeff (\<Sum>x\<in>A. p x) i = (\<Sum>x\<in>A. coeff (p x) i)"
  by (cases "finite A", induct set: finite, simp_all)

lemma monom_setsum: "monom (\<Sum>x\<in>A. a x) n = (\<Sum>x\<in>A. monom (a x) n)"
  by (rule poly_eqI) (simp add: coeff_setsum)

fun plus_coeffs :: "'a::comm_monoid_add list \<Rightarrow> 'a list \<Rightarrow> 'a list"
where
  "plus_coeffs xs [] = xs"
| "plus_coeffs [] ys = ys"
| "plus_coeffs (x # xs) (y # ys) = (x + y) ## plus_coeffs xs ys"

lemma coeffs_plus_eq_plus_coeffs [code abstract]:
  "coeffs (p + q) = plus_coeffs (coeffs p) (coeffs q)"
proof -
  { fix xs ys :: "'a list" and n
    have "nth_default 0 (plus_coeffs xs ys) n = nth_default 0 xs n + nth_default 0 ys n"
    proof (induct xs ys arbitrary: n rule: plus_coeffs.induct)
      case (3 x xs y ys n)
      then show ?case by (cases n) (auto simp add: cCons_def)
    qed simp_all }
  note * = this
  { fix xs ys :: "'a list"
    assume "xs \<noteq> [] \<Longrightarrow> last xs \<noteq> 0" and "ys \<noteq> [] \<Longrightarrow> last ys \<noteq> 0"
    moreover assume "plus_coeffs xs ys \<noteq> []"
    ultimately have "last (plus_coeffs xs ys) \<noteq> 0"
    proof (induct xs ys rule: plus_coeffs.induct)
      case (3 x xs y ys) then show ?case by (auto simp add: cCons_def) metis
    qed simp_all }
  note ** = this
  show ?thesis
    apply (rule coeffs_eqI)
    apply (simp add: * nth_default_coeffs_eq)
    apply (rule **)
    apply (auto dest: last_coeffs_not_0)
    done
qed

lemma coeffs_uminus [code abstract]:
  "coeffs (- p) = map (\<lambda>a. - a) (coeffs p)"
  by (rule coeffs_eqI)
    (simp_all add: not_0_coeffs_not_Nil last_map last_coeffs_not_0 nth_default_map_eq nth_default_coeffs_eq)

lemma [code]:
  fixes p q :: "'a::ab_group_add poly"
  shows "p - q = p + - q"
  by (fact diff_conv_add_uminus)

lemma poly_add [simp]: "poly (p + q) x = poly p x + poly q x"
  apply (induct p arbitrary: q, simp)
  apply (case_tac q, simp, simp add: algebra_simps)
  done

lemma poly_minus [simp]:
  fixes x :: "'a::comm_ring"
  shows "poly (- p) x = - poly p x"
  by (induct p) simp_all

lemma poly_diff [simp]:
  fixes x :: "'a::comm_ring"
  shows "poly (p - q) x = poly p x - poly q x"
  using poly_add [of p "- q" x] by simp

lemma poly_setsum: "poly (\<Sum>k\<in>A. p k) x = (\<Sum>k\<in>A. poly (p k) x)"
  by (induct A rule: infinite_finite_induct) simp_all

lemma Poly_snoc: "Poly (xs @ [x]) = Poly xs + monom x (length xs)"
  by (induction xs) (simp_all add: monom_0 monom_Suc)


subsection \<open>Multiplication by a constant, polynomial multiplication and the unit polynomial\<close>

lift_definition smult :: "'a::comm_semiring_0 \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
  is "\<lambda>a p n. a * coeff p n"
proof -
  fix a :: 'a and p :: "'a poly" show "\<forall>\<^sub>\<infinity> i. a * coeff p i = 0"
    using MOST_coeff_eq_0[of p] by eventually_elim simp
qed

lemma coeff_smult [simp]:
  "coeff (smult a p) n = a * coeff p n"
  by (simp add: smult.rep_eq)

lemma degree_smult_le: "degree (smult a p) \<le> degree p"
  by (rule degree_le, simp add: coeff_eq_0)

lemma smult_smult [simp]: "smult a (smult b p) = smult (a * b) p"
  by (rule poly_eqI, simp add: mult.assoc)

lemma smult_0_right [simp]: "smult a 0 = 0"
  by (rule poly_eqI, simp)

lemma smult_0_left [simp]: "smult 0 p = 0"
  by (rule poly_eqI, simp)

lemma smult_1_left [simp]: "smult (1::'a::comm_semiring_1) p = p"
  by (rule poly_eqI, simp)

lemma smult_add_right:
  "smult a (p + q) = smult a p + smult a q"
  by (rule poly_eqI, simp add: algebra_simps)

lemma smult_add_left:
  "smult (a + b) p = smult a p + smult b p"
  by (rule poly_eqI, simp add: algebra_simps)

lemma smult_minus_right [simp]:
  "smult (a::'a::comm_ring) (- p) = - smult a p"
  by (rule poly_eqI, simp)

lemma smult_minus_left [simp]:
  "smult (- a::'a::comm_ring) p = - smult a p"
  by (rule poly_eqI, simp)

lemma smult_diff_right:
  "smult (a::'a::comm_ring) (p - q) = smult a p - smult a q"
  by (rule poly_eqI, simp add: algebra_simps)

lemma smult_diff_left:
  "smult (a - b::'a::comm_ring) p = smult a p - smult b p"
  by (rule poly_eqI, simp add: algebra_simps)

lemmas smult_distribs =
  smult_add_left smult_add_right
  smult_diff_left smult_diff_right

lemma smult_pCons [simp]:
  "smult a (pCons b p) = pCons (a * b) (smult a p)"
  by (rule poly_eqI, simp add: coeff_pCons split: nat.split)

lemma smult_monom: "smult a (monom b n) = monom (a * b) n"
  by (induct n, simp add: monom_0, simp add: monom_Suc)

lemma degree_smult_eq [simp]:
  fixes a :: "'a::idom"
  shows "degree (smult a p) = (if a = 0 then 0 else degree p)"
  by (cases "a = 0", simp, simp add: degree_def)

lemma smult_eq_0_iff [simp]:
  fixes a :: "'a::idom"
  shows "smult a p = 0 \<longleftrightarrow> a = 0 \<or> p = 0"
  by (simp add: poly_eq_iff)

lemma coeffs_smult [code abstract]:
  fixes p :: "'a::idom poly"
  shows "coeffs (smult a p) = (if a = 0 then [] else map (Groups.times a) (coeffs p))"
  by (rule coeffs_eqI)
    (auto simp add: not_0_coeffs_not_Nil last_map last_coeffs_not_0 nth_default_map_eq nth_default_coeffs_eq)

instantiation poly :: (comm_semiring_0) comm_semiring_0
begin

definition
  "p * q = fold_coeffs (\<lambda>a p. smult a q + pCons 0 p) p 0"

lemma mult_poly_0_left: "(0::'a poly) * q = 0"
  by (simp add: times_poly_def)

lemma mult_pCons_left [simp]:
  "pCons a p * q = smult a q + pCons 0 (p * q)"
  by (cases "p = 0 \<and> a = 0") (auto simp add: times_poly_def)

lemma mult_poly_0_right: "p * (0::'a poly) = 0"
  by (induct p) (simp add: mult_poly_0_left, simp)

lemma mult_pCons_right [simp]:
  "p * pCons a q = smult a p + pCons 0 (p * q)"
  by (induct p) (simp add: mult_poly_0_left, simp add: algebra_simps)

lemmas mult_poly_0 = mult_poly_0_left mult_poly_0_right

lemma mult_smult_left [simp]:
  "smult a p * q = smult a (p * q)"
  by (induct p) (simp add: mult_poly_0, simp add: smult_add_right)

lemma mult_smult_right [simp]:
  "p * smult a q = smult a (p * q)"
  by (induct q) (simp add: mult_poly_0, simp add: smult_add_right)

lemma mult_poly_add_left:
  fixes p q r :: "'a poly"
  shows "(p + q) * r = p * r + q * r"
  by (induct r) (simp add: mult_poly_0, simp add: smult_distribs algebra_simps)

instance
proof
  fix p q r :: "'a poly"
  show 0: "0 * p = 0"
    by (rule mult_poly_0_left)
  show "p * 0 = 0"
    by (rule mult_poly_0_right)
  show "(p + q) * r = p * r + q * r"
    by (rule mult_poly_add_left)
  show "(p * q) * r = p * (q * r)"
    by (induct p, simp add: mult_poly_0, simp add: mult_poly_add_left)
  show "p * q = q * p"
    by (induct p, simp add: mult_poly_0, simp)
qed

end

instance poly :: (comm_semiring_0_cancel) comm_semiring_0_cancel ..

lemma coeff_mult:
  "coeff (p * q) n = (\<Sum>i\<le>n. coeff p i * coeff q (n-i))"
proof (induct p arbitrary: n)
  case 0 show ?case by simp
next
  case (pCons a p n) thus ?case
    by (cases n, simp, simp add: setsum_atMost_Suc_shift
                            del: setsum_atMost_Suc)
qed

lemma degree_mult_le: "degree (p * q) \<le> degree p + degree q"
apply (rule degree_le)
apply (induct p)
apply simp
apply (simp add: coeff_eq_0 coeff_pCons split: nat.split)
done

lemma mult_monom: "monom a m * monom b n = monom (a * b) (m + n)"
  by (induct m) (simp add: monom_0 smult_monom, simp add: monom_Suc)

instantiation poly :: (comm_semiring_1) comm_semiring_1
begin

definition one_poly_def: "1 = pCons 1 0"

instance
proof
  show "1 * p = p" for p :: "'a poly"
    unfolding one_poly_def by simp
  show "0 \<noteq> (1::'a poly)"
    unfolding one_poly_def by simp
qed

end

instance poly :: (comm_ring) comm_ring ..

instance poly :: (comm_ring_1) comm_ring_1 ..

lemma coeff_1 [simp]: "coeff 1 n = (if n = 0 then 1 else 0)"
  unfolding one_poly_def
  by (simp add: coeff_pCons split: nat.split)

lemma monom_eq_1 [simp]:
  "monom 1 0 = 1"
  by (simp add: monom_0 one_poly_def)
  
lemma degree_1 [simp]: "degree 1 = 0"
  unfolding one_poly_def
  by (rule degree_pCons_0)

lemma coeffs_1_eq [simp, code abstract]:
  "coeffs 1 = [1]"
  by (simp add: one_poly_def)

lemma degree_power_le:
  "degree (p ^ n) \<le> degree p * n"
  by (induct n) (auto intro: order_trans degree_mult_le)

lemma poly_smult [simp]:
  "poly (smult a p) x = a * poly p x"
  by (induct p, simp, simp add: algebra_simps)

lemma poly_mult [simp]:
  "poly (p * q) x = poly p x * poly q x"
  by (induct p, simp_all, simp add: algebra_simps)

lemma poly_1 [simp]:
  "poly 1 x = 1"
  by (simp add: one_poly_def)

lemma poly_power [simp]:
  fixes p :: "'a::{comm_semiring_1} poly"
  shows "poly (p ^ n) x = poly p x ^ n"
  by (induct n) simp_all

  
subsection \<open>Conversions from natural numbers\<close>

lemma of_nat_poly: "of_nat n = [:of_nat n :: 'a :: comm_semiring_1:]"
proof (induction n)
  case (Suc n)
  hence "of_nat (Suc n) = 1 + (of_nat n :: 'a poly)" 
    by simp
  also have "(of_nat n :: 'a poly) = [: of_nat n :]" 
    by (subst Suc) (rule refl)
  also have "1 = [:1:]" by (simp add: one_poly_def)
  finally show ?case by (subst (asm) add_pCons) simp
qed simp

lemma degree_of_nat [simp]: "degree (of_nat n) = 0"
  by (simp add: of_nat_poly)

lemma degree_numeral [simp]: "degree (numeral n) = 0"
  by (subst of_nat_numeral [symmetric], subst of_nat_poly) simp

lemma numeral_poly: "numeral n = [:numeral n:]"
  by (subst of_nat_numeral [symmetric], subst of_nat_poly) simp

subsection \<open>Lemmas about divisibility\<close>

lemma dvd_smult: "p dvd q \<Longrightarrow> p dvd smult a q"
proof -
  assume "p dvd q"
  then obtain k where "q = p * k" ..
  then have "smult a q = p * smult a k" by simp
  then show "p dvd smult a q" ..
qed

lemma dvd_smult_cancel:
  fixes a :: "'a::field"
  shows "p dvd smult a q \<Longrightarrow> a \<noteq> 0 \<Longrightarrow> p dvd q"
  by (drule dvd_smult [where a="inverse a"]) simp

lemma dvd_smult_iff:
  fixes a :: "'a::field"
  shows "a \<noteq> 0 \<Longrightarrow> p dvd smult a q \<longleftrightarrow> p dvd q"
  by (safe elim!: dvd_smult dvd_smult_cancel)

lemma smult_dvd_cancel:
  "smult a p dvd q \<Longrightarrow> p dvd q"
proof -
  assume "smult a p dvd q"
  then obtain k where "q = smult a p * k" ..
  then have "q = p * smult a k" by simp
  then show "p dvd q" ..
qed

lemma smult_dvd:
  fixes a :: "'a::field"
  shows "p dvd q \<Longrightarrow> a \<noteq> 0 \<Longrightarrow> smult a p dvd q"
  by (rule smult_dvd_cancel [where a="inverse a"]) simp

lemma smult_dvd_iff:
  fixes a :: "'a::field"
  shows "smult a p dvd q \<longleftrightarrow> (if a = 0 then q = 0 else p dvd q)"
  by (auto elim: smult_dvd smult_dvd_cancel)


subsection \<open>Polynomials form an integral domain\<close>

lemma coeff_mult_degree_sum:
  "coeff (p * q) (degree p + degree q) =
   coeff p (degree p) * coeff q (degree q)"
  by (induct p, simp, simp add: coeff_eq_0)

instance poly :: (idom) idom
proof
  fix p q :: "'a poly"
  assume "p \<noteq> 0" and "q \<noteq> 0"
  have "coeff (p * q) (degree p + degree q) =
        coeff p (degree p) * coeff q (degree q)"
    by (rule coeff_mult_degree_sum)
  also have "coeff p (degree p) * coeff q (degree q) \<noteq> 0"
    using \<open>p \<noteq> 0\<close> and \<open>q \<noteq> 0\<close> by simp
  finally have "\<exists>n. coeff (p * q) n \<noteq> 0" ..
  thus "p * q \<noteq> 0" by (simp add: poly_eq_iff)
qed

lemma degree_mult_eq:
  fixes p q :: "'a::idom poly"
  shows "\<lbrakk>p \<noteq> 0; q \<noteq> 0\<rbrakk> \<Longrightarrow> degree (p * q) = degree p + degree q"
apply (rule order_antisym [OF degree_mult_le le_degree])
apply (simp add: coeff_mult_degree_sum)
done

lemma degree_mult_right_le:
  fixes p q :: "'a::idom poly"
  assumes "q \<noteq> 0"
  shows "degree p \<le> degree (p * q)"
  using assms by (cases "p = 0") (simp_all add: degree_mult_eq)

lemma coeff_degree_mult:
  fixes p q :: "'a::idom poly"
  shows "coeff (p * q) (degree (p * q)) =
    coeff q (degree q) * coeff p (degree p)"
  by (cases "p = 0 \<or> q = 0") (auto simp add: degree_mult_eq coeff_mult_degree_sum)

lemma dvd_imp_degree_le:
  fixes p q :: "'a::idom poly"
  shows "\<lbrakk>p dvd q; q \<noteq> 0\<rbrakk> \<Longrightarrow> degree p \<le> degree q"
  by (erule dvdE, simp add: degree_mult_eq)


subsection \<open>Polynomials form an ordered integral domain\<close>

definition pos_poly :: "'a::linordered_idom poly \<Rightarrow> bool"
where
  "pos_poly p \<longleftrightarrow> 0 < coeff p (degree p)"

lemma pos_poly_pCons:
  "pos_poly (pCons a p) \<longleftrightarrow> pos_poly p \<or> (p = 0 \<and> 0 < a)"
  unfolding pos_poly_def by simp

lemma not_pos_poly_0 [simp]: "\<not> pos_poly 0"
  unfolding pos_poly_def by simp

lemma pos_poly_add: "\<lbrakk>pos_poly p; pos_poly q\<rbrakk> \<Longrightarrow> pos_poly (p + q)"
  apply (induct p arbitrary: q, simp)
  apply (case_tac q, force simp add: pos_poly_pCons add_pos_pos)
  done

lemma pos_poly_mult: "\<lbrakk>pos_poly p; pos_poly q\<rbrakk> \<Longrightarrow> pos_poly (p * q)"
  unfolding pos_poly_def
  apply (subgoal_tac "p \<noteq> 0 \<and> q \<noteq> 0")
  apply (simp add: degree_mult_eq coeff_mult_degree_sum)
  apply auto
  done

lemma pos_poly_total: "p = 0 \<or> pos_poly p \<or> pos_poly (- p)"
by (induct p) (auto simp add: pos_poly_pCons)

lemma last_coeffs_eq_coeff_degree:
  "p \<noteq> 0 \<Longrightarrow> last (coeffs p) = coeff p (degree p)"
  by (simp add: coeffs_def)

lemma pos_poly_coeffs [code]:
  "pos_poly p \<longleftrightarrow> (let as = coeffs p in as \<noteq> [] \<and> last as > 0)" (is "?P \<longleftrightarrow> ?Q")
proof
  assume ?Q then show ?P by (auto simp add: pos_poly_def last_coeffs_eq_coeff_degree)
next
  assume ?P then have *: "0 < coeff p (degree p)" by (simp add: pos_poly_def)
  then have "p \<noteq> 0" by auto
  with * show ?Q by (simp add: last_coeffs_eq_coeff_degree)
qed

instantiation poly :: (linordered_idom) linordered_idom
begin

definition
  "x < y \<longleftrightarrow> pos_poly (y - x)"

definition
  "x \<le> y \<longleftrightarrow> x = y \<or> pos_poly (y - x)"

definition
  "\<bar>x::'a poly\<bar> = (if x < 0 then - x else x)"

definition
  "sgn (x::'a poly) = (if x = 0 then 0 else if 0 < x then 1 else - 1)"

instance
proof
  fix x y z :: "'a poly"
  show "x < y \<longleftrightarrow> x \<le> y \<and> \<not> y \<le> x"
    unfolding less_eq_poly_def less_poly_def
    apply safe
    apply simp
    apply (drule (1) pos_poly_add)
    apply simp
    done
  show "x \<le> x"
    unfolding less_eq_poly_def by simp
  show "x \<le> y \<Longrightarrow> y \<le> z \<Longrightarrow> x \<le> z"
    unfolding less_eq_poly_def
    apply safe
    apply (drule (1) pos_poly_add)
    apply (simp add: algebra_simps)
    done
  show "x \<le> y \<Longrightarrow> y \<le> x \<Longrightarrow> x = y"
    unfolding less_eq_poly_def
    apply safe
    apply (drule (1) pos_poly_add)
    apply simp
    done
  show "x \<le> y \<Longrightarrow> z + x \<le> z + y"
    unfolding less_eq_poly_def
    apply safe
    apply (simp add: algebra_simps)
    done
  show "x \<le> y \<or> y \<le> x"
    unfolding less_eq_poly_def
    using pos_poly_total [of "x - y"]
    by auto
  show "x < y \<Longrightarrow> 0 < z \<Longrightarrow> z * x < z * y"
    unfolding less_poly_def
    by (simp add: right_diff_distrib [symmetric] pos_poly_mult)
  show "\<bar>x\<bar> = (if x < 0 then - x else x)"
    by (rule abs_poly_def)
  show "sgn x = (if x = 0 then 0 else if 0 < x then 1 else - 1)"
    by (rule sgn_poly_def)
qed

end

text \<open>TODO: Simplification rules for comparisons\<close>


subsection \<open>Synthetic division and polynomial roots\<close>

text \<open>
  Synthetic division is simply division by the linear polynomial @{term "x - c"}.
\<close>

definition synthetic_divmod :: "'a::comm_semiring_0 poly \<Rightarrow> 'a \<Rightarrow> 'a poly \<times> 'a"
where
  "synthetic_divmod p c = fold_coeffs (\<lambda>a (q, r). (pCons r q, a + c * r)) p (0, 0)"

definition synthetic_div :: "'a::comm_semiring_0 poly \<Rightarrow> 'a \<Rightarrow> 'a poly"
where
  "synthetic_div p c = fst (synthetic_divmod p c)"

lemma synthetic_divmod_0 [simp]:
  "synthetic_divmod 0 c = (0, 0)"
  by (simp add: synthetic_divmod_def)

lemma synthetic_divmod_pCons [simp]:
  "synthetic_divmod (pCons a p) c = (\<lambda>(q, r). (pCons r q, a + c * r)) (synthetic_divmod p c)"
  by (cases "p = 0 \<and> a = 0") (auto simp add: synthetic_divmod_def)

lemma synthetic_div_0 [simp]:
  "synthetic_div 0 c = 0"
  unfolding synthetic_div_def by simp

lemma synthetic_div_unique_lemma: "smult c p = pCons a p \<Longrightarrow> p = 0"
by (induct p arbitrary: a) simp_all

lemma snd_synthetic_divmod:
  "snd (synthetic_divmod p c) = poly p c"
  by (induct p, simp, simp add: split_def)

lemma synthetic_div_pCons [simp]:
  "synthetic_div (pCons a p) c = pCons (poly p c) (synthetic_div p c)"
  unfolding synthetic_div_def
  by (simp add: split_def snd_synthetic_divmod)

lemma synthetic_div_eq_0_iff:
  "synthetic_div p c = 0 \<longleftrightarrow> degree p = 0"
  by (induct p, simp, case_tac p, simp)

lemma degree_synthetic_div:
  "degree (synthetic_div p c) = degree p - 1"
  by (induct p, simp, simp add: synthetic_div_eq_0_iff)

lemma synthetic_div_correct:
  "p + smult c (synthetic_div p c) = pCons (poly p c) (synthetic_div p c)"
  by (induct p) simp_all

lemma synthetic_div_unique:
  "p + smult c q = pCons r q \<Longrightarrow> r = poly p c \<and> q = synthetic_div p c"
apply (induct p arbitrary: q r)
apply (simp, frule synthetic_div_unique_lemma, simp)
apply (case_tac q, force)
done

lemma synthetic_div_correct':
  fixes c :: "'a::comm_ring_1"
  shows "[:-c, 1:] * synthetic_div p c + [:poly p c:] = p"
  using synthetic_div_correct [of p c]
  by (simp add: algebra_simps)

lemma poly_eq_0_iff_dvd:
  fixes c :: "'a::idom"
  shows "poly p c = 0 \<longleftrightarrow> [:-c, 1:] dvd p"
proof
  assume "poly p c = 0"
  with synthetic_div_correct' [of c p]
  have "p = [:-c, 1:] * synthetic_div p c" by simp
  then show "[:-c, 1:] dvd p" ..
next
  assume "[:-c, 1:] dvd p"
  then obtain k where "p = [:-c, 1:] * k" by (rule dvdE)
  then show "poly p c = 0" by simp
qed

lemma dvd_iff_poly_eq_0:
  fixes c :: "'a::idom"
  shows "[:c, 1:] dvd p \<longleftrightarrow> poly p (-c) = 0"
  by (simp add: poly_eq_0_iff_dvd)

lemma poly_roots_finite:
  fixes p :: "'a::idom poly"
  shows "p \<noteq> 0 \<Longrightarrow> finite {x. poly p x = 0}"
proof (induct n \<equiv> "degree p" arbitrary: p)
  case (0 p)
  then obtain a where "a \<noteq> 0" and "p = [:a:]"
    by (cases p, simp split: if_splits)
  then show "finite {x. poly p x = 0}" by simp
next
  case (Suc n p)
  show "finite {x. poly p x = 0}"
  proof (cases "\<exists>x. poly p x = 0")
    case False
    then show "finite {x. poly p x = 0}" by simp
  next
    case True
    then obtain a where "poly p a = 0" ..
    then have "[:-a, 1:] dvd p" by (simp only: poly_eq_0_iff_dvd)
    then obtain k where k: "p = [:-a, 1:] * k" ..
    with \<open>p \<noteq> 0\<close> have "k \<noteq> 0" by auto
    with k have "degree p = Suc (degree k)"
      by (simp add: degree_mult_eq del: mult_pCons_left)
    with \<open>Suc n = degree p\<close> have "n = degree k" by simp
    then have "finite {x. poly k x = 0}" using \<open>k \<noteq> 0\<close> by (rule Suc.hyps)
    then have "finite (insert a {x. poly k x = 0})" by simp
    then show "finite {x. poly p x = 0}"
      by (simp add: k Collect_disj_eq del: mult_pCons_left)
  qed
qed

lemma poly_eq_poly_eq_iff:
  fixes p q :: "'a::{idom,ring_char_0} poly"
  shows "poly p = poly q \<longleftrightarrow> p = q" (is "?P \<longleftrightarrow> ?Q")
proof
  assume ?Q then show ?P by simp
next
  { fix p :: "'a::{idom,ring_char_0} poly"
    have "poly p = poly 0 \<longleftrightarrow> p = 0"
      apply (cases "p = 0", simp_all)
      apply (drule poly_roots_finite)
      apply (auto simp add: infinite_UNIV_char_0)
      done
  } note this [of "p - q"]
  moreover assume ?P
  ultimately show ?Q by auto
qed

lemma poly_all_0_iff_0:
  fixes p :: "'a::{ring_char_0, idom} poly"
  shows "(\<forall>x. poly p x = 0) \<longleftrightarrow> p = 0"
  by (auto simp add: poly_eq_poly_eq_iff [symmetric])


subsection \<open>Long division of polynomials\<close>

definition pdivmod_rel :: "'a::field poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly \<Rightarrow> bool"
where
  "pdivmod_rel x y q r \<longleftrightarrow>
    x = q * y + r \<and> (if y = 0 then q = 0 else r = 0 \<or> degree r < degree y)"

lemma pdivmod_rel_0:
  "pdivmod_rel 0 y 0 0"
  unfolding pdivmod_rel_def by simp

lemma pdivmod_rel_by_0:
  "pdivmod_rel x 0 0 x"
  unfolding pdivmod_rel_def by simp

lemma eq_zero_or_degree_less:
  assumes "degree p \<le> n" and "coeff p n = 0"
  shows "p = 0 \<or> degree p < n"
proof (cases n)
  case 0
  with \<open>degree p \<le> n\<close> and \<open>coeff p n = 0\<close>
  have "coeff p (degree p) = 0" by simp
  then have "p = 0" by simp
  then show ?thesis ..
next
  case (Suc m)
  have "\<forall>i>n. coeff p i = 0"
    using \<open>degree p \<le> n\<close> by (simp add: coeff_eq_0)
  then have "\<forall>i\<ge>n. coeff p i = 0"
    using \<open>coeff p n = 0\<close> by (simp add: le_less)
  then have "\<forall>i>m. coeff p i = 0"
    using \<open>n = Suc m\<close> by (simp add: less_eq_Suc_le)
  then have "degree p \<le> m"
    by (rule degree_le)
  then have "degree p < n"
    using \<open>n = Suc m\<close> by (simp add: less_Suc_eq_le)
  then show ?thesis ..
qed

lemma pdivmod_rel_pCons:
  assumes rel: "pdivmod_rel x y q r"
  assumes y: "y \<noteq> 0"
  assumes b: "b = coeff (pCons a r) (degree y) / coeff y (degree y)"
  shows "pdivmod_rel (pCons a x) y (pCons b q) (pCons a r - smult b y)"
    (is "pdivmod_rel ?x y ?q ?r")
proof -
  have x: "x = q * y + r" and r: "r = 0 \<or> degree r < degree y"
    using assms unfolding pdivmod_rel_def by simp_all

  have 1: "?x = ?q * y + ?r"
    using b x by simp

  have 2: "?r = 0 \<or> degree ?r < degree y"
  proof (rule eq_zero_or_degree_less)
    show "degree ?r \<le> degree y"
    proof (rule degree_diff_le)
      show "degree (pCons a r) \<le> degree y"
        using r by auto
      show "degree (smult b y) \<le> degree y"
        by (rule degree_smult_le)
    qed
  next
    show "coeff ?r (degree y) = 0"
      using \<open>y \<noteq> 0\<close> unfolding b by simp
  qed

  from 1 2 show ?thesis
    unfolding pdivmod_rel_def
    using \<open>y \<noteq> 0\<close> by simp
qed

lemma pdivmod_rel_exists: "\<exists>q r. pdivmod_rel x y q r"
apply (cases "y = 0")
apply (fast intro!: pdivmod_rel_by_0)
apply (induct x)
apply (fast intro!: pdivmod_rel_0)
apply (fast intro!: pdivmod_rel_pCons)
done

lemma pdivmod_rel_unique:
  assumes 1: "pdivmod_rel x y q1 r1"
  assumes 2: "pdivmod_rel x y q2 r2"
  shows "q1 = q2 \<and> r1 = r2"
proof (cases "y = 0")
  assume "y = 0" with assms show ?thesis
    by (simp add: pdivmod_rel_def)
next
  assume [simp]: "y \<noteq> 0"
  from 1 have q1: "x = q1 * y + r1" and r1: "r1 = 0 \<or> degree r1 < degree y"
    unfolding pdivmod_rel_def by simp_all
  from 2 have q2: "x = q2 * y + r2" and r2: "r2 = 0 \<or> degree r2 < degree y"
    unfolding pdivmod_rel_def by simp_all
  from q1 q2 have q3: "(q1 - q2) * y = r2 - r1"
    by (simp add: algebra_simps)
  from r1 r2 have r3: "(r2 - r1) = 0 \<or> degree (r2 - r1) < degree y"
    by (auto intro: degree_diff_less)

  show "q1 = q2 \<and> r1 = r2"
  proof (rule ccontr)
    assume "\<not> (q1 = q2 \<and> r1 = r2)"
    with q3 have "q1 \<noteq> q2" and "r1 \<noteq> r2" by auto
    with r3 have "degree (r2 - r1) < degree y" by simp
    also have "degree y \<le> degree (q1 - q2) + degree y" by simp
    also have "\<dots> = degree ((q1 - q2) * y)"
      using \<open>q1 \<noteq> q2\<close> by (simp add: degree_mult_eq)
    also have "\<dots> = degree (r2 - r1)"
      using q3 by simp
    finally have "degree (r2 - r1) < degree (r2 - r1)" .
    then show "False" by simp
  qed
qed

lemma pdivmod_rel_0_iff: "pdivmod_rel 0 y q r \<longleftrightarrow> q = 0 \<and> r = 0"
by (auto dest: pdivmod_rel_unique intro: pdivmod_rel_0)

lemma pdivmod_rel_by_0_iff: "pdivmod_rel x 0 q r \<longleftrightarrow> q = 0 \<and> r = x"
by (auto dest: pdivmod_rel_unique intro: pdivmod_rel_by_0)

lemmas pdivmod_rel_unique_div = pdivmod_rel_unique [THEN conjunct1]

lemmas pdivmod_rel_unique_mod = pdivmod_rel_unique [THEN conjunct2]

instantiation poly :: (field) ring_div
begin

definition divide_poly where
  div_poly_def: "x div y = (THE q. \<exists>r. pdivmod_rel x y q r)"

definition mod_poly where
  "x mod y = (THE r. \<exists>q. pdivmod_rel x y q r)"

lemma div_poly_eq:
  "pdivmod_rel x y q r \<Longrightarrow> x div y = q"
unfolding div_poly_def
by (fast elim: pdivmod_rel_unique_div)

lemma mod_poly_eq:
  "pdivmod_rel x y q r \<Longrightarrow> x mod y = r"
unfolding mod_poly_def
by (fast elim: pdivmod_rel_unique_mod)

lemma pdivmod_rel:
  "pdivmod_rel x y (x div y) (x mod y)"
proof -
  from pdivmod_rel_exists
    obtain q r where "pdivmod_rel x y q r" by fast
  thus ?thesis
    by (simp add: div_poly_eq mod_poly_eq)
qed

instance
proof
  fix x y :: "'a poly"
  show "x div y * y + x mod y = x"
    using pdivmod_rel [of x y]
    by (simp add: pdivmod_rel_def)
next
  fix x :: "'a poly"
  have "pdivmod_rel x 0 0 x"
    by (rule pdivmod_rel_by_0)
  thus "x div 0 = 0"
    by (rule div_poly_eq)
next
  fix y :: "'a poly"
  have "pdivmod_rel 0 y 0 0"
    by (rule pdivmod_rel_0)
  thus "0 div y = 0"
    by (rule div_poly_eq)
next
  fix x y z :: "'a poly"
  assume "y \<noteq> 0"
  hence "pdivmod_rel (x + z * y) y (z + x div y) (x mod y)"
    using pdivmod_rel [of x y]
    by (simp add: pdivmod_rel_def distrib_right)
  thus "(x + z * y) div y = z + x div y"
    by (rule div_poly_eq)
next
  fix x y z :: "'a poly"
  assume "x \<noteq> 0"
  show "(x * y) div (x * z) = y div z"
  proof (cases "y \<noteq> 0 \<and> z \<noteq> 0")
    have "\<And>x::'a poly. pdivmod_rel x 0 0 x"
      by (rule pdivmod_rel_by_0)
    then have [simp]: "\<And>x::'a poly. x div 0 = 0"
      by (rule div_poly_eq)
    have "\<And>x::'a poly. pdivmod_rel 0 x 0 0"
      by (rule pdivmod_rel_0)
    then have [simp]: "\<And>x::'a poly. 0 div x = 0"
      by (rule div_poly_eq)
    case False then show ?thesis by auto
  next
    case True then have "y \<noteq> 0" and "z \<noteq> 0" by auto
    with \<open>x \<noteq> 0\<close>
    have "\<And>q r. pdivmod_rel y z q r \<Longrightarrow> pdivmod_rel (x * y) (x * z) q (x * r)"
      by (auto simp add: pdivmod_rel_def algebra_simps)
        (rule classical, simp add: degree_mult_eq)
    moreover from pdivmod_rel have "pdivmod_rel y z (y div z) (y mod z)" .
    ultimately have "pdivmod_rel (x * y) (x * z) (y div z) (x * (y mod z))" .
    then show ?thesis by (simp add: div_poly_eq)
  qed
qed

end

lemma is_unit_monom_0:
  fixes a :: "'a::field"
  assumes "a \<noteq> 0"
  shows "is_unit (monom a 0)"
proof
  from assms show "1 = monom a 0 * monom (1 / a) 0"
    by (simp add: mult_monom)
qed

lemma is_unit_triv:
  fixes a :: "'a::field"
  assumes "a \<noteq> 0"
  shows "is_unit [:a:]"
  using assms by (simp add: is_unit_monom_0 monom_0 [symmetric])

lemma is_unit_iff_degree:
  assumes "p \<noteq> 0"
  shows "is_unit p \<longleftrightarrow> degree p = 0" (is "?P \<longleftrightarrow> ?Q")
proof
  assume ?Q
  then obtain a where "p = [:a:]" by (rule degree_eq_zeroE)
  with assms show ?P by (simp add: is_unit_triv)
next
  assume ?P
  then obtain q where "q \<noteq> 0" "p * q = 1" ..
  then have "degree (p * q) = degree 1"
    by simp
  with \<open>p \<noteq> 0\<close> \<open>q \<noteq> 0\<close> have "degree p + degree q = 0"
    by (simp add: degree_mult_eq)
  then show ?Q by simp
qed

lemma is_unit_pCons_iff:
  "is_unit (pCons a p) \<longleftrightarrow> p = 0 \<and> a \<noteq> 0" (is "?P \<longleftrightarrow> ?Q")
  by (cases "p = 0") (auto simp add: is_unit_triv is_unit_iff_degree)

lemma is_unit_monom_trival:
  fixes p :: "'a::field poly"
  assumes "is_unit p"
  shows "monom (coeff p (degree p)) 0 = p"
  using assms by (cases p) (simp_all add: monom_0 is_unit_pCons_iff)

lemma is_unit_polyE:
  assumes "is_unit p"
  obtains a where "p = monom a 0" and "a \<noteq> 0"
proof -
  obtain a q where "p = pCons a q" by (cases p)
  with assms have "p = [:a:]" and "a \<noteq> 0"
    by (simp_all add: is_unit_pCons_iff)
  with that show thesis by (simp add: monom_0)
qed

instantiation poly :: (field) normalization_semidom
begin

definition normalize_poly :: "'a poly \<Rightarrow> 'a poly"
  where "normalize_poly p = smult (1 / coeff p (degree p)) p"

definition unit_factor_poly :: "'a poly \<Rightarrow> 'a poly"
  where "unit_factor_poly p = monom (coeff p (degree p)) 0"

instance
proof
  fix p :: "'a poly"
  show "unit_factor p * normalize p = p"
    by (simp add: normalize_poly_def unit_factor_poly_def)
      (simp only: mult_smult_left [symmetric] smult_monom, simp)
next
  show "normalize 0 = (0::'a poly)"
    by (simp add: normalize_poly_def)
next
  show "unit_factor 0 = (0::'a poly)"
    by (simp add: unit_factor_poly_def)
next
  fix p :: "'a poly"
  assume "is_unit p"
  then obtain a where "p = monom a 0" and "a \<noteq> 0"
    by (rule is_unit_polyE)
  then show "normalize p = 1"
    by (auto simp add: normalize_poly_def smult_monom degree_monom_eq)
next
  fix p q :: "'a poly"
  assume "q \<noteq> 0"
  from \<open>q \<noteq> 0\<close> have "is_unit (monom (coeff q (degree q)) 0)"
    by (auto intro: is_unit_monom_0)
  then show "is_unit (unit_factor q)"
    by (simp add: unit_factor_poly_def)
next
  fix p q :: "'a poly"
  have "monom (coeff (p * q) (degree (p * q))) 0 =
    monom (coeff p (degree p)) 0 * monom (coeff q (degree q)) 0"
    by (simp add: monom_0 coeff_degree_mult)
  then show "unit_factor (p * q) =
    unit_factor p * unit_factor q"
    by (simp add: unit_factor_poly_def)
qed

end

lemma degree_mod_less:
  "y \<noteq> 0 \<Longrightarrow> x mod y = 0 \<or> degree (x mod y) < degree y"
  using pdivmod_rel [of x y]
  unfolding pdivmod_rel_def by simp

lemma div_poly_less: "degree x < degree y \<Longrightarrow> x div y = 0"
proof -
  assume "degree x < degree y"
  hence "pdivmod_rel x y 0 x"
    by (simp add: pdivmod_rel_def)
  thus "x div y = 0" by (rule div_poly_eq)
qed

lemma mod_poly_less: "degree x < degree y \<Longrightarrow> x mod y = x"
proof -
  assume "degree x < degree y"
  hence "pdivmod_rel x y 0 x"
    by (simp add: pdivmod_rel_def)
  thus "x mod y = x" by (rule mod_poly_eq)
qed

lemma pdivmod_rel_smult_left:
  "pdivmod_rel x y q r
    \<Longrightarrow> pdivmod_rel (smult a x) y (smult a q) (smult a r)"
  unfolding pdivmod_rel_def by (simp add: smult_add_right)

lemma div_smult_left: "(smult a x) div y = smult a (x div y)"
  by (rule div_poly_eq, rule pdivmod_rel_smult_left, rule pdivmod_rel)

lemma mod_smult_left: "(smult a x) mod y = smult a (x mod y)"
  by (rule mod_poly_eq, rule pdivmod_rel_smult_left, rule pdivmod_rel)

lemma poly_div_minus_left [simp]:
  fixes x y :: "'a::field poly"
  shows "(- x) div y = - (x div y)"
  using div_smult_left [of "- 1::'a"] by simp

lemma poly_mod_minus_left [simp]:
  fixes x y :: "'a::field poly"
  shows "(- x) mod y = - (x mod y)"
  using mod_smult_left [of "- 1::'a"] by simp

lemma pdivmod_rel_add_left:
  assumes "pdivmod_rel x y q r"
  assumes "pdivmod_rel x' y q' r'"
  shows "pdivmod_rel (x + x') y (q + q') (r + r')"
  using assms unfolding pdivmod_rel_def
  by (auto simp add: algebra_simps degree_add_less)

lemma poly_div_add_left:
  fixes x y z :: "'a::field poly"
  shows "(x + y) div z = x div z + y div z"
  using pdivmod_rel_add_left [OF pdivmod_rel pdivmod_rel]
  by (rule div_poly_eq)

lemma poly_mod_add_left:
  fixes x y z :: "'a::field poly"
  shows "(x + y) mod z = x mod z + y mod z"
  using pdivmod_rel_add_left [OF pdivmod_rel pdivmod_rel]
  by (rule mod_poly_eq)

lemma poly_div_diff_left:
  fixes x y z :: "'a::field poly"
  shows "(x - y) div z = x div z - y div z"
  by (simp only: diff_conv_add_uminus poly_div_add_left poly_div_minus_left)

lemma poly_mod_diff_left:
  fixes x y z :: "'a::field poly"
  shows "(x - y) mod z = x mod z - y mod z"
  by (simp only: diff_conv_add_uminus poly_mod_add_left poly_mod_minus_left)

lemma pdivmod_rel_smult_right:
  "\<lbrakk>a \<noteq> 0; pdivmod_rel x y q r\<rbrakk>
    \<Longrightarrow> pdivmod_rel x (smult a y) (smult (inverse a) q) r"
  unfolding pdivmod_rel_def by simp

lemma div_smult_right:
  "a \<noteq> 0 \<Longrightarrow> x div (smult a y) = smult (inverse a) (x div y)"
  by (rule div_poly_eq, erule pdivmod_rel_smult_right, rule pdivmod_rel)

lemma mod_smult_right: "a \<noteq> 0 \<Longrightarrow> x mod (smult a y) = x mod y"
  by (rule mod_poly_eq, erule pdivmod_rel_smult_right, rule pdivmod_rel)

lemma poly_div_minus_right [simp]:
  fixes x y :: "'a::field poly"
  shows "x div (- y) = - (x div y)"
  using div_smult_right [of "- 1::'a"] by (simp add: nonzero_inverse_minus_eq)

lemma poly_mod_minus_right [simp]:
  fixes x y :: "'a::field poly"
  shows "x mod (- y) = x mod y"
  using mod_smult_right [of "- 1::'a"] by simp

lemma pdivmod_rel_mult:
  "\<lbrakk>pdivmod_rel x y q r; pdivmod_rel q z q' r'\<rbrakk>
    \<Longrightarrow> pdivmod_rel x (y * z) q' (y * r' + r)"
apply (cases "z = 0", simp add: pdivmod_rel_def)
apply (cases "y = 0", simp add: pdivmod_rel_by_0_iff pdivmod_rel_0_iff)
apply (cases "r = 0")
apply (cases "r' = 0")
apply (simp add: pdivmod_rel_def)
apply (simp add: pdivmod_rel_def field_simps degree_mult_eq)
apply (cases "r' = 0")
apply (simp add: pdivmod_rel_def degree_mult_eq)
apply (simp add: pdivmod_rel_def field_simps)
apply (simp add: degree_mult_eq degree_add_less)
done

lemma poly_div_mult_right:
  fixes x y z :: "'a::field poly"
  shows "x div (y * z) = (x div y) div z"
  by (rule div_poly_eq, rule pdivmod_rel_mult, (rule pdivmod_rel)+)

lemma poly_mod_mult_right:
  fixes x y z :: "'a::field poly"
  shows "x mod (y * z) = y * (x div y mod z) + x mod y"
  by (rule mod_poly_eq, rule pdivmod_rel_mult, (rule pdivmod_rel)+)

lemma mod_pCons:
  fixes a and x
  assumes y: "y \<noteq> 0"
  defines b: "b \<equiv> coeff (pCons a (x mod y)) (degree y) / coeff y (degree y)"
  shows "(pCons a x) mod y = (pCons a (x mod y) - smult b y)"
unfolding b
apply (rule mod_poly_eq)
apply (rule pdivmod_rel_pCons [OF pdivmod_rel y refl])
done

definition pdivmod :: "'a::field poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly \<times> 'a poly"
where
  "pdivmod p q = (p div q, p mod q)"

lemma div_poly_code [code]: 
  "p div q = fst (pdivmod p q)"
  by (simp add: pdivmod_def)

lemma mod_poly_code [code]:
  "p mod q = snd (pdivmod p q)"
  by (simp add: pdivmod_def)

lemma pdivmod_0:
  "pdivmod 0 q = (0, 0)"
  by (simp add: pdivmod_def)

lemma pdivmod_pCons:
  "pdivmod (pCons a p) q =
    (if q = 0 then (0, pCons a p) else
      (let (s, r) = pdivmod p q;
           b = coeff (pCons a r) (degree q) / coeff q (degree q)
        in (pCons b s, pCons a r - smult b q)))"
  apply (simp add: pdivmod_def Let_def, safe)
  apply (rule div_poly_eq)
  apply (erule pdivmod_rel_pCons [OF pdivmod_rel _ refl])
  apply (rule mod_poly_eq)
  apply (erule pdivmod_rel_pCons [OF pdivmod_rel _ refl])
  done

lemma pdivmod_fold_coeffs [code]:
  "pdivmod p q = (if q = 0 then (0, p)
    else fold_coeffs (\<lambda>a (s, r).
      let b = coeff (pCons a r) (degree q) / coeff q (degree q)
      in (pCons b s, pCons a r - smult b q)
   ) p (0, 0))"
  apply (cases "q = 0")
  apply (simp add: pdivmod_def)
  apply (rule sym)
  apply (induct p)
  apply (simp_all add: pdivmod_0 pdivmod_pCons)
  apply (case_tac "a = 0 \<and> p = 0")
  apply (auto simp add: pdivmod_def)
  done


subsection \<open>Order of polynomial roots\<close>

definition order :: "'a::idom \<Rightarrow> 'a poly \<Rightarrow> nat"
where
  "order a p = (LEAST n. \<not> [:-a, 1:] ^ Suc n dvd p)"

lemma coeff_linear_power:
  fixes a :: "'a::comm_semiring_1"
  shows "coeff ([:a, 1:] ^ n) n = 1"
apply (induct n, simp_all)
apply (subst coeff_eq_0)
apply (auto intro: le_less_trans degree_power_le)
done

lemma degree_linear_power:
  fixes a :: "'a::comm_semiring_1"
  shows "degree ([:a, 1:] ^ n) = n"
apply (rule order_antisym)
apply (rule ord_le_eq_trans [OF degree_power_le], simp)
apply (rule le_degree, simp add: coeff_linear_power)
done

lemma order_1: "[:-a, 1:] ^ order a p dvd p"
apply (cases "p = 0", simp)
apply (cases "order a p", simp)
apply (subgoal_tac "nat < (LEAST n. \<not> [:-a, 1:] ^ Suc n dvd p)")
apply (drule not_less_Least, simp)
apply (fold order_def, simp)
done

lemma order_2: "p \<noteq> 0 \<Longrightarrow> \<not> [:-a, 1:] ^ Suc (order a p) dvd p"
unfolding order_def
apply (rule LeastI_ex)
apply (rule_tac x="degree p" in exI)
apply (rule notI)
apply (drule (1) dvd_imp_degree_le)
apply (simp only: degree_linear_power)
done

lemma order:
  "p \<noteq> 0 \<Longrightarrow> [:-a, 1:] ^ order a p dvd p \<and> \<not> [:-a, 1:] ^ Suc (order a p) dvd p"
by (rule conjI [OF order_1 order_2])

lemma order_degree:
  assumes p: "p \<noteq> 0"
  shows "order a p \<le> degree p"
proof -
  have "order a p = degree ([:-a, 1:] ^ order a p)"
    by (simp only: degree_linear_power)
  also have "\<dots> \<le> degree p"
    using order_1 p by (rule dvd_imp_degree_le)
  finally show ?thesis .
qed

lemma order_root: "poly p a = 0 \<longleftrightarrow> p = 0 \<or> order a p \<noteq> 0"
apply (cases "p = 0", simp_all)
apply (rule iffI)
apply (metis order_2 not_gr0 poly_eq_0_iff_dvd power_0 power_Suc_0 power_one_right)
unfolding poly_eq_0_iff_dvd
apply (metis dvd_power dvd_trans order_1)
done

lemma order_0I: "poly p a \<noteq> 0 \<Longrightarrow> order a p = 0"
  by (subst (asm) order_root) auto


subsection \<open>GCD of polynomials\<close>

instantiation poly :: (field) gcd
begin

function gcd_poly :: "'a::field poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
where
  "gcd (x::'a poly) 0 = smult (inverse (coeff x (degree x))) x"
| "y \<noteq> 0 \<Longrightarrow> gcd (x::'a poly) y = gcd y (x mod y)"
by auto

termination "gcd :: _ poly \<Rightarrow> _"
by (relation "measure (\<lambda>(x, y). if y = 0 then 0 else Suc (degree y))")
   (auto dest: degree_mod_less)

declare gcd_poly.simps [simp del]

definition lcm_poly :: "'a::field poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
where
  "lcm_poly a b = a * b div smult (coeff a (degree a) * coeff b (degree b)) (gcd a b)"

instance ..

end

lemma
  fixes x y :: "_ poly"
  shows poly_gcd_dvd1 [iff]: "gcd x y dvd x"
    and poly_gcd_dvd2 [iff]: "gcd x y dvd y"
  apply (induct x y rule: gcd_poly.induct)
  apply (simp_all add: gcd_poly.simps)
  apply (fastforce simp add: smult_dvd_iff dest: inverse_zero_imp_zero)
  apply (blast dest: dvd_mod_imp_dvd)
  done

lemma poly_gcd_greatest:
  fixes k x y :: "_ poly"
  shows "k dvd x \<Longrightarrow> k dvd y \<Longrightarrow> k dvd gcd x y"
  by (induct x y rule: gcd_poly.induct)
     (simp_all add: gcd_poly.simps dvd_mod dvd_smult)

lemma dvd_poly_gcd_iff [iff]:
  fixes k x y :: "_ poly"
  shows "k dvd gcd x y \<longleftrightarrow> k dvd x \<and> k dvd y"
  by (auto intro!: poly_gcd_greatest intro: dvd_trans [of _ "gcd x y"])

lemma poly_gcd_monic:
  fixes x y :: "_ poly"
  shows "coeff (gcd x y) (degree (gcd x y)) =
    (if x = 0 \<and> y = 0 then 0 else 1)"
  by (induct x y rule: gcd_poly.induct)
     (simp_all add: gcd_poly.simps nonzero_imp_inverse_nonzero)

lemma poly_gcd_zero_iff [simp]:
  fixes x y :: "_ poly"
  shows "gcd x y = 0 \<longleftrightarrow> x = 0 \<and> y = 0"
  by (simp only: dvd_0_left_iff [symmetric] dvd_poly_gcd_iff)

lemma poly_gcd_0_0 [simp]:
  "gcd (0::_ poly) 0 = 0"
  by simp

lemma poly_dvd_antisym:
  fixes p q :: "'a::idom poly"
  assumes coeff: "coeff p (degree p) = coeff q (degree q)"
  assumes dvd1: "p dvd q" and dvd2: "q dvd p" shows "p = q"
proof (cases "p = 0")
  case True with coeff show "p = q" by simp
next
  case False with coeff have "q \<noteq> 0" by auto
  have degree: "degree p = degree q"
    using \<open>p dvd q\<close> \<open>q dvd p\<close> \<open>p \<noteq> 0\<close> \<open>q \<noteq> 0\<close>
    by (intro order_antisym dvd_imp_degree_le)

  from \<open>p dvd q\<close> obtain a where a: "q = p * a" ..
  with \<open>q \<noteq> 0\<close> have "a \<noteq> 0" by auto
  with degree a \<open>p \<noteq> 0\<close> have "degree a = 0"
    by (simp add: degree_mult_eq)
  with coeff a show "p = q"
    by (cases a, auto split: if_splits)
qed

lemma poly_gcd_unique:
  fixes d x y :: "_ poly"
  assumes dvd1: "d dvd x" and dvd2: "d dvd y"
    and greatest: "\<And>k. k dvd x \<Longrightarrow> k dvd y \<Longrightarrow> k dvd d"
    and monic: "coeff d (degree d) = (if x = 0 \<and> y = 0 then 0 else 1)"
  shows "gcd x y = d"
proof -
  have "coeff (gcd x y) (degree (gcd x y)) = coeff d (degree d)"
    by (simp_all add: poly_gcd_monic monic)
  moreover have "gcd x y dvd d"
    using poly_gcd_dvd1 poly_gcd_dvd2 by (rule greatest)
  moreover have "d dvd gcd x y"
    using dvd1 dvd2 by (rule poly_gcd_greatest)
  ultimately show ?thesis
    by (rule poly_dvd_antisym)
qed

interpretation gcd_poly: abel_semigroup "gcd :: _ poly \<Rightarrow> _"
proof
  fix x y z :: "'a poly"
  show "gcd (gcd x y) z = gcd x (gcd y z)"
    by (rule poly_gcd_unique) (auto intro: dvd_trans simp add: poly_gcd_monic)
  show "gcd x y = gcd y x"
    by (rule poly_gcd_unique) (simp_all add: poly_gcd_monic)
qed

lemmas poly_gcd_assoc = gcd_poly.assoc
lemmas poly_gcd_commute = gcd_poly.commute
lemmas poly_gcd_left_commute = gcd_poly.left_commute

lemmas poly_gcd_ac = poly_gcd_assoc poly_gcd_commute poly_gcd_left_commute

lemma poly_gcd_1_left [simp]: "gcd 1 y = (1 :: _ poly)"
by (rule poly_gcd_unique) simp_all

lemma poly_gcd_1_right [simp]: "gcd x 1 = (1 :: _ poly)"
by (rule poly_gcd_unique) simp_all

lemma poly_gcd_minus_left [simp]: "gcd (- x) y = gcd x (y :: _ poly)"
by (rule poly_gcd_unique) (simp_all add: poly_gcd_monic)

lemma poly_gcd_minus_right [simp]: "gcd x (- y) = gcd x (y :: _ poly)"
by (rule poly_gcd_unique) (simp_all add: poly_gcd_monic)

lemma poly_gcd_code [code]:
  "gcd x y = (if y = 0 then smult (inverse (coeff x (degree x))) x else gcd y (x mod (y :: _ poly)))"
  by (simp add: gcd_poly.simps)


subsection \<open>Additional induction rules on polynomials\<close>

text \<open>
  An induction rule for induction over the roots of a polynomial with a certain property. 
  (e.g. all positive roots)
\<close>
lemma poly_root_induct [case_names 0 no_roots root]:
  fixes p :: "'a :: idom poly"
  assumes "Q 0"
  assumes "\<And>p. (\<And>a. P a \<Longrightarrow> poly p a \<noteq> 0) \<Longrightarrow> Q p"
  assumes "\<And>a p. P a \<Longrightarrow> Q p \<Longrightarrow> Q ([:a, -1:] * p)"
  shows   "Q p"
proof (induction "degree p" arbitrary: p rule: less_induct)
  case (less p)
  show ?case
  proof (cases "p = 0")
    assume nz: "p \<noteq> 0"
    show ?case
    proof (cases "\<exists>a. P a \<and> poly p a = 0")
      case False
      thus ?thesis by (intro assms(2)) blast
    next
      case True
      then obtain a where a: "P a" "poly p a = 0" 
        by blast
      hence "-[:-a, 1:] dvd p" 
        by (subst minus_dvd_iff) (simp add: poly_eq_0_iff_dvd)
      then obtain q where q: "p = [:a, -1:] * q" by (elim dvdE) simp
      with nz have q_nz: "q \<noteq> 0" by auto
      have "degree p = Suc (degree q)"
        by (subst q, subst degree_mult_eq) (simp_all add: q_nz)
      hence "Q q" by (intro less) simp
      from a(1) and this have "Q ([:a, -1:] * q)" 
        by (rule assms(3))
      with q show ?thesis by simp
    qed
  qed (simp add: assms(1))
qed

lemma dropWhile_replicate_append: 
  "dropWhile (op= a) (replicate n a @ ys) = dropWhile (op= a) ys"
  by (induction n) simp_all

lemma Poly_append_replicate_0: "Poly (xs @ replicate n 0) = Poly xs"
  by (subst coeffs_eq_iff) (simp_all add: strip_while_def dropWhile_replicate_append)

text \<open>
  An induction rule for simultaneous induction over two polynomials, 
  prepending one coefficient in each step.
\<close>
lemma poly_induct2 [case_names 0 pCons]:
  assumes "P 0 0" "\<And>a p b q. P p q \<Longrightarrow> P (pCons a p) (pCons b q)"
  shows   "P p q"
proof -
  def n \<equiv> "max (length (coeffs p)) (length (coeffs q))"
  def xs \<equiv> "coeffs p @ (replicate (n - length (coeffs p)) 0)"
  def ys \<equiv> "coeffs q @ (replicate (n - length (coeffs q)) 0)"
  have "length xs = length ys" 
    by (simp add: xs_def ys_def n_def)
  hence "P (Poly xs) (Poly ys)" 
    by (induction rule: list_induct2) (simp_all add: assms)
  also have "Poly xs = p" 
    by (simp add: xs_def Poly_append_replicate_0)
  also have "Poly ys = q" 
    by (simp add: ys_def Poly_append_replicate_0)
  finally show ?thesis .
qed


subsection \<open>Composition of polynomials\<close>

definition pcompose :: "'a::comm_semiring_0 poly \<Rightarrow> 'a poly \<Rightarrow> 'a poly"
where
  "pcompose p q = fold_coeffs (\<lambda>a c. [:a:] + q * c) p 0"

lemma pcompose_0 [simp]:
  "pcompose 0 q = 0"
  by (simp add: pcompose_def)

lemma pcompose_pCons:
  "pcompose (pCons a p) q = [:a:] + q * pcompose p q"
  by (cases "p = 0 \<and> a = 0") (auto simp add: pcompose_def)

lemma poly_pcompose:
  "poly (pcompose p q) x = poly p (poly q x)"
  by (induct p) (simp_all add: pcompose_pCons)

lemma degree_pcompose_le:
  "degree (pcompose p q) \<le> degree p * degree q"
apply (induct p, simp)
apply (simp add: pcompose_pCons, clarify)
apply (rule degree_add_le, simp)
apply (rule order_trans [OF degree_mult_le], simp)
done

lemma pcompose_add:
  fixes p q r :: "'a :: {comm_semiring_0, ab_semigroup_add} poly"
  shows "pcompose (p + q) r = pcompose p r + pcompose q r"
proof (induction p q rule: poly_induct2)
  case (pCons a p b q)
  have "pcompose (pCons a p + pCons b q) r = 
          [:a + b:] + r * pcompose p r + r * pcompose q r"
    by (simp_all add: pcompose_pCons pCons.IH algebra_simps)
  also have "[:a + b:] = [:a:] + [:b:]" by simp
  also have "\<dots> + r * pcompose p r + r * pcompose q r = 
                 pcompose (pCons a p) r + pcompose (pCons b q) r"
    by (simp only: pcompose_pCons add_ac)
  finally show ?case .
qed simp

lemma pcompose_minus:
  fixes p r :: "'a :: comm_ring poly"
  shows "pcompose (-p) r = -pcompose p r"
  by (induction p) (simp_all add: pcompose_pCons)

lemma pcompose_diff:
  fixes p q r :: "'a :: comm_ring poly"
  shows "pcompose (p - q) r = pcompose p r - pcompose q r"
  using pcompose_add[of p "-q"] by (simp add: pcompose_minus)

lemma pcompose_smult:
  fixes p r :: "'a :: comm_semiring_0 poly"
  shows "pcompose (smult a p) r = smult a (pcompose p r)"
  by (induction p) 
     (simp_all add: pcompose_pCons pcompose_add smult_add_right)

lemma pcompose_mult:
  fixes p q r :: "'a :: comm_semiring_0 poly"
  shows "pcompose (p * q) r = pcompose p r * pcompose q r"
  by (induction p arbitrary: q)
     (simp_all add: pcompose_add pcompose_smult pcompose_pCons algebra_simps)

lemma pcompose_assoc: 
  "pcompose p (pcompose q r :: 'a :: comm_semiring_0 poly ) =
     pcompose (pcompose p q) r"
  by (induction p arbitrary: q) 
     (simp_all add: pcompose_pCons pcompose_add pcompose_mult)


(* The remainder of this section and the next were contributed by Wenda Li *)

lemma degree_mult_eq_0:
  fixes p q:: "'a :: idom poly"
  shows "degree (p*q) = 0 \<longleftrightarrow> p=0 \<or> q=0 \<or> (p\<noteq>0 \<and> q\<noteq>0 \<and> degree p =0 \<and> degree q =0)"
by (auto simp add:degree_mult_eq)

lemma pcompose_const[simp]:"pcompose [:a:] q = [:a:]" by (subst pcompose_pCons,simp) 

lemma pcompose_0':"pcompose p 0=[:coeff p 0:]"
  apply (induct p)
  apply (auto simp add:pcompose_pCons)
done

lemma degree_pcompose:
  fixes p q:: "'a::idom poly"
  shows "degree(pcompose p q) = degree p * degree q"
proof (induct p)
  case 0
  thus ?case by auto
next
  case (pCons a p)
  have "degree (q * pcompose p q) = 0 \<Longrightarrow> ?case" 
    proof (cases "p=0")
      case True
      thus ?thesis by auto
    next
      case False assume "degree (q * pcompose p q) = 0"
      hence "degree q=0 \<or> pcompose p q=0" by (auto simp add:degree_mult_eq_0)
      moreover have "\<lbrakk>pcompose p q=0;degree q\<noteq>0\<rbrakk> \<Longrightarrow> False" using pCons.hyps(2) `p\<noteq>0` 
        proof -
          assume "pcompose p q=0" "degree q\<noteq>0"
          hence "degree p=0" using pCons.hyps(2) by auto
          then obtain a1 where "p=[:a1:]"
            by (metis degree_pCons_eq_if old.nat.distinct(2) pCons_cases)
          thus False using `pcompose p q=0` `p\<noteq>0` by auto
        qed
      ultimately have "degree (pCons a p) * degree q=0" by auto
      moreover have "degree (pcompose (pCons a p) q) = 0" 
        proof -
          have" 0 = max (degree [:a:]) (degree (q*pcompose p q))"
            using `degree (q * pcompose p q) = 0` by simp
          also have "... \<ge> degree ([:a:] + q * pcompose p q)"
            by (rule degree_add_le_max)
          finally show ?thesis by (auto simp add:pcompose_pCons)
        qed
      ultimately show ?thesis by simp
    qed
  moreover have "degree (q * pcompose p q)>0 \<Longrightarrow> ?case" 
    proof -
      assume asm:"0 < degree (q * pcompose p q)"
      hence "p\<noteq>0" "q\<noteq>0" "pcompose p q\<noteq>0" by auto
      have "degree (pcompose (pCons a p) q) = degree ( q * pcompose p q)"
        unfolding pcompose_pCons
        using degree_add_eq_right[of "[:a:]" ] asm by auto       
      thus ?thesis 
        using pCons.hyps(2) degree_mult_eq[OF `q\<noteq>0` `pcompose p q\<noteq>0`] by auto
    qed
  ultimately show ?case by blast
qed

lemma pcompose_eq_0:
  fixes p q:: "'a::idom poly"
  assumes "pcompose p q=0" "degree q>0" 
  shows "p=0"
proof -
  have "degree p=0" using assms degree_pcompose[of p q] by auto
  then obtain a where "p=[:a:]" 
    by (metis degree_pCons_eq_if gr0_conv_Suc neq0_conv pCons_cases)
  hence "a=0" using assms(1) by auto
  thus ?thesis using `p=[:a:]` by simp
qed


section{*lead coefficient*}

definition lead_coeff:: "'a::zero poly \<Rightarrow> 'a" where
  "lead_coeff p= coeff p (degree p)"

lemma lead_coeff_pCons[simp]:
    "p\<noteq>0 \<Longrightarrow>lead_coeff (pCons a p) = lead_coeff p"
    "p=0 \<Longrightarrow> lead_coeff (pCons a p) = a"
unfolding lead_coeff_def by auto

lemma lead_coeff_0[simp]:"lead_coeff 0 =0" 
  unfolding lead_coeff_def by auto

lemma lead_coeff_mult:
   fixes p q::"'a ::idom poly"
   shows "lead_coeff (p * q) = lead_coeff p * lead_coeff q"
by (unfold lead_coeff_def,cases "p=0 \<or> q=0",auto simp add:coeff_mult_degree_sum degree_mult_eq)

lemma lead_coeff_add_le:
  assumes "degree p < degree q"
  shows "lead_coeff (p+q) = lead_coeff q" 
using assms unfolding lead_coeff_def
by (metis coeff_add coeff_eq_0 monoid_add_class.add.left_neutral degree_add_eq_right)

lemma lead_coeff_minus:
  "lead_coeff (-p) = - lead_coeff p"
by (metis coeff_minus degree_minus lead_coeff_def)


lemma lead_coeff_comp:
  fixes p q:: "'a::idom poly"
  assumes "degree q > 0" 
  shows "lead_coeff (pcompose p q) = lead_coeff p * lead_coeff q ^ (degree p)"
proof (induct p)
  case 0
  thus ?case unfolding lead_coeff_def by auto
next
  case (pCons a p)
  have "degree ( q * pcompose p q) = 0 \<Longrightarrow> ?case"
    proof -
      assume "degree ( q * pcompose p q) = 0"
      hence "pcompose p q = 0" by (metis assms degree_0 degree_mult_eq_0 neq0_conv)
      hence "p=0" using pcompose_eq_0[OF _ `degree q > 0`] by simp
      thus ?thesis by auto
    qed
  moreover have "degree ( q * pcompose p q) > 0 \<Longrightarrow> ?case" 
    proof -
      assume "degree ( q * pcompose p q) > 0"
      hence "lead_coeff (pcompose (pCons a p) q) =lead_coeff ( q * pcompose p q)"
        by (auto simp add:pcompose_pCons lead_coeff_add_le)
      also have "... = lead_coeff q * (lead_coeff p * lead_coeff q ^ degree p)"
        using pCons.hyps(2) lead_coeff_mult[of q "pcompose p q"] by simp
      also have "... = lead_coeff p * lead_coeff q ^ (degree p + 1)"
        by auto
      finally show ?thesis by auto
    qed
  ultimately show ?case by blast
qed

lemma lead_coeff_smult: 
  "lead_coeff (smult c p :: 'a :: idom poly) = c * lead_coeff p"
proof -
  have "smult c p = [:c:] * p" by simp
  also have "lead_coeff \<dots> = c * lead_coeff p" 
    by (subst lead_coeff_mult) simp_all
  finally show ?thesis .
qed

lemma lead_coeff_1 [simp]: "lead_coeff 1 = 1"
  by (simp add: lead_coeff_def)

lemma lead_coeff_of_nat [simp]:
  "lead_coeff (of_nat n) = (of_nat n :: 'a :: {comm_semiring_1,semiring_char_0})"
  by (induction n) (simp_all add: lead_coeff_def of_nat_poly)

lemma lead_coeff_numeral [simp]: 
  "lead_coeff (numeral n) = numeral n"
  unfolding lead_coeff_def
  by (subst of_nat_numeral [symmetric], subst of_nat_poly) simp

lemma lead_coeff_power: 
  "lead_coeff (p ^ n :: 'a :: idom poly) = lead_coeff p ^ n"
  by (induction n) (simp_all add: lead_coeff_mult)

lemma lead_coeff_nonzero: "p \<noteq> 0 \<Longrightarrow> lead_coeff p \<noteq> 0"
  by (simp add: lead_coeff_def)
  
  

no_notation cCons (infixr "##" 65)

end
