(*  Title:      HOL/IOA/Solve.thy
    Author:     Tobias Nipkow & Konrad Slind
    Copyright   1994  TU Muenchen
*)

section \<open>Weak possibilities mapping (abstraction)\<close>

theory Solve
imports IOA
begin

definition is_weak_pmap :: "['c \<Rightarrow> 'a, ('action,'c)ioa,('action,'a)ioa] \<Rightarrow> bool" where
  "is_weak_pmap f C A \<equiv>
   (\<forall>s\<in>starts_of(C). f(s)\<in>starts_of(A)) \<and>
   (\<forall>s t a. reachable C s \<and>
            (s,a,t)\<in>trans_of(C)
            \<longrightarrow> (if a\<in>externals(asig_of(C)) then
                   (f(s),a,f(t))\<in>trans_of(A)
                 else f(s)=f(t)))"

declare mk_trace_thm [simp] trans_in_actions [simp]

lemma trace_inclusion: 
  "[| IOA(C); IOA(A); externals(asig_of(C)) = externals(asig_of(A));  
           is_weak_pmap f C A |] ==> traces(C) \<subseteq> traces(A)"
  apply (unfold is_weak_pmap_def traces_def)

  apply (simp (no_asm) add: has_trace_def)
  apply safe
  apply (rename_tac ex1 ex2)

  (* choose same trace, therefore same NF *)
  apply (rule_tac x = "mk_trace C ex1" in exI)
  apply simp

  (* give execution of abstract automata *)
  apply (rule_tac x = "(mk_trace A ex1,\<lambda>i. f (ex2 i))" in bexI)

  (* Traces coincide *)
   apply (simp (no_asm_simp) add: mk_trace_def filter_oseq_idemp)

  (* Use lemma *)
  apply (frule states_of_exec_reachable)

  (* Now show that it's an execution *)
  apply (simp add: executions_def)
  apply safe

  (* Start states map to start states *)
  apply (drule bspec)
  apply assumption

  (* Show that it's an execution fragment *)
  apply (simp add: is_execution_fragment_def)
  apply safe

  apply (erule_tac x = "ex2 n" in allE)
  apply (erule_tac x = "ex2 (Suc n)" in allE)
  apply (erule_tac x = a in allE)
  apply simp
  done

(* Lemmata *)

lemma imp_conj_lemma: "(P \<Longrightarrow> Q\<longrightarrow>R) \<Longrightarrow> P\<and>Q \<longrightarrow> R"
  by blast


(* fist_order_tautology of externals_of_par *)
lemma externals_of_par_extra:
  "a\<in>externals(asig_of(A1||A2)) =     
   (a\<in>externals(asig_of(A1)) \<and> a\<in>externals(asig_of(A2)) \<or>
   a\<in>externals(asig_of(A1)) \<and> a\<notin>externals(asig_of(A2)) \<or>
   a\<notin>externals(asig_of(A1)) \<and> a\<in>externals(asig_of(A2)))"
  apply (auto simp add: externals_def asig_of_par asig_comp_def asig_inputs_def asig_outputs_def)
  done

lemma comp1_reachable: "[| reachable (C1||C2) s |] ==> reachable C1 (fst s)"
  apply (simp add: reachable_def)
  apply (erule bexE)
  apply (rule_tac x =
    "(filter_oseq (\<lambda>a. a\<in>actions (asig_of (C1))) (fst ex) , \<lambda>i. fst (snd ex i))" in bexI)
(* fst(s) is in projected execution *)
  apply force
(* projected execution is indeed an execution *)
  apply (simp cong del: if_weak_cong
    add: executions_def is_execution_fragment_def par_def starts_of_def
      trans_of_def filter_oseq_def
    split: option.split)
  done


(* Exact copy of proof of comp1_reachable for the second
   component of a parallel composition.     *)
lemma comp2_reachable: "[| reachable (C1||C2) s|] ==> reachable C2 (snd s)"
  apply (simp add: reachable_def)
  apply (erule bexE)
  apply (rule_tac x =
    "(filter_oseq (\<lambda>a. a\<in>actions (asig_of (C2))) (fst ex) , \<lambda>i. snd (snd ex i))" in bexI)
(* fst(s) is in projected execution *)
  apply force
(* projected execution is indeed an execution *)
  apply (simp cong del: if_weak_cong
    add: executions_def is_execution_fragment_def par_def starts_of_def
    trans_of_def filter_oseq_def
    split: option.split)
  done

declare if_split [split del] if_weak_cong [cong del]

(*Composition of possibility-mappings *)
lemma fxg_is_weak_pmap_of_product_IOA: 
     "[| is_weak_pmap f C1 A1;  
         externals(asig_of(A1))=externals(asig_of(C1)); 
         is_weak_pmap g C2 A2;   
         externals(asig_of(A2))=externals(asig_of(C2));  
         compat_ioas C1 C2; compat_ioas A1 A2  |]      
   ==> is_weak_pmap (\<lambda>p.(f(fst(p)),g(snd(p)))) (C1||C2) (A1||A2)"
  apply (unfold is_weak_pmap_def)
  apply (rule conjI)
(* start_states *)
  apply (simp add: par_def starts_of_def)
(* transitions *)
  apply (rule allI)+
  apply (rule imp_conj_lemma)
  apply (simp (no_asm) add: externals_of_par_extra)
  apply (simp (no_asm) add: par_def)
  apply (simp add: trans_of_def)
  apply (simplesubst if_split)
  apply (rule conjI)
  apply (rule impI)
  apply (erule disjE)
(* case 1      a:e(A1) | a:e(A2) *)
  apply (simp add: comp1_reachable comp2_reachable ext_is_act)
  apply (erule disjE)
(* case 2      a:e(A1) | a~:e(A2) *)
  apply (simp add: comp1_reachable comp2_reachable ext_is_act ext1_ext2_is_not_act2)
(* case 3      a:~e(A1) | a:e(A2) *)
  apply (simp add: comp1_reachable comp2_reachable ext_is_act ext1_ext2_is_not_act1)
(* case 4      a:~e(A1) | a~:e(A2) *)
  apply (rule impI)
  apply (subgoal_tac "a\<notin>externals (asig_of (A1)) & a\<notin>externals (asig_of (A2))")
(* delete auxiliary subgoal *)
  prefer 2
  apply force
  apply (simp (no_asm) add: conj_disj_distribR cong add: conj_cong split: if_split)
  apply (tactic \<open>
    REPEAT((resolve_tac \<^context> [conjI, impI] 1 ORELSE eresolve_tac \<^context> [conjE] 1) THEN
      asm_full_simp_tac(\<^context> addsimps [@{thm comp1_reachable}, @{thm comp2_reachable}]) 1)\<close>)
  done


lemma reachable_rename_ioa: "[| reachable (rename C g) s |] ==> reachable C s"
  apply (simp add: reachable_def)
  apply (erule bexE)
  apply (rule_tac x = "((\<lambda>i. case (fst ex i) of None \<Rightarrow> None | Some (x) => g x) ,snd ex)" in bexI)
  apply (simp (no_asm))
(* execution is indeed an execution of C *)
  apply (simp add: executions_def is_execution_fragment_def par_def
    starts_of_def trans_of_def rename_def split: option.split)
  apply force
  done


lemma rename_through_pmap: "[| is_weak_pmap f C A |] 
                       ==> (is_weak_pmap f (rename C g) (rename A g))"
  apply (simp add: is_weak_pmap_def)
  apply (rule conjI)
  apply (simp add: rename_def starts_of_def)
  apply (rule allI)+
  apply (rule imp_conj_lemma)
  apply (simp (no_asm) add: rename_def)
  apply (simp add: externals_def asig_inputs_def asig_outputs_def asig_of_def trans_of_def)
  apply safe
  apply (simplesubst if_split)
  apply (rule conjI)
  apply (rule impI)
  apply (erule disjE)
  apply (erule exE)
  apply (erule conjE)
(* x is input *)
  apply (drule sym)
  apply (drule sym)
  apply simp
  apply hypsubst+
  apply (cut_tac C = "C" and g = "g" and s = "s" in reachable_rename_ioa)
  apply assumption
  apply simp
(* x is output *)
  apply (erule exE)
  apply (erule conjE)
  apply (drule sym)
  apply (drule sym)
  apply simp
  apply hypsubst+
  apply (cut_tac C = "C" and g = "g" and s = "s" in reachable_rename_ioa)
  apply assumption
  apply simp
(* x is internal *)
  apply (simp (no_asm) cong add: conj_cong)
  apply (rule impI)
  apply (erule conjE)
  apply (cut_tac C = "C" and g = "g" and s = "s" in reachable_rename_ioa)
  apply auto
  done

declare if_split [split] if_weak_cong [cong]

end
