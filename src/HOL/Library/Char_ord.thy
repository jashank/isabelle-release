(*  Title:      HOL/Library/Char_ord.thy
    Author:     Norbert Voelker, Florian Haftmann
*)

header {* Order on characters *}

theory Char_ord
imports Main
begin

instantiation nibble :: linorder
begin

definition
  "n \<le> m \<longleftrightarrow> nat_of_nibble n \<le> nat_of_nibble m"

definition
  "n < m \<longleftrightarrow> nat_of_nibble n < nat_of_nibble m"

instance proof
qed (auto simp add: less_eq_nibble_def less_nibble_def not_le nat_of_nibble_eq_iff)

end

instantiation nibble :: distrib_lattice
begin

definition
  "(inf \<Colon> nibble \<Rightarrow> _) = min"

definition
  "(sup \<Colon> nibble \<Rightarrow> _) = max"

instance proof
qed (auto simp add: inf_nibble_def sup_nibble_def min_max.sup_inf_distrib1)

end

instantiation char :: linorder
begin

definition
  "c1 \<le> c2 \<longleftrightarrow> nat_of_char c1 \<le> nat_of_char c2"

definition
  "c1 < c2 \<longleftrightarrow> nat_of_char c1 < nat_of_char c2"

instance proof
qed (auto simp add: less_eq_char_def less_char_def nat_of_char_eq_iff)

end

lemma less_eq_char_Char:
  "Char n1 m1 \<le> Char n2 m2 \<longleftrightarrow> n1 < n2 \<or> n1 = n2 \<and> m1 \<le> m2"
proof -
  {
    assume "nat_of_nibble n1 * 16 + nat_of_nibble m1
      \<le> nat_of_nibble n2 * 16 + nat_of_nibble m2"
    then have "nat_of_nibble n1 \<le> nat_of_nibble n2"
    using nat_of_nibble_less_16 [of m1] nat_of_nibble_less_16 [of m2] by auto
  }
  note * = this
  show ?thesis
    using nat_of_nibble_less_16 [of m1] nat_of_nibble_less_16 [of m2]
    by (auto simp add: less_eq_char_def nat_of_char_Char less_eq_nibble_def less_nibble_def not_less nat_of_nibble_eq_iff dest: *)
qed

lemma less_char_Char:
  "Char n1 m1 < Char n2 m2 \<longleftrightarrow> n1 < n2 \<or> n1 = n2 \<and> m1 < m2"
proof -
  {
    assume "nat_of_nibble n1 * 16 + nat_of_nibble m1
      < nat_of_nibble n2 * 16 + nat_of_nibble m2"
    then have "nat_of_nibble n1 \<le> nat_of_nibble n2"
    using nat_of_nibble_less_16 [of m1] nat_of_nibble_less_16 [of m2] by auto
  }
  note * = this
  show ?thesis
    using nat_of_nibble_less_16 [of m1] nat_of_nibble_less_16 [of m2]
    by (auto simp add: less_char_def nat_of_char_Char less_eq_nibble_def less_nibble_def not_less nat_of_nibble_eq_iff dest: *)
qed

instantiation char :: distrib_lattice
begin

definition
  "(inf \<Colon> char \<Rightarrow> _) = min"

definition
  "(sup \<Colon> char \<Rightarrow> _) = max"

instance proof
qed (auto simp add: inf_char_def sup_char_def min_max.sup_inf_distrib1)

end

text {* Legacy aliasses *}

lemmas nibble_less_eq_def = less_eq_nibble_def
lemmas nibble_less_def = less_nibble_def
lemmas char_less_eq_def = less_eq_char_def
lemmas char_less_def = less_char_def
lemmas char_less_eq_simp = less_eq_char_Char
lemmas char_less_simp = less_char_Char

end

