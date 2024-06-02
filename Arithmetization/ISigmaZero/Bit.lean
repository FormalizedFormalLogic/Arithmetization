import Arithmetization.ISigmaZero.Exponential.Exp
import Arithmetization.ISigmaZero.Exponential.Log

namespace LO.FirstOrder

namespace Arith

noncomputable section

variable {M : Type} [Zero M] [One M] [Add M] [Mul M] [LT M]

namespace Model

variable [M ⊧ₘ* 𝐈𝚺₀]

def Bit (i a : M) : Prop := ∃ p ≤ a, Exponential i p ∧ LenBit p a

instance : Membership M M := ⟨Bit⟩

def bitDef : 𝚺₀-Semisentence 2 := ⟨“∃[#0 < #2 + 1] (!Exponential.def [#1, #0] ∧ !lenbitDef [#0, #2])”, by simp⟩

lemma bit_defined : 𝚺₀-Relation ((· ∈ ·) : M → M → Prop) via bitDef := by
  intro v; simp [bitDef, lenbit_defined.df.iff, Exponential.defined.df.iff, ←le_iff_lt_succ]; rfl

@[simp] lemma bit_defined_iff (v) :
    Semiformula.Evalbm M v bitDef.val ↔ v 0 = fbit (v 1) (v 2) := fbit_defined.df.iff v

instance mem_definable : DefinableRel ℒₒᵣ 𝚺 0 ((· ∈ ·) : M → M → Prop) := .to_definable _ bit_defined

lemma lt_of_mem {i a : M} (h : i ∈ a) : i < a := by
  rcases h with ⟨p, _, hep, hp⟩
  exact lt_of_lt_of_le hep.lt hp.le

lemma mem_def (i a : M) : i ∈ a ↔ Bit i a := by rfl

section

variable {L : Language} [L.ORing] [Structure L M] [Structure.ORing L M] [Structure.Monotone L M]

variable (Γ : Polarity) (n : ℕ)

@[definability] lemma Definable.ball_mem {P : (Fin k → M) → M → Prop} {f : (Fin k → M) → M}
    (hf : Semipolynomial L Γ n f) (h : Definable L Γ n (fun w ↦ P (w ·.succ) (w 0))) :
    Definable L Γ n (fun v ↦ ∀ x ∈ f v, P v x) := by
  rcases hf.bounded with ⟨bf, hbf⟩
  rcases hf.definable with ⟨f_graph, hf_graph⟩
  rcases h with ⟨p, hp⟩
  exact ⟨⟨“∃[#0 < !!(Rew.bShift bf) + 1] (!f_graph ∧ ∀[#0 < #1] (!bitDef .[#0, #1] → !((Rew.substs (#0 :> (#·.succ.succ))).hom p)))”,
    by simp; apply Hierarchy.oringEmb; simp⟩,
    by  intro v; simp [hf_graph.eval, hp.eval, bit_defined.df.iff, ←le_iff_lt_succ]
        constructor
        · rintro h; exact ⟨f v, hbf v, rfl, fun x _ hx ↦ h x hx⟩
        · rintro ⟨_, _, rfl, h⟩ x hx; exact h x (lt_of_mem hx) hx⟩

@[definability] lemma Definable.bex_mem {P : (Fin k → M) → M → Prop} {f : (Fin k → M) → M}
    (hf : Semipolynomial L Γ n f) (h : Definable L Γ n (fun w ↦ P (w ·.succ) (w 0))) :
    Definable L Γ n (fun v ↦ ∃ x ∈ f v, P v x) := by
  rcases hf.bounded with ⟨bf, hbf⟩
  rcases hf.definable with ⟨f_graph, hf_graph⟩
  rcases h with ⟨p, hp⟩
  exact ⟨⟨“∃[#0 < !!(Rew.bShift bf) + 1] (!f_graph ∧ ∃[#0 < #1] (!bitDef .[#0, #1] ∧ !((Rew.substs (#0 :> (#·.succ.succ))).hom p)))”,
    by simp; apply Hierarchy.oringEmb; simp⟩,
    by  intro v; simp [hf_graph.eval, hp.eval, bit_defined.df.iff, ←le_iff_lt_succ]
        constructor
        · rintro ⟨x, hx, h⟩; exact ⟨f v, hbf v, rfl, x, lt_of_mem hx, hx, h⟩
        · rintro ⟨_, _, rfl, x, _, hx, h⟩; exact ⟨x, hx, h⟩⟩

end

end Model

end

end Arith

end LO.FirstOrder
