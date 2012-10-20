(* Author: Florian Haftmann, TU Muenchen *)

header {* Finite types as explicit enumerations *}

theory Enum
imports Map String
begin

subsection {* Class @{text enum} *}

class enum =
  fixes enum :: "'a list"
  fixes enum_all :: "('a \<Rightarrow> bool) \<Rightarrow> bool"
  fixes enum_ex  :: "('a \<Rightarrow> bool) \<Rightarrow> bool"
  assumes UNIV_enum: "UNIV = set enum"
    and enum_distinct: "distinct enum"
  assumes enum_all : "enum_all P = (\<forall> x. P x)"
  assumes enum_ex  : "enum_ex P = (\<exists> x. P x)" 
begin

subclass finite proof
qed (simp add: UNIV_enum)

lemma enum_UNIV: "set enum = UNIV" unfolding UNIV_enum ..

lemma in_enum: "x \<in> set enum"
  unfolding enum_UNIV by auto

lemma enum_eq_I:
  assumes "\<And>x. x \<in> set xs"
  shows "set enum = set xs"
proof -
  from assms UNIV_eq_I have "UNIV = set xs" by auto
  with enum_UNIV show ?thesis by simp
qed

end


subsection {* Equality and order on functions *}

instantiation "fun" :: (enum, equal) equal
begin

definition
  "HOL.equal f g \<longleftrightarrow> (\<forall>x \<in> set enum. f x = g x)"

instance proof
qed (simp_all add: equal_fun_def enum_UNIV fun_eq_iff)

end

lemma [code]:
  "HOL.equal f g \<longleftrightarrow> enum_all (%x. f x = g x)"
by (auto simp add: equal enum_all fun_eq_iff)

lemma [code nbe]:
  "HOL.equal (f :: _ \<Rightarrow> _) f \<longleftrightarrow> True"
  by (fact equal_refl)

lemma order_fun [code]:
  fixes f g :: "'a\<Colon>enum \<Rightarrow> 'b\<Colon>order"
  shows "f \<le> g \<longleftrightarrow> enum_all (\<lambda>x. f x \<le> g x)"
    and "f < g \<longleftrightarrow> f \<le> g \<and> enum_ex (\<lambda>x. f x \<noteq> g x)"
  by (simp_all add: enum_all enum_ex fun_eq_iff le_fun_def order_less_le)


subsection {* Quantifiers *}

lemma all_code [code]: "(\<forall>x. P x) \<longleftrightarrow> enum_all P"
  by (simp add: enum_all)

lemma exists_code [code]: "(\<exists>x. P x) \<longleftrightarrow> enum_ex P"
  by (simp add: enum_ex)

lemma exists1_code[code]: "(\<exists>!x. P x) \<longleftrightarrow> list_ex1 P enum"
  by (auto simp add: enum_UNIV list_ex1_iff)


subsection {* Default instances *}

lemma map_of_zip_enum_is_Some:
  assumes "length ys = length (enum \<Colon> 'a\<Colon>enum list)"
  shows "\<exists>y. map_of (zip (enum \<Colon> 'a\<Colon>enum list) ys) x = Some y"
proof -
  from assms have "x \<in> set (enum \<Colon> 'a\<Colon>enum list) \<longleftrightarrow>
    (\<exists>y. map_of (zip (enum \<Colon> 'a\<Colon>enum list) ys) x = Some y)"
    by (auto intro!: map_of_zip_is_Some)
  then show ?thesis using enum_UNIV by auto
qed

lemma map_of_zip_enum_inject:
  fixes xs ys :: "'b\<Colon>enum list"
  assumes length: "length xs = length (enum \<Colon> 'a\<Colon>enum list)"
      "length ys = length (enum \<Colon> 'a\<Colon>enum list)"
    and map_of: "the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) xs) = the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) ys)"
  shows "xs = ys"
proof -
  have "map_of (zip (enum \<Colon> 'a list) xs) = map_of (zip (enum \<Colon> 'a list) ys)"
  proof
    fix x :: 'a
    from length map_of_zip_enum_is_Some obtain y1 y2
      where "map_of (zip (enum \<Colon> 'a list) xs) x = Some y1"
        and "map_of (zip (enum \<Colon> 'a list) ys) x = Some y2" by blast
    moreover from map_of
      have "the (map_of (zip (enum \<Colon> 'a\<Colon>enum list) xs) x) = the (map_of (zip (enum \<Colon> 'a\<Colon>enum list) ys) x)"
      by (auto dest: fun_cong)
    ultimately show "map_of (zip (enum \<Colon> 'a\<Colon>enum list) xs) x = map_of (zip (enum \<Colon> 'a\<Colon>enum list) ys) x"
      by simp
  qed
  with length enum_distinct show "xs = ys" by (rule map_of_zip_inject)
qed

definition
  all_n_lists :: "(('a :: enum) list \<Rightarrow> bool) \<Rightarrow> nat \<Rightarrow> bool"
where
  "all_n_lists P n = (\<forall>xs \<in> set (List.n_lists n enum). P xs)"

lemma [code]:
  "all_n_lists P n = (if n = 0 then P [] else enum_all (%x. all_n_lists (%xs. P (x # xs)) (n - 1)))"
unfolding all_n_lists_def enum_all
by (cases n) (auto simp add: enum_UNIV)

definition
  ex_n_lists :: "(('a :: enum) list \<Rightarrow> bool) \<Rightarrow> nat \<Rightarrow> bool"
where
  "ex_n_lists P n = (\<exists>xs \<in> set (List.n_lists n enum). P xs)"

lemma [code]:
  "ex_n_lists P n = (if n = 0 then P [] else enum_ex (%x. ex_n_lists (%xs. P (x # xs)) (n - 1)))"
unfolding ex_n_lists_def enum_ex
by (cases n) (auto simp add: enum_UNIV)


instantiation "fun" :: (enum, enum) enum
begin

definition
  "enum = map (\<lambda>ys. the o map_of (zip (enum\<Colon>'a list) ys)) (List.n_lists (length (enum\<Colon>'a\<Colon>enum list)) enum)"

definition
  "enum_all P = all_n_lists (\<lambda>bs. P (the o map_of (zip enum bs))) (length (enum :: 'a list))"

definition
  "enum_ex P = ex_n_lists (\<lambda>bs. P (the o map_of (zip enum bs))) (length (enum :: 'a list))"


instance proof
  show "UNIV = set (enum \<Colon> ('a \<Rightarrow> 'b) list)"
  proof (rule UNIV_eq_I)
    fix f :: "'a \<Rightarrow> 'b"
    have "f = the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) (map f enum))"
      by (auto simp add: map_of_zip_map fun_eq_iff intro: in_enum)
    then show "f \<in> set enum"
      by (auto simp add: enum_fun_def set_n_lists intro: in_enum)
  qed
next
  from map_of_zip_enum_inject
  show "distinct (enum \<Colon> ('a \<Rightarrow> 'b) list)"
    by (auto intro!: inj_onI simp add: enum_fun_def
      distinct_map distinct_n_lists enum_distinct set_n_lists enum_all)
next
  fix P
  show "enum_all (P :: ('a \<Rightarrow> 'b) \<Rightarrow> bool) = (\<forall>x. P x)"
  proof
    assume "enum_all P"
    show "\<forall>x. P x"
    proof
      fix f :: "'a \<Rightarrow> 'b"
      have f: "f = the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) (map f enum))"
        by (auto simp add: map_of_zip_map fun_eq_iff intro: in_enum)
      from `enum_all P` have "P (the \<circ> map_of (zip enum (map f enum)))"
        unfolding enum_all_fun_def all_n_lists_def
        apply (simp add: set_n_lists)
        apply (erule_tac x="map f enum" in allE)
        apply (auto intro!: in_enum)
        done
      from this f show "P f" by auto
    qed
  next
    assume "\<forall>x. P x"
    from this show "enum_all P"
      unfolding enum_all_fun_def all_n_lists_def by auto
  qed
next
  fix P
  show "enum_ex (P :: ('a \<Rightarrow> 'b) \<Rightarrow> bool) = (\<exists>x. P x)"
  proof
    assume "enum_ex P"
    from this show "\<exists>x. P x"
      unfolding enum_ex_fun_def ex_n_lists_def by auto
  next
    assume "\<exists>x. P x"
    from this obtain f where "P f" ..
    have f: "f = the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) (map f enum))"
      by (auto simp add: map_of_zip_map fun_eq_iff intro: in_enum) 
    from `P f` this have "P (the \<circ> map_of (zip (enum \<Colon> 'a\<Colon>enum list) (map f enum)))"
      by auto
    from  this show "enum_ex P"
      unfolding enum_ex_fun_def ex_n_lists_def
      apply (auto simp add: set_n_lists)
      apply (rule_tac x="map f enum" in exI)
      apply (auto intro!: in_enum)
      done
  qed
qed

end

lemma enum_fun_code [code]: "enum = (let enum_a = (enum \<Colon> 'a\<Colon>{enum, equal} list)
  in map (\<lambda>ys. the o map_of (zip enum_a ys)) (List.n_lists (length enum_a) enum))"
  by (simp add: enum_fun_def Let_def)

lemma enum_all_fun_code [code]:
  "enum_all P = (let enum_a = (enum :: 'a::{enum, equal} list)
   in all_n_lists (\<lambda>bs. P (the o map_of (zip enum_a bs))) (length enum_a))"
  by (simp add: enum_all_fun_def Let_def)

lemma enum_ex_fun_code [code]:
  "enum_ex P = (let enum_a = (enum :: 'a::{enum, equal} list)
   in ex_n_lists (\<lambda>bs. P (the o map_of (zip enum_a bs))) (length enum_a))"
  by (simp add: enum_ex_fun_def Let_def)

instantiation unit :: enum
begin

definition
  "enum = [()]"

definition
  "enum_all P = P ()"

definition
  "enum_ex P = P ()"

instance proof
qed (auto simp add: enum_unit_def UNIV_unit enum_all_unit_def enum_ex_unit_def intro: unit.exhaust)

end

instantiation bool :: enum
begin

definition
  "enum = [False, True]"

definition
  "enum_all P = (P False \<and> P True)"

definition
  "enum_ex P = (P False \<or> P True)"

instance proof
  fix P
  show "enum_all (P :: bool \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_bool_def by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: bool \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_bool_def by (auto, case_tac x) auto
qed (auto simp add: enum_bool_def UNIV_bool)

end

instantiation prod :: (enum, enum) enum
begin

definition
  "enum = List.product enum enum"

definition
  "enum_all P = enum_all (%x. enum_all (%y. P (x, y)))"

definition
  "enum_ex P = enum_ex (%x. enum_ex (%y. P (x, y)))"

 
instance by default
  (simp_all add: enum_prod_def product_list_set distinct_product
    enum_UNIV enum_distinct enum_all_prod_def enum_all enum_ex_prod_def enum_ex)

end

instantiation sum :: (enum, enum) enum
begin

definition
  "enum = map Inl enum @ map Inr enum"

definition
  "enum_all P = (enum_all (%x. P (Inl x)) \<and> enum_all (%x. P (Inr x)))"

definition
  "enum_ex P = (enum_ex (%x. P (Inl x)) \<or> enum_ex (%x. P (Inr x)))"

instance proof
  fix P
  show "enum_all (P :: ('a + 'b) \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_sum_def enum_all
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: ('a + 'b) \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_sum_def enum_ex
    by (auto, case_tac x) auto
qed (auto simp add: enum_UNIV enum_sum_def, case_tac x, auto intro: inj_onI simp add: distinct_map enum_distinct)

end

instantiation nibble :: enum
begin

definition
  "enum = [Nibble0, Nibble1, Nibble2, Nibble3, Nibble4, Nibble5, Nibble6, Nibble7,
    Nibble8, Nibble9, NibbleA, NibbleB, NibbleC, NibbleD, NibbleE, NibbleF]"

definition
  "enum_all P = (P Nibble0 \<and> P Nibble1 \<and> P Nibble2 \<and> P Nibble3 \<and> P Nibble4 \<and> P Nibble5 \<and> P Nibble6 \<and> P Nibble7
     \<and> P Nibble8 \<and> P Nibble9 \<and> P NibbleA \<and> P NibbleB \<and> P NibbleC \<and> P NibbleD \<and> P NibbleE \<and> P NibbleF)"

definition
  "enum_ex P = (P Nibble0 \<or> P Nibble1 \<or> P Nibble2 \<or> P Nibble3 \<or> P Nibble4 \<or> P Nibble5 \<or> P Nibble6 \<or> P Nibble7
     \<or> P Nibble8 \<or> P Nibble9 \<or> P NibbleA \<or> P NibbleB \<or> P NibbleC \<or> P NibbleD \<or> P NibbleE \<or> P NibbleF)"

instance proof
  fix P
  show "enum_all (P :: nibble \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_nibble_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: nibble \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_nibble_def
    by (auto, case_tac x) auto
qed (simp_all add: enum_nibble_def UNIV_nibble)

end

instantiation char :: enum
begin

definition
  "enum = map (split Char) (List.product enum enum)"

lemma enum_chars [code]:
  "enum = chars"
  unfolding enum_char_def chars_def enum_nibble_def by simp

definition
  "enum_all P = list_all P chars"

definition
  "enum_ex P = list_ex P chars"

lemma set_enum_char: "set (enum :: char list) = UNIV"
    by (auto intro: char.exhaust simp add: enum_char_def product_list_set enum_UNIV full_SetCompr_eq [symmetric])

instance proof
  fix P
  show "enum_all (P :: char \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_char_def enum_chars[symmetric]
    by (auto simp add: list_all_iff set_enum_char)
next
  fix P
  show "enum_ex (P :: char \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_char_def enum_chars[symmetric]
    by (auto simp add: list_ex_iff set_enum_char)
next
  show "distinct (enum :: char list)"
    by (auto intro: inj_onI simp add: enum_char_def product_list_set distinct_map distinct_product enum_distinct)
qed (auto simp add: set_enum_char)

end

instantiation option :: (enum) enum
begin

definition
  "enum = None # map Some enum"

definition
  "enum_all P = (P None \<and> enum_all (%x. P (Some x)))"

definition
  "enum_ex P = (P None \<or> enum_ex (%x. P (Some x)))"

instance proof
  fix P
  show "enum_all (P :: 'a option \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_option_def enum_all
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: 'a option \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_option_def enum_ex
    by (auto, case_tac x) auto
qed (auto simp add: enum_UNIV enum_option_def, rule option.exhaust, auto intro: simp add: distinct_map enum_distinct)
end

instantiation set :: (enum) enum
begin

definition
  "enum = map set (sublists enum)"

definition
  "enum_all P \<longleftrightarrow> (\<forall>A\<in>set enum. P (A::'a set))"

definition
  "enum_ex P \<longleftrightarrow> (\<exists>A\<in>set enum. P (A::'a set))"

instance proof
qed (simp_all add: enum_set_def enum_all_set_def enum_ex_set_def sublists_powset distinct_set_sublists
  enum_distinct enum_UNIV)

end


subsection {* Small finite types *}

text {* We define small finite types for the use in Quickcheck *}

datatype finite_1 = a\<^isub>1

notation (output) a\<^isub>1  ("a\<^isub>1")

instantiation finite_1 :: enum
begin

definition
  "enum = [a\<^isub>1]"

definition
  "enum_all P = P a\<^isub>1"

definition
  "enum_ex P = P a\<^isub>1"

instance proof
  fix P
  show "enum_all (P :: finite_1 \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_finite_1_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: finite_1 \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_finite_1_def
    by (auto, case_tac x) auto
qed (auto simp add: enum_finite_1_def intro: finite_1.exhaust)

end

instantiation finite_1 :: linorder
begin

definition less_eq_finite_1 :: "finite_1 \<Rightarrow> finite_1 \<Rightarrow> bool"
where
  "less_eq_finite_1 x y = True"

definition less_finite_1 :: "finite_1 \<Rightarrow> finite_1 \<Rightarrow> bool"
where
  "less_finite_1 x y = False"

instance
apply (intro_classes)
apply (auto simp add: less_finite_1_def less_eq_finite_1_def)
apply (metis finite_1.exhaust)
done

end

hide_const (open) a\<^isub>1

datatype finite_2 = a\<^isub>1 | a\<^isub>2

notation (output) a\<^isub>1  ("a\<^isub>1")
notation (output) a\<^isub>2  ("a\<^isub>2")

instantiation finite_2 :: enum
begin

definition
  "enum = [a\<^isub>1, a\<^isub>2]"

definition
  "enum_all P = (P a\<^isub>1 \<and> P a\<^isub>2)"

definition
  "enum_ex P = (P a\<^isub>1 \<or> P a\<^isub>2)"

instance proof
  fix P
  show "enum_all (P :: finite_2 \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_finite_2_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: finite_2 \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_finite_2_def
    by (auto, case_tac x) auto
qed (auto simp add: enum_finite_2_def intro: finite_2.exhaust)

end

instantiation finite_2 :: linorder
begin

definition less_finite_2 :: "finite_2 \<Rightarrow> finite_2 \<Rightarrow> bool"
where
  "less_finite_2 x y = ((x = a\<^isub>1) & (y = a\<^isub>2))"

definition less_eq_finite_2 :: "finite_2 \<Rightarrow> finite_2 \<Rightarrow> bool"
where
  "less_eq_finite_2 x y = ((x = y) \<or> (x < y))"


instance
apply (intro_classes)
apply (auto simp add: less_finite_2_def less_eq_finite_2_def)
apply (metis finite_2.distinct finite_2.nchotomy)+
done

end

hide_const (open) a\<^isub>1 a\<^isub>2


datatype finite_3 = a\<^isub>1 | a\<^isub>2 | a\<^isub>3

notation (output) a\<^isub>1  ("a\<^isub>1")
notation (output) a\<^isub>2  ("a\<^isub>2")
notation (output) a\<^isub>3  ("a\<^isub>3")

instantiation finite_3 :: enum
begin

definition
  "enum = [a\<^isub>1, a\<^isub>2, a\<^isub>3]"

definition
  "enum_all P = (P a\<^isub>1 \<and> P a\<^isub>2 \<and> P a\<^isub>3)"

definition
  "enum_ex P = (P a\<^isub>1 \<or> P a\<^isub>2 \<or> P a\<^isub>3)"

instance proof
  fix P
  show "enum_all (P :: finite_3 \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_finite_3_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: finite_3 \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_finite_3_def
    by (auto, case_tac x) auto
qed (auto simp add: enum_finite_3_def intro: finite_3.exhaust)

end

instantiation finite_3 :: linorder
begin

definition less_finite_3 :: "finite_3 \<Rightarrow> finite_3 \<Rightarrow> bool"
where
  "less_finite_3 x y = (case x of a\<^isub>1 => (y \<noteq> a\<^isub>1)
     | a\<^isub>2 => (y = a\<^isub>3)| a\<^isub>3 => False)"

definition less_eq_finite_3 :: "finite_3 \<Rightarrow> finite_3 \<Rightarrow> bool"
where
  "less_eq_finite_3 x y = ((x = y) \<or> (x < y))"


instance proof (intro_classes)
qed (auto simp add: less_finite_3_def less_eq_finite_3_def split: finite_3.split_asm)

end

hide_const (open) a\<^isub>1 a\<^isub>2 a\<^isub>3


datatype finite_4 = a\<^isub>1 | a\<^isub>2 | a\<^isub>3 | a\<^isub>4

notation (output) a\<^isub>1  ("a\<^isub>1")
notation (output) a\<^isub>2  ("a\<^isub>2")
notation (output) a\<^isub>3  ("a\<^isub>3")
notation (output) a\<^isub>4  ("a\<^isub>4")

instantiation finite_4 :: enum
begin

definition
  "enum = [a\<^isub>1, a\<^isub>2, a\<^isub>3, a\<^isub>4]"

definition
  "enum_all P = (P a\<^isub>1 \<and> P a\<^isub>2 \<and> P a\<^isub>3 \<and> P a\<^isub>4)"

definition
  "enum_ex P = (P a\<^isub>1 \<or> P a\<^isub>2 \<or> P a\<^isub>3 \<or> P a\<^isub>4)"

instance proof
  fix P
  show "enum_all (P :: finite_4 \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_finite_4_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: finite_4 \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_finite_4_def
    by (auto, case_tac x) auto
qed (auto simp add: enum_finite_4_def intro: finite_4.exhaust)

end

hide_const (open) a\<^isub>1 a\<^isub>2 a\<^isub>3 a\<^isub>4


datatype finite_5 = a\<^isub>1 | a\<^isub>2 | a\<^isub>3 | a\<^isub>4 | a\<^isub>5

notation (output) a\<^isub>1  ("a\<^isub>1")
notation (output) a\<^isub>2  ("a\<^isub>2")
notation (output) a\<^isub>3  ("a\<^isub>3")
notation (output) a\<^isub>4  ("a\<^isub>4")
notation (output) a\<^isub>5  ("a\<^isub>5")

instantiation finite_5 :: enum
begin

definition
  "enum = [a\<^isub>1, a\<^isub>2, a\<^isub>3, a\<^isub>4, a\<^isub>5]"

definition
  "enum_all P = (P a\<^isub>1 \<and> P a\<^isub>2 \<and> P a\<^isub>3 \<and> P a\<^isub>4 \<and> P a\<^isub>5)"

definition
  "enum_ex P = (P a\<^isub>1 \<or> P a\<^isub>2 \<or> P a\<^isub>3 \<or> P a\<^isub>4 \<or> P a\<^isub>5)"

instance proof
  fix P
  show "enum_all (P :: finite_5 \<Rightarrow> bool) = (\<forall>x. P x)"
    unfolding enum_all_finite_5_def
    by (auto, case_tac x) auto
next
  fix P
  show "enum_ex (P :: finite_5 \<Rightarrow> bool) = (\<exists>x. P x)"
    unfolding enum_ex_finite_5_def
    by (auto, case_tac x) auto
qed (auto simp add: enum_finite_5_def intro: finite_5.exhaust)

end

hide_const (open) a\<^isub>1 a\<^isub>2 a\<^isub>3 a\<^isub>4 a\<^isub>5


subsection {* An executable THE operator on finite types *}

definition
  [code del]: "enum_the = The"

lemma [code]:
  "The P = (case filter P enum of [x] => x | _ => enum_the P)"
proof -
  {
    fix a
    assume filter_enum: "filter P enum = [a]"
    have "The P = a"
    proof (rule the_equality)
      fix x
      assume "P x"
      show "x = a"
      proof (rule ccontr)
        assume "x \<noteq> a"
        from filter_enum obtain us vs
          where enum_eq: "enum = us @ [a] @ vs"
          and "\<forall> x \<in> set us. \<not> P x"
          and "\<forall> x \<in> set vs. \<not> P x"
          and "P a"
          by (auto simp add: filter_eq_Cons_iff) (simp only: filter_empty_conv[symmetric])
        with `P x` in_enum[of x, unfolded enum_eq] `x \<noteq> a` show "False" by auto
      qed
    next
      from filter_enum show "P a" by (auto simp add: filter_eq_Cons_iff)
    qed
  }
  from this show ?thesis
    unfolding enum_the_def by (auto split: list.split)
qed

code_abort enum_the
code_const enum_the (Eval "(fn p => raise Match)")


subsection {* Further operations on finite types *}

lemma Collect_code [code]:
  "Collect P = set (filter P enum)"
by (auto simp add: enum_UNIV)

lemma [code]:
  "Id = image (%x. (x, x)) (set Enum.enum)"
by (auto intro: imageI in_enum)

lemma tranclp_unfold [code, no_atp]:
  "tranclp r a b \<equiv> (a, b) \<in> trancl {(x, y). r x y}"
by (simp add: trancl_def)

lemma rtranclp_rtrancl_eq [code, no_atp]:
  "rtranclp r x y = ((x, y) : rtrancl {(x, y). r x y})"
unfolding rtrancl_def by auto

lemma max_ext_eq [code]:
  "max_ext R = {(X, Y). finite X & finite Y & Y ~={} & (ALL x. x : X --> (EX xa : Y. (x, xa) : R))}"
by (auto simp add: max_ext.simps)

lemma max_extp_eq[code]:
  "max_extp r x y = ((x, y) : max_ext {(x, y). r x y})"
unfolding max_ext_def by auto

lemma mlex_eq[code]:
  "f <*mlex*> R = {(x, y). f x < f y \<or> (f x <= f y \<and> (x, y) : R)}"
unfolding mlex_prod_def by auto

subsection {* Executable accessible part *}

definition 
  [code del]: "card_UNIV = card UNIV"

lemma [code]:
  "card_UNIV TYPE('a :: enum) = card (set (Enum.enum :: 'a list))"
  unfolding card_UNIV_def enum_UNIV ..

lemma [code]:
  fixes xs :: "('a::finite \<times> 'a) list"
  shows "acc (set xs) = bacc (set xs) (card_UNIV TYPE('a))"
  by (simp add: card_UNIV_def acc_bacc_eq)

lemma [code_unfold]: "accp r = (\<lambda>x. x \<in> acc {(x, y). r x y})"
  unfolding acc_def by simp

subsection {* Closing up *}

hide_type (open) finite_1 finite_2 finite_3 finite_4 finite_5
hide_const (open) enum enum_all enum_ex all_n_lists ex_n_lists ntrancl

end

