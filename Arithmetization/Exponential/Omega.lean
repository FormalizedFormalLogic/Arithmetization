import Arithmetization.Exponential.Log

namespace LO.FirstOrder

namespace Arith

/-- ∀ x, ∃ y, 2^{|x|^2} = y-/
def omega₁ : Sentence ℒₒᵣ := “∀ ∃ ∃[#0 < #2 + 1] (!Model.binarylengthdef [#0, #2] ∧ !Model.Exp.def [#0*#0, #1])”

inductive Theory.Omega₁ : Theory ℒₒᵣ where
  | omega : Theory.Omega₁ omega₁

notation "𝛀₁" => Theory.Omega₁

@[simp] lemma Omega₁.mem_iff {σ} : σ ∈ 𝛀₁ ↔ σ = omega₁ :=
  ⟨by rintro ⟨⟩; rfl, by rintro rfl; exact Theory.Omega₁.omega⟩

noncomputable section

namespace Model

variable {M : Type} [Zero M] [One M] [Add M] [Mul M] [LT M] [𝐏𝐀⁻.Mod M]

lemma models_Omega₁_iff [𝐈𝚺₀.Mod M] : M ⊧ₘ omega₁ ↔ ∀ x : M, ∃ y, Exp (‖x‖^2) y := by
  simp [models_def, omega₁, binary_length_defined.pval, Exp.defined.pval, sq, ←le_iff_lt_succ]
  constructor
  · intro h x
    rcases h x with ⟨y, _, _, rfl, h⟩; exact ⟨y, h⟩
  · intro h x
    rcases h x with ⟨y, h⟩
    exact ⟨y, ‖x‖, by simp, rfl, h⟩

lemma sigma₁_omega₁ [𝐈𝚺₁.Mod M] : M ⊧ₘ omega₁ := models_Omega₁_iff.mpr (fun x ↦ Exp.range_exists (‖x‖^2))

instance [𝐈𝚺₁.Mod M] : 𝛀₁.Mod M := ⟨by intro _; simp; rintro rfl; exact sigma₁_omega₁⟩

variable [𝐈𝚺₀.Mod M] [𝛀₁.Mod M]

lemma exists_exp_sq_binary_length (x : M) : ∃ y, Exp (‖x‖^2) y :=
  models_Omega₁_iff.mp (Theory.Mod.models M Theory.Omega₁.omega) x

lemma exists_unique_exp_sq_binary_length (x : M) : ∃! y, Exp (‖x‖^2) y := by
  rcases exists_exp_sq_binary_length x with ⟨y, h⟩
  exact ExistsUnique.intro y h (fun y' h' ↦ h'.uniq h)

lemma hash_exists_unique (x y : M) : ∃! z, Exp (‖x‖ * ‖y‖) z := by
  wlog le : x ≤ y
  · simpa [mul_comm] using this y x (le_of_not_ge le)
  rcases exists_exp_sq_binary_length y with ⟨z, h⟩
  have : ‖x‖ * ‖y‖ < ‖z‖ :=
    lt_of_le_of_lt (by simp [sq]; exact mul_le_mul_right (binary_length_monotone le)) h.lt_binary_length
  have : Exp (‖x‖ * ‖y‖) (bexp z (‖x‖ * ‖y‖)) := exp_bexp_of_lt (a := z) (x := ‖x‖ * ‖y‖) this
  exact ExistsUnique.intro (bexp z (‖x‖ * ‖y‖)) this (fun z' H' ↦ H'.uniq this)

instance : Hash M := ⟨fun a b ↦ Classical.choose! (hash_exists_unique a b)⟩

lemma exp_hash (a b : M) : Exp (‖a‖ * ‖b‖) (a # b) := Classical.choose!_spec (hash_exists_unique a b)

def hashdef : Σᴬ[0] 3 :=
  ⟨“∃[#0 < #2 + 1] ∃[#0 < #4 + 1] (!binarylengthdef [#1, #3] ∧ !binarylengthdef [#0, #4] ∧ !Exp.def [#1 * #0, #2])”, by simp⟩

lemma hash_defined : Σᴬ[0]-Function₂ (Hash.hash : M → M → M) hashdef := by
  intro v; simp[hashdef, binary_length_defined.pval, Exp.defined.pval, ←le_iff_lt_succ]
  constructor
  · intro h; exact ⟨‖v 1‖, by simp, ‖v 2‖, by simp, rfl, rfl, by rw [h]; exact exp_hash _ _⟩
  · rintro ⟨_, _, _, _, rfl, rfl, h⟩; exact h.uniq (exp_hash (v 1) (v 2))

instance : DefinableFunction₂ b s (Hash.hash : M → M → M) := defined_to_with_param₀ _ hash_defined

@[simp] lemma hash_pos (a b : M) : 0 < a # b := (exp_hash a b).range_pos

@[simp] lemma hash_lt (a b : M) : ‖a‖ * ‖b‖ < a # b := (exp_hash a b).dom_lt_range

lemma binary_length_hash (a b : M) : ‖a # b‖ = ‖a‖ * ‖b‖ + 1 := (exp_hash a b).binary_length_eq

@[simp] lemma hash_zero_left (a : M) : 0 # a = 1 := (exp_hash 0 a).uniq (by simp)

@[simp] lemma hash_zero_right (a : M) : a # 0 = 1 := (exp_hash a 0).uniq (by simp)

lemma hash_comm (a b : M) : a # b = b # a := (exp_hash a b).uniq (by simpa [mul_comm] using exp_hash b a)

end Model

end

end Arith

end LO.FirstOrder
