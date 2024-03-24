import Arithmetization.Exponential.Exp
import Arithmetization.Exponential.Log

namespace LO.FirstOrder

namespace Arith

noncomputable section

variable {M : Type} [Zero M] [One M] [Add M] [Mul M] [LT M] [𝐏𝐀⁻.Mod M]

namespace Model

variable [𝐈𝚺₁.Mod M]

def Bit (i a : M) : Prop := LenBit (exp i) a

instance : Membership M M := ⟨Bit⟩

def bitdef : Δ₀Sentence 2 := ⟨“∃[#0 < #2 + 1] (!expdef [#0, #1] ∧ !lenbitdef [#0, #2])”, by simp⟩

lemma bit_defined : Δ₀-Relation ((· ∈ ·) : M → M → Prop) via bitdef := by
  intro v; simp [bitdef, lenbit_defined.pval, exp_defined.pval, ←le_iff_lt_succ]
  constructor
  · intro h; exact ⟨exp (v 0), by simp [h.le], rfl, h⟩
  · rintro ⟨_, _, rfl, h⟩; exact h

instance {b s} : DefinableRel b s ((· ∈ ·) : M → M → Prop) := defined_to_with_param₀ _ bit_defined

open Classical in
noncomputable def bitInsert (i a : M) : M := if i ∈ a then a else a + exp i

instance : Insert M M := ⟨bitInsert⟩

lemma insert_eq {i a : M} : insert i a = bitInsert i a := rfl

lemma mem_iff_bit {i a : M} : i ∈ a ↔ Bit i a := iff_of_eq rfl

lemma exp_le_of_mem {i a : M} (h : i ∈ a) : exp i ≤ a := LenBit.le h

lemma lt_of_mem {i a : M} (h : i ∈ a) : i < a := lt_of_lt_of_le (lt_exp i) (exp_le_of_mem h)

@[definability] lemma Definable.ball_mem {P : (Fin k → M) → M → Prop} {f : (Fin k → M) → M}
    (hf : Semipolynomial b s f) (h : Definable b s (fun w ↦ P (w ·.succ) (w 0))) :
    Definable b s (fun v ↦ ∀ x ∈ f v, P v x) := by
  rcases hf.bounded with ⟨bf, hbf⟩
  rcases hf.definable with ⟨f_graph, hf_graph⟩
  rcases h with ⟨p, hp⟩
  exact ⟨⟨“∃[#0 < !!(Rew.bShift bf) + 1] (!f_graph ∧ ∀[#0 < #1] (!bitdef .[#0, #1] → !((Rew.substs (#0 :> (#·.succ.succ))).hom p)))”, by simp⟩,
    by  intro v; simp [hf_graph.eval, hp.eval, bit_defined.pval, ←le_iff_lt_succ]
        constructor
        · rintro h; exact ⟨f v, hbf v, rfl, fun x _ hx ↦ h x hx⟩
        · rintro ⟨_, _, rfl, h⟩ x hx; exact h x (lt_of_mem hx) hx⟩

@[definability] lemma Definable.bex_mem {P : (Fin k → M) → M → Prop} {f : (Fin k → M) → M}
    (hf : Semipolynomial b s f) (h : Definable b s (fun w ↦ P (w ·.succ) (w 0))) :
    Definable b s (fun v ↦ ∃ x ∈ f v, P v x) := by
  rcases hf.bounded with ⟨bf, hbf⟩
  rcases hf.definable with ⟨f_graph, hf_graph⟩
  rcases h with ⟨p, hp⟩
  exact ⟨⟨“∃[#0 < !!(Rew.bShift bf) + 1] (!f_graph ∧ ∃[#0 < #1] (!bitdef .[#0, #1] ∧ !((Rew.substs (#0 :> (#·.succ.succ))).hom p)))”, by simp⟩,
    by  intro v; simp [hf_graph.eval, hp.eval, bit_defined.pval, ←le_iff_lt_succ]
        constructor
        · rintro ⟨x, hx, h⟩; exact ⟨f v, hbf v, rfl, x, lt_of_mem hx, hx, h⟩
        · rintro ⟨_, _, rfl, x, _, hx, h⟩; exact ⟨x, hx, h⟩⟩

lemma mem_iff_mul_exp_add_exp_add {i a : M} : i ∈ a ↔ ∃ k, ∃ r < exp i, a = k * exp (i + 1) + exp i + r := by
  simp [mem_iff_bit, exp_succ]
  exact lenbit_iff_add_mul (exp_pow2 i) (a := a)

lemma not_mem_iff_mul_exp_add {i a : M} : i ∉ a ↔ ∃ k, ∃ r < exp i, a = k * exp (i + 1) + r := by
  simp [mem_iff_bit, exp_succ]
  exact not_lenbit_iff_add_mul (exp_pow2 i) (a := a)

@[simp] lemma not_mem_zero (i : M) : i ∉ (0 : M) := by simp [mem_iff_bit, Bit]

@[simp] lemma mem_bitInsert_iff {i j a : M} :
    i ∈ insert j a ↔ i = j ∨ i ∈ a := by
  by_cases h : j ∈ a <;> simp [h, insert_eq, bitInsert]
  · by_cases e : i = j <;> simp [h, e]
  · simpa [exponential_inj.eq_iff] using
      lenbit_add_pow2_iff_of_not_lenbit (exp_pow2 i) (exp_pow2 j) h

lemma pos_of_nonempty {i a : M} (h : i ∈ a) : 0 < a := by
  by_contra A; simp at A; rcases A; simp_all

lemma log_mem_of_pos {a : M} (h : 0 < a) : log a ∈ a :=
  mem_iff_mul_exp_add_exp_add.mpr
    ⟨0, a - exp log a,
      (tsub_lt_iff_left (exponential_log_le_self h)).mpr (by rw [←two_mul]; exact lt_two_mul_exponential_log h),
      by simp; exact Eq.symm <| add_tsub_self_of_le (exponential_log_le_self h)⟩

lemma le_log_of_mem {i a : M} (h : i ∈ a) : i ≤ log a := (exp_le_iff_le_log (pos_of_nonempty h)).mp (exp_le_of_mem h)

lemma succ_mem_iff_mem_div_two {i a : M} : i + 1 ∈ a ↔ i ∈ a / 2 := by simp [mem_iff_bit, Bit, LenBit.iff_rem, exp_succ, div_mul]

lemma lt_length_of_mem {i a : M} (h : i ∈ a) : i < ‖a‖ := by
  simpa [length_of_pos (pos_of_nonempty h), ←le_iff_lt_succ] using le_log_of_mem h

lemma lt_exp_iff {a i : M} : a < exp i ↔ ∀ j ∈ a, j < i :=
  ⟨fun h j hj ↦ exponential_monotone.mp <| lt_of_le_of_lt (exp_le_of_mem hj) h,
   by contrapose; simp
      intro (h : exp i ≤ a)
      have pos : 0 < a := lt_of_lt_of_le (by simp) h
      exact ⟨log a, log_mem_of_pos pos, (exp_le_iff_le_log pos).mp h⟩⟩

instance : HasSubset M := ⟨fun a b ↦ ∀ ⦃i⦄, i ∈ a → i ∈ b⟩

def bitSubsetdef : Δ₀Sentence 2 := ⟨“∀[#0 < #1] (!bitdef [#0, #1] → !bitdef [#0, #2])”, by simp⟩

lemma bitSubset_defined : Δ₀-Relation ((· ⊆ ·) : M → M → Prop) via bitSubsetdef := by
  intro v; simp [bitSubsetdef, bit_defined.pval]
  exact ⟨by intro h x _ hx; exact h hx, by intro h x hx; exact h x (lt_of_mem hx) hx⟩

instance {b s} : DefinableRel b s ((· ⊆ ·) : M → M → Prop) := defined_to_with_param₀ _ bitSubset_defined

lemma mem_exp_add_succ_sub_one (i j : M) : i ∈ exp (i + j + 1) - 1 := by
  have : exp (i + j + 1) - 1 = (exp j - 1) * exp (i + 1) + exp i + (exp i - 1) := calc
    exp (i + j + 1) - 1 = exp j * exp (i + 1) - 1                             := by simp [exp_add, ←mul_assoc, mul_comm]
    _                   = exp j * exp (i + 1) - exp (i + 1) + exp (i + 1) - 1 := by rw [sub_add_self_of_le]; exact le_mul_of_pos_left (exp_pos j)
    _                   = (exp j - 1) * exp (i + 1) + exp (i + 1) - 1         := by simp [sub_mul]
    _                   = (exp j - 1) * exp (i + 1) + (exp i + exp i) - 1     := by simp [←two_mul, ←exp_succ i]
    _                   = (exp j - 1) * exp (i + 1) + (exp i + exp i - 1)     := by rw [add_tsub_assoc_of_le]; simp [←two_mul, ←pos_iff_one_le]
    _                   = (exp j - 1) * exp (i + 1) + exp i + (exp i - 1)     := by simp [add_assoc, add_tsub_assoc_of_le]
  exact mem_iff_mul_exp_add_exp_add.mpr ⟨exp j - 1, exp i - 1, (tsub_lt_iff_left (by simp)).mpr $ by simp, this⟩

/-- under a = {0, 1, 2, ..., a - 1} -/
def under (a : M) : M := exp a - 1

lemma mem_under_iff {i j : M} : i ∈ under j ↔ i < j := by
  constructor
  · intro h
    have : exp i < exp j := calc
      exp i ≤ exp j - 1 := exp_le_of_mem h
      _     < exp j     := pred_lt_self_of_pos (exp_pos j)
    exact exponential_monotone.mp this
  · intro lt
    have := lt_iff_succ_le.mp lt
    let k := j - (i + 1)
    have : j = i + k + 1 := by
      simp [add_assoc, ←sub_sub]; rw [sub_add_self_of_le, add_tsub_self_of_le]
      · exact le_of_lt lt
      · exact le_tsub_of_add_le_left this
    rw [this]; exact mem_exp_add_succ_sub_one i k

lemma eq_zero_of_subset_zero {a : M} : a ⊆ 0 → a = 0 := by
  intro h; by_contra A
  have : log a ∈ 0 := h (log_mem_of_pos (pos_iff_ne_zero.mpr A))
  simp_all

lemma subset_div_two {a b : M} : a ⊆ b → a / 2 ⊆ b / 2 := by
  intro ss i hi
  have : i + 1 ∈ a := succ_mem_iff_mem_div_two.mpr hi
  exact succ_mem_iff_mem_div_two.mp <| ss this

lemma zero_mem_iff {a : M} : 0 ∉ a ↔ 2 ∣ a := by simp [mem_iff_bit, Bit, LenBit]

@[simp] lemma zero_not_mem (a : M) : 0 ∉ 2 * a := by simp [mem_iff_bit, Bit, LenBit]

lemma le_of_subset {a b : M} (h : a ⊆ b) : a ≤ b := by
  revert a
  induction b using hierarchy_polynomial_induction_pi₁
  · definability
  case zero =>
    intro a h
    simp [eq_zero_of_subset_zero h]
  case even b IH =>
    intro a ha
    have IH : a / 2 ≤ b := IH (by simpa using subset_div_two ha)
    have : 2 * (a / 2) = a :=
      mul_div_self_of_dvd.mpr (zero_mem_iff.mp $ by intro h; have : 0 ∈ 2 * b := ha h; simp_all)
    simpa [this] using mul_le_mul_left (a := 2) IH
  case odd b IH =>
    intro a ha
    have IH : a / 2 ≤ b := IH (by simpa [div_mul_add' b 2 one_lt_two] using subset_div_two ha)
    exact le_trans (le_two_mul_div_two_add_one a) (by simpa using IH)

lemma mem_ext {a b : M} (h : ∀ i, i ∈ a ↔ i ∈ b) : a = b :=
  le_antisymm (le_of_subset $ fun i hi ↦ (h i).mp hi) (le_of_subset $ fun i hi ↦ (h i).mpr hi)

theorem finset_comprehension (P : M → Prop) (n : M) : ∃ s < exp n, ∀ i < n, i ∈ s ↔ P i := by {  }

end Model

end

end Arith

end LO.FirstOrder
