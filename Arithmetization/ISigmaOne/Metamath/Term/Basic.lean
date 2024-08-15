import Arithmetization.ISigmaOne.Metamath.Language
import Arithmetization.ISigmaOne.HFS

noncomputable section

namespace LO.Arith

open FirstOrder FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Arith.Language V} {pL : LDef} [Arith.Language.Defined L pL]

section term

def qqBvar (z : V) : V := ⟪0, z⟫ + 1

def qqFvar (x : V) : V := ⟪1, x⟫ + 1

def qqFunc (k f v : V) : V := ⟪2, k, f, v⟫ + 1

scoped prefix:max "^#" => qqBvar

scoped prefix:max "^&" => qqFvar

scoped prefix:max "^func " => qqFunc

@[simp] lemma var_lt_qqBvar (z : V) : z < ^#z := lt_succ_iff_le.mpr <| le_pair_right 0 z

@[simp] lemma var_lt_qqFvar (x : V) : x < ^&x := lt_succ_iff_le.mpr <| le_pair_right 1 x

@[simp] lemma arity_lt_qqFunc (k f v : V) : k < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right 2 k) <| pair_le_pair_right 2 <| le_pair_left k ⟪f, v⟫

@[simp] lemma func_lt_qqFunc (k f v : V) : f < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_left f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

@[simp] lemma terms_lt_qqFunc (k f v : V) : v < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

lemma lt_qqFunc_of_mem {i b k f v : V} (hi : ⟪i, b⟫ ∈ v) : b < ^func k f v :=
  _root_.lt_trans (lt_of_mem_rng hi) (terms_lt_qqFunc k f v)

@[simp] lemma qqBvar_inj {z z' : V} : ^#z = ^#z' ↔ z = z' := by simp [qqBvar]

@[simp] lemma qqFvar_inj {x x' : V} : ^&x = ^&x' ↔ x = x' := by simp [qqFvar]

@[simp] lemma qqFunc_inj {k f v k' f' w : V} : ^func k f v = ^func k' f' w ↔ k = k' ∧ f = f' ∧ v = w := by simp [qqFunc]

def _root_.LO.FirstOrder.Arith.qqBvarDef : 𝚺₀.Semisentence 2 := .mkSigma “t z | ∃ t' < t, !pairDef t' 0 z ∧ t = t' + 1” (by simp)

lemma qqBvar_defined : 𝚺₀-Function₁ (qqBvar : V → V) via qqBvarDef := by
  intro v; simp [qqBvarDef]
  constructor
  · intro h; exact ⟨⟪0, v 1⟫, by simp [qqBvar, h], rfl, h⟩
  · rintro ⟨x, _, rfl, h⟩; exact h

@[simp] lemma eval_qqBvarDef (v) :
    Semiformula.Evalbm V v qqBvarDef.val ↔ v 0 = ^#(v 1) := qqBvar_defined.df.iff v

def _root_.LO.FirstOrder.Arith.qqFvarDef : 𝚺₀.Semisentence 2 := .mkSigma “t x | ∃ t' < t, !pairDef t' 1 x ∧ t = t' + 1” (by simp)

lemma qqFvar_defined : 𝚺₀-Function₁ (qqFvar : V → V) via qqFvarDef := by
  intro v; simp [qqFvarDef]
  constructor
  · intro h; exact ⟨⟪1, v 1⟫, by simp [qqFvar, h], rfl, h⟩
  · rintro ⟨x, _, rfl, h⟩; exact h

@[simp] lemma eval_qqFvarDef (v) :
    Semiformula.Evalbm V v qqFvarDef.val ↔ v 0 = ^&(v 1) := qqFvar_defined.df.iff v

private lemma qqFunc_graph {x k f v : V} :
    x = ^func k f v ↔ ∃ fv < x, fv = ⟪f, v⟫ ∧ ∃ kfv < x, kfv = ⟪k, fv⟫ ∧ ∃ x' < x, x' = ⟪2, kfv⟫ ∧ x = x' + 1 :=
  ⟨by rintro rfl
      exact ⟨⟪f, v⟫, lt_succ_iff_le.mpr <| le_trans (le_pair_right _ _) (le_pair_right _ _), rfl,
        ⟪k, f, v⟫, lt_succ_iff_le.mpr <| by simp, rfl,
        ⟪2, k, f, v⟫, by simp [qqFunc], rfl, rfl⟩,
   by rintro ⟨_, _, rfl, _, _, rfl, _, _, rfl, rfl⟩; rfl⟩

def _root_.LO.FirstOrder.Arith.qqFuncDef : 𝚺₀.Semisentence 4 := .mkSigma
  “x k f v | ∃ fv < x, !pairDef fv f v ∧ ∃ kfv < x, !pairDef kfv k fv ∧ ∃ x' < x, !pairDef x' 2 kfv ∧ x = x' + 1” (by simp)

lemma qqFunc_defined : 𝚺₀-Function₃ (qqFunc : V → V → V → V) via qqFuncDef := by
  intro v; simp [qqFuncDef, qqFunc_graph]

@[simp] lemma eval_qqFuncDef (v) :
    Semiformula.Evalbm V v qqFuncDef.val ↔ v 0 = ^func (v 1) (v 2) (v 3) := qqFunc_defined.df.iff v

namespace FormalizedTerm

variable (L)

def Phi (n : V) (C : Set V) (t : V) : Prop :=
  (∃ z < n, t = ^#z) ∨ (∃ x, t = ^&x) ∨ (∃ k f v : V, L.Func k f ∧ k = len v ∧ (∀ i < k, v.[i] ∈ C) ∧ t = ^func k f v)

private lemma phi_iff (n : V) (C : V) (t : V) :
    Phi L n {x | x ∈ C} t ↔
    (∃ z < n, t = ^#z) ∨
    (∃ x < t, t = ^&x) ∨
    (∃ k < t, ∃ f < t, ∃ v < t, L.Func k f ∧ k = len v ∧ (∀ i < k, v.[i] ∈ C) ∧ t = ^func k f v) where
  mp := by
    rintro (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, hk, hv, rfl⟩)
    · left; exact ⟨z, hz, rfl⟩
    · right; left
      exact ⟨x, lt_succ_iff_le.mpr <| by simp, rfl⟩
    · right; right
      exact ⟨k, by simp, f, by simp, v, by simp, hkf, hk, hv, rfl⟩
  mpr := by
    unfold Phi
    rintro (⟨z, hz, rfl⟩ | ⟨x, _, rfl⟩ | ⟨k, _, f, _, v, _, hkf, hk, hv, rfl⟩)
    · left; exact ⟨z, hz, rfl⟩
    · right; left; exact ⟨x, rfl⟩
    · right; right; exact ⟨k, f, v, hkf, hk, hv, rfl⟩

def blueprint (pL : LDef) : Fixpoint.Blueprint 1 where
  core := .mkDelta
    (.mkSigma “t C n |
      (∃ z < n, !qqBvarDef t z) ∨
      (∃ x < t, !qqFvarDef t x) ∨
      (∃ k < t, ∃ f < t, ∃ v < t, !pL.func k f ∧ !lenDef k v ∧ (∀ i < k, ∃ u, !nthDef u v i ∧ u ∈ C) ∧ !qqFuncDef t k f v)”
    (by simp))
    (.mkPi “t C n |
      (∃ z < n, !qqBvarDef t z) ∨
      (∃ x < t, !qqFvarDef t x) ∨
      (∃ k < t, ∃ f < t, ∃ v < t, !pL.func k f ∧ (∀ l, !lenDef l v → k = l) ∧ (∀ i < k, ∀ u, !nthDef u v i → u ∈ C) ∧ !qqFuncDef t k f v)”
    (by simp))

def construction : Fixpoint.Construction V (blueprint pL) where
  Φ := fun n ↦ Phi L (n 0)
  defined := ⟨by intro v; simp [blueprint], by
    intro v; simp [blueprint, phi_iff, Language.Defined.eval_func (L := L)]⟩
  monotone := by
    rintro C C' hC v x (h | h | ⟨k, f, v, hkf, hk, h, rfl⟩)
    · exact Or.inl h
    · exact Or.inr <| Or.inl h
    · exact Or.inr <| Or.inr ⟨k, f, v, hkf, hk, fun i hi ↦ hC (h i hi), rfl⟩

instance : (construction L).StrongFinite V where
  strong_finite := by
    rintro C v x (h | h | ⟨k, f, v, hkf, hk, h, rfl⟩)
    · exact Or.inl h
    · exact Or.inr <| Or.inl h
    · exact Or.inr <| Or.inr ⟨k, f, v, hkf, hk, fun i hi ↦
        ⟨h i hi, lt_of_le_of_lt (nth_le _ _) (by simp)⟩, rfl⟩

end FormalizedTerm

open FormalizedTerm

variable (L)

def Language.Semiterm (n : V) : V → Prop := (construction L).Fixpoint ![n]

abbrev Language.Term : V → Prop := L.Semiterm 0

def _root_.LO.FirstOrder.Arith.LDef.isSemitermDef (pL : LDef) : 𝚫₁-Semisentence 2 := (blueprint pL).fixpointDefΔ₁.rew (Rew.substs ![#1, #0])

lemma isSemiterm_defined : 𝚫₁-Relation L.Semiterm via pL.isSemitermDef :=
  ⟨HSemiformula.ProperOn.rew (construction L).fixpoint_definedΔ₁.proper _,
   by intro v; simp [LDef.isSemitermDef, (construction L).eval_fixpointDefΔ₁]; rfl⟩

@[simp] lemma eval_isSemitermDef (v) :
    Semiformula.Evalbm V v pL.isSemitermDef.val ↔ L.Semiterm (v 0) (v 1) := (isSemiterm_defined L).df.iff v

instance isSemitermDef_definable : 𝚫₁-Relation (L.Semiterm) := Defined.to_definable _ (isSemiterm_defined L)

@[simp, definability] instance isSemitermDef_definable' (Γ) : (Γ, m + 1)-Relation (L.Semiterm) :=
  .of_deltaOne (isSemitermDef_definable L) _ _

def Language.SemitermVec (n m w : V) : Prop := n = len w ∧ ∀ i < n, L.Semiterm m (w.[i])

variable {L}

protected lemma Language.SemitermVec.lh {n m w : V} (h : L.SemitermVec n m w) : n = len w := h.1

lemma Language.SemitermVec.prop {n m w : V} (h : L.SemitermVec n m w) {i} : i < n → L.Semiterm m w.[i] := h.2 i

@[simp] lemma Language.SemitermVec.empty (m : V) : L.SemitermVec 0 m 0 := ⟨by simp, by simp⟩

@[simp] lemma Language.SemitermVec.cons {n m w t : V} (h : L.SemitermVec n m w) (ht : L.Semiterm m t) : L.SemitermVec (n + 1) m (t ∷ w) :=
  ⟨by simp [h.lh], fun i hi ↦ by
    rcases zero_or_succ i with (rfl | ⟨i, rfl⟩)
    · simpa
    · simpa using h.prop (by simpa using hi)⟩

@[simp] lemma Language.SemitermVec.cons₁_iff {m t : V} :
    L.SemitermVec 1 m ?[t] ↔ L.Semiterm m t := by
  constructor
  · intro h; simpa using h.prop (i := 0) (by simp)
  · intro h; simpa using (Language.SemitermVec.empty m).cons h

@[simp] lemma Language.SemitermVec.mkSeq₂_iff {m t₁ t₂ : V} :
    L.SemitermVec 2 m ?[t₁, t₂] ↔ L.Semiterm m t₁ ∧ L.Semiterm m t₂ := by
  constructor
  · intro h; exact ⟨by simpa using h.prop (i := 0) (by simp), by simpa using h.prop (i := 1) (by simp)⟩
  · rintro ⟨h₁, h₂⟩
    simpa [one_add_one_eq_two] using (Language.SemitermVec.cons₁_iff.mpr h₂).cons h₁

section

def _root_.LO.FirstOrder.Arith.LDef.semitermVecDef (pL : LDef) : 𝚫₁-Semisentence 3 := .mkDelta
  (.mkSigma
    “n m w | !lenDef n w ∧ ∀ i < n, ∃ u, !nthDef u w i ∧ !pL.isSemitermDef.sigma m u”
    (by simp))
  (.mkPi
    “n m w | (∀ l, !lenDef l w → n = l) ∧ ∀ i < n, ∀ u, !nthDef u w i → !pL.isSemitermDef.pi m u”
    (by simp))

variable (L)

lemma semitermVec_defined : 𝚫₁-Relation₃ L.SemitermVec via pL.semitermVecDef :=
  ⟨by intro v; simp [LDef.semitermVecDef, HSemiformula.val_sigma, eval_isSemitermDef L, (isSemiterm_defined L).proper.iff'],
   by intro v; simp [LDef.semitermVecDef, HSemiformula.val_sigma, eval_isSemitermDef L, Language.SemitermVec]⟩

@[simp] lemma eval_semitermVecDef (v) :
    Semiformula.Evalbm V v pL.semitermVecDef.val ↔ L.SemitermVec (v 0) (v 1) (v 2) := (semitermVec_defined L).df.iff v

instance semitermVecDef_definable : 𝚫₁-Relation₃ (L.SemitermVec) := Defined.to_definable _ (semitermVec_defined L)

@[simp, definability] instance semitermVecDef_definable' (Γ) : (Γ, m + 1)-Relation₃ (L.SemitermVec) :=
  .of_deltaOne (semitermVecDef_definable L) _ _

end

variable {n : V}

lemma Language.Semiterm.case_iff {t : V} :
    L.Semiterm n t ↔
    (∃ z < n, t = ^#z) ∨
    (∃ x, t = ^&x) ∨
    (∃ k f v : V, L.Func k f ∧ L.SemitermVec k n v ∧ t = ^func k f v) := by
  simpa [construction, Phi, SemitermVec, and_assoc] using (construction L).case

alias ⟨Language.Semiterm.case, Language.Semiterm.mk⟩ := Language.Semiterm.case_iff

@[simp] lemma Language.Semiterm.bvar {z : V} : L.Semiterm n ^#z ↔ z < n :=
  ⟨by intro h
      rcases h.case with (⟨z', hz, hzz'⟩ | ⟨x, h⟩ | ⟨k, f, v, _, _, h⟩)
      · rcases (show z = z' from by simpa using hzz'); exact hz
      · simp [qqBvar, qqFvar] at h
      · simp [qqBvar, qqFunc] at h,
    fun hz ↦ Language.Semiterm.mk (Or.inl ⟨z, hz, rfl⟩)⟩

@[simp] lemma Language.Semiterm.fvar (x : V) : L.Semiterm n ^&x := Language.Semiterm.mk (Or.inr <| Or.inl ⟨x, rfl⟩)

@[simp] lemma Language.Semiterm.func_iff {k f v : V} :
    L.Semiterm n (^func k f v) ↔ L.Func k f ∧ L.SemitermVec k n v :=
  ⟨by intro h
      rcases h.case with (⟨_, _, h⟩ | ⟨x, h⟩ | ⟨k', f', w, hkf, ⟨hk, hv⟩, h⟩)
      · simp [qqFunc, qqBvar] at h
      · simp [qqFunc, qqFvar] at h
      · rcases (show k = k' ∧ f = f' ∧ v = w by simpa [qqFunc] using h) with ⟨rfl, rfl, rfl⟩
        exact ⟨hkf, hk, hv⟩,
   by rintro ⟨hkf, hk, hv⟩; exact Language.Semiterm.mk (Or.inr <| Or.inr ⟨k, f, v, hkf, ⟨hk, hv⟩, rfl⟩)⟩

lemma Language.Semiterm.func {k f v : V} (hkf : L.Func k f) (hv : L.SemitermVec k n v) :
    L.Semiterm n (^func k f v) := Language.Semiterm.func_iff.mpr ⟨hkf, hv⟩

lemma Language.Semiterm.induction (Γ) {P : V → Prop} (hP : (Γ, 1)-Predicate P)
    (hbvar : ∀ z < n, P (^#z)) (hfvar : ∀ x, P (^&x))
    (hfunc : ∀ k f v, L.Func k f → L.SemitermVec k n v → (∀ i < k, P v.[i]) → P (^func k f v)) :
    ∀ t, L.Semiterm n t → P t :=
  (construction L).induction (v := ![n]) hP (by
    rintro C hC x (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, hk, h, rfl⟩)
    · exact hbvar z hz
    · exact hfvar x
    · exact hfunc k f v hkf ⟨hk, fun i hi ↦ hC _ (h i hi) |>.1⟩ (fun i hi ↦ hC _ (h i hi) |>.2))

end term

namespace Language.TermRec

structure Blueprint (pL : LDef) (arity : ℕ) where
  bvar : 𝚺₁-Semisentence (arity + 3)
  fvar : 𝚺₁-Semisentence (arity + 3)
  func : 𝚺₁-Semisentence (arity + 6)

namespace Blueprint

variable (β : Blueprint pL arity)

def blueprint : Fixpoint.Blueprint (arity + 1) := ⟨.mkDelta
  (.mkSigma “pr C n |
    ∃ t <⁺ pr, ∃ y <⁺ pr, !pairDef pr t y ∧ !pL.isSemitermDef.sigma n t ∧
    ( (∃ z < t, !qqBvarDef t z ∧ !β.bvar y n z ⋯) ∨
      (∃ x < t, !qqFvarDef t x ∧ !β.fvar y n x ⋯) ∨
      (∃ k < t, ∃ f < t, ∃ v < t, ∃ rv, !repeatVecDef rv C k ∧ ∃ w <⁺ rv,
        (!lenDef k w ∧ ∀ i < k, ∃ vi, !nthDef vi v i ∧ ∃ v'i, !nthDef v'i w i ∧ :⟪vi, v'i⟫:∈ C) ∧
        !qqFuncDef t k f v ∧ !β.func y n k f v w ⋯) )”
    (by simp))
  (.mkPi “pr C n |
    ∃ t <⁺ pr, ∃ y <⁺ pr, !pairDef pr t y ∧ !pL.isSemitermDef.pi n t ∧
    ( (∃ z < t, !qqBvarDef t z ∧ !β.bvar.graphDelta.pi y n z ⋯) ∨
      (∃ x < t, !qqFvarDef t x ∧ !β.fvar.graphDelta.pi y n x ⋯) ∨
      (∃ k < t, ∃ f < t, ∃ v < t, ∀ rv, !repeatVecDef rv C k → ∃ w <⁺ rv,
        ((∀ l, !lenDef l w → k = l) ∧ ∀ i < k, ∀ vi, !nthDef vi v i → ∀ v'i, !nthDef v'i w i → :⟪vi, v'i⟫:∈ C) ∧
        !qqFuncDef t k f v ∧ !β.func.graphDelta.pi y n k f v w ⋯) )”
    (by simp))⟩

def graph : 𝚺₁-Semisentence (arity + 3) := .mkSigma
  “n t y | ∃ pr <⁺ (t + y + 1)², !pairDef pr t y ∧ !β.blueprint.fixpointDef pr n ⋯” (by simp)

def result : 𝚺₁-Semisentence (arity + 3) := .mkSigma
  “y n t | (!pL.isSemitermDef.pi n t → !β.graph n t y ⋯) ∧ (¬!pL.isSemitermDef.sigma n t → y = 0)” (by simp)

def resultVec : 𝚺₁-Semisentence (arity + 4) := .mkSigma
  “w' k n w |
    (!pL.semitermVecDef.pi k n w → !lenDef k w' ∧ ∀ i < k, ∃ z, !nthDef z w i ∧ ∃ z', !nthDef z' w' i ∧ !β.graph.val n z z' ⋯) ∧
    (¬!pL.semitermVecDef.sigma k n w → w' = 0)” (by simp)

end Blueprint

variable (V)

structure Construction (L : Arith.Language V) {k : ℕ} (φ : Blueprint pL k) where
  bvar : (Fin k → V) → V → V → V
  fvar : (Fin k → V) → V → V → V
  func : (Fin k → V) → V → V → V → V → V → V
  bvar_defined : DefinedFunction (fun v ↦ bvar (v ·.succ.succ) (v 0) (v 1)) φ.bvar
  fvar_defined : DefinedFunction (fun v ↦ fvar (v ·.succ.succ) (v 0) (v 1)) φ.fvar
  func_defined : DefinedFunction (fun v ↦ func (v ·.succ.succ.succ.succ.succ) (v 0) (v 1) (v 2) (v 3) (v 4)) φ.func

variable {V}

namespace Construction

variable {arity : ℕ} {β : Blueprint pL arity} (c : Construction V L β)

def Phi (param : Fin arity → V) (n : V) (C : Set V) (pr : V) : Prop :=
  L.Semiterm n (π₁ pr) ∧
  ( (∃ z, pr = ⟪^#z, c.bvar param n z⟫) ∨
    (∃ x, pr = ⟪^&x, c.fvar param n x⟫) ∨
    (∃ k f v w, (k = len w ∧ ∀ i < k, ⟪v.[i], w.[i]⟫ ∈ C) ∧ pr = ⟪^func k f v, c.func param n k f v w⟫) )

lemma seq_bound {k s m : V} (Ss : Seq s) (hk : k = lh s) (hs : ∀ i z, ⟪i, z⟫ ∈ s → z < m) :
    s < exp ((k + m + 1)^2) := lt_exp_iff.mpr <| fun p hp ↦ by
  have : p < ⟪k, m⟫ := by
    simpa [hk] using
      pair_lt_pair (Ss.lt_lh_of_mem (show ⟪π₁ p, π₂ p⟫ ∈ s by simpa using hp)) (hs (π₁ p) (π₂ p) (by simpa using hp))
  exact lt_of_lt_of_le this (by simp)

private lemma phi_iff (param : Fin arity → V) (n C pr : V) :
    c.Phi param n {x | x ∈ C} pr ↔
    ∃ t ≤ pr, ∃ y ≤ pr, pr = ⟪t, y⟫ ∧ L.Semiterm n t ∧
    ( (∃ z < t, t = ^#z ∧ y = c.bvar param n z) ∨
      (∃ x < t, t = ^&x ∧ y = c.fvar param n x) ∨
      (∃ k < t, ∃ f < t, ∃ v < t, ∃ w ≤ repeatVec C k,
        (k = len w ∧ ∀ i < k, ⟪v.[i], w.[i]⟫ ∈ C) ∧
        t = ^func k f v ∧ y = c.func param n k f v w) ) := by
  constructor
  · rintro ⟨ht, H⟩
    refine ⟨π₁ pr, by simp, π₂ pr, by simp, by simp, ht, ?_⟩
    rcases H with (⟨z, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, w, ⟨hk, hw⟩, hk, rfl⟩)
    · left; exact ⟨z, by simp⟩
    · right; left; exact ⟨x, by simp⟩
    · right; right
      refine ⟨k, by simp, f, by simp, v, by simp, w, ?_, ⟨hk, hw⟩, by simp⟩
      · rcases hk; apply len_repeatVec_of_nth_le (fun i hi ↦ le_of_lt <| lt_of_mem_rng <| hw i hi)
  · rintro ⟨t, _, y, _, rfl, ht, H⟩
    refine ⟨by simpa using ht, ?_⟩
    rcases H with (⟨z, _, rfl, rfl⟩ | ⟨x, _, rfl, rfl⟩ | ⟨k, _, f, _, v, _, w, _, ⟨hk, hw⟩, rfl, rfl⟩)
    · left; exact ⟨z, rfl⟩
    · right; left; exact ⟨x, rfl⟩
    · right; right
      exact ⟨k, f, v, w, ⟨hk, fun i hi ↦ hw i hi⟩, rfl⟩

/-- TODO: move-/
@[simp] lemma cons_app_9 {n : ℕ} (a : α) (s : Fin n.succ.succ.succ.succ.succ.succ.succ.succ.succ → α) : (a :> s) 9 = s 8 := rfl

@[simp] lemma cons_app_10 {n : ℕ} (a : α) (s : Fin n.succ.succ.succ.succ.succ.succ.succ.succ.succ.succ → α) : (a :> s) 10 = s 9 := rfl

@[simp] lemma cons_app_11 {n : ℕ} (a : α) (s : Fin n.succ.succ.succ.succ.succ.succ.succ.succ.succ.succ.succ → α) : (a :> s) 11 = s 10 := rfl

def construction : Fixpoint.Construction V β.blueprint where
  Φ := fun v ↦ c.Phi (v ·.succ) (v 0)
  defined :=
  ⟨by intro v
      /-
      simp? [HSemiformula.val_sigma, Blueprint.blueprint,
        eval_isSemitermDef L, (isSemiterm_defined L).proper.iff',
        c.bvar_defined.iff, c.bvar_defined.graph_delta.proper.iff',
        c.fvar_defined.iff, c.fvar_defined.graph_delta.proper.iff',
        c.func_defined.iff, c.func_defined.graph_delta.proper.iff']
      -/
      simp only [Nat.succ_eq_add_one, Blueprint.blueprint, Nat.reduceAdd, HSemiformula.val_sigma,
        BinderNotation.finSuccItr_one, Nat.add_zero, HSemiformula.sigma_mkDelta,
        HSemiformula.val_mkSigma, Semiformula.eval_bexLTSucc', Semiterm.val_bvar,
        Matrix.cons_val_one, Matrix.vecHead, LogicalConnective.HomClass.map_and,
        Semiformula.eval_substs, Matrix.comp_vecCons', Matrix.cons_val_two, Matrix.vecTail,
        Function.comp_apply, Matrix.cons_val_succ, Matrix.cons_val_zero, Matrix.cons_val_fin_one,
        Matrix.constant_eq_singleton, pair_defined_iff, Fin.isValue, Fin.succ_zero_eq_one,
        Matrix.cons_val_four, eval_isSemitermDef L, LogicalConnective.HomClass.map_or,
        Semiformula.eval_bexLT, eval_qqBvarDef, Matrix.cons_app_five, c.bvar_defined.iff,
        LogicalConnective.Prop.and_eq, eval_qqFvarDef, c.fvar_defined.iff, Matrix.cons_val_three,
        Semiformula.eval_ex, Matrix.cons_app_seven, Matrix.cons_app_six, eval_repeatVec,
        eval_lenDef, Semiformula.eval_ballLT, eval_nthDef, Semiformula.eval_operator₃, cons_app_11,
        cons_app_10, cons_app_9, Matrix.cons_app_eight, eval_memRel, exists_eq_left, eval_qqFuncDef,
        Fin.succ_one_eq_two, c.func_defined.iff, LogicalConnective.Prop.or_eq,
        HSemiformula.pi_mkDelta, HSemiformula.val_mkPi, (isSemiterm_defined L).proper.iff',
        c.bvar_defined.graph_delta.proper.iff', HSemiformula.graphDelta_val,
        c.fvar_defined.graph_delta.proper.iff', Semiformula.eval_all,
        LogicalConnective.HomClass.map_imply, Semiformula.eval_operator₂, Structure.Eq.eq,
        LogicalConnective.Prop.arrow_eq, forall_eq, c.func_defined.graph_delta.proper.iff']
      ,
    by  intro v
        /-
        simpa? [HSemiformula.val_sigma, Blueprint.blueprint, eval_isSemitermDef L,
          c.bvar_defined.iff, c.fvar_defined.iff, c.func_defined.iff]
        using c.phi_iff _ _ _ _
        -/
        simpa only [Nat.succ_eq_add_one, BinderNotation.finSuccItr_one, Fin.succ_zero_eq_one,
          Blueprint.blueprint, Nat.reduceAdd, HSemiformula.val_sigma, Nat.add_zero,
          HSemiformula.val_mkDelta, HSemiformula.val_mkSigma, Semiformula.eval_bexLTSucc',
          Semiterm.val_bvar, Matrix.cons_val_one, Matrix.vecHead,
          LogicalConnective.HomClass.map_and, Semiformula.eval_substs, Matrix.comp_vecCons',
          Matrix.cons_val_two, Matrix.vecTail, Function.comp_apply, Matrix.cons_val_succ,
          Matrix.cons_val_zero, Matrix.cons_val_fin_one, Matrix.constant_eq_singleton,
          pair_defined_iff, Fin.isValue, Matrix.cons_val_four, eval_isSemitermDef L,
          LogicalConnective.HomClass.map_or, Semiformula.eval_bexLT, eval_qqBvarDef,
          Matrix.cons_app_five, c.bvar_defined.iff, LogicalConnective.Prop.and_eq, eval_qqFvarDef,
          c.fvar_defined.iff, Matrix.cons_val_three, Semiformula.eval_ex, Matrix.cons_app_seven,
          Matrix.cons_app_six, eval_repeatVec, eval_lenDef, Semiformula.eval_ballLT, eval_nthDef,
          Semiformula.eval_operator₃, cons_app_11, cons_app_10, cons_app_9, Matrix.cons_app_eight,
          eval_memRel, exists_eq_left, eval_qqFuncDef, Fin.succ_one_eq_two, c.func_defined.iff,
          LogicalConnective.Prop.or_eq] using c.phi_iff _ _ _ _⟩
  monotone := by
    unfold Phi
    rintro C C' hC v pr ⟨ht, H⟩
    refine ⟨ht, ?_⟩
    rcases H with (⟨z, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, w, ⟨hk, hw⟩, rfl⟩)
    · left; exact ⟨z, rfl⟩
    · right; left; exact ⟨x, rfl⟩
    · right; right; exact ⟨k, f, v, w, ⟨hk, fun i hi ↦ hC (hw i hi)⟩, rfl⟩

instance : c.construction.Finite where
  finite {C param pr h} := by
    rcases h with ⟨hp, (h | h | ⟨k, f, v, w, ⟨hk, hw⟩, rfl⟩)⟩
    · exact ⟨0, hp, Or.inl h⟩
    · exact ⟨0, hp, Or.inr <| Or.inl h⟩
    · exact ⟨⟪v, w⟫ + 1, hp, Or.inr <| Or.inr
        ⟨k, f, v, w,
          ⟨hk, fun i hi ↦ ⟨hw i hi, lt_succ_iff_le.mpr <| pair_le_pair (by simp) (by simp)⟩⟩, rfl⟩⟩

def Graph (param : Fin arity → V) (n x y : V) : Prop := c.construction.Fixpoint (n :> param) ⟪x, y⟫

variable {param : Fin arity → V} {n : V}

variable {c}

lemma Graph.case_iff {t y : V} :
    c.Graph param n t y ↔
    L.Semiterm n t ∧
    ( (∃ z, t = ^#z ∧ y = c.bvar param n z) ∨
      (∃ x, t = ^&x ∧ y = c.fvar param n x) ∨
      (∃ k f v w, (k = len w ∧ ∀ i < k, c.Graph param n v.[i] w.[i]) ∧
      t = ^func k f v ∧ y = c.func param n k f v w) ) :=
  Iff.trans c.construction.case (by apply and_congr (by simp); simp; rfl)

variable (c)

lemma graph_defined : Arith.Defined (fun v ↦ c.Graph (v ·.succ.succ.succ) (v 0) (v 1) (v 2)) β.graph := by
  intro v
  simp [Blueprint.graph, c.construction.fixpoint_defined.iff]
  constructor
  · intro h; exact ⟨⟪v 1, v 2⟫, by simp, rfl, h⟩
  · rintro ⟨_, _, rfl, h⟩; exact h

@[simp] lemma eval_graphDef (v) :
    Semiformula.Evalbm V v β.graph.val ↔ c.Graph (v ·.succ.succ.succ) (v 0) (v 1) (v 2) := (graph_defined c).df.iff v

instance termSubst_definable : Arith.Definable ℒₒᵣ 𝚺₁ (fun v ↦ c.Graph (v ·.succ.succ.succ) (v 0) (v 1) (v 2)) :=
  Defined.to_definable _ (graph_defined c)

@[simp, definability] instance termSubst_definable₂ (param n) : 𝚺₁-Relation (c.Graph param n) := by
  simpa using Definable.retractiont (n := 2) (termSubst_definable c) (&n :> #0 :> #1 :> fun i ↦ &(param i))

lemma graph_dom_isSemiterm {t y} :
    c.Graph param n t y → L.Semiterm n t := fun h ↦ Graph.case_iff.mp h |>.1

lemma graph_bvar_iff {z} (hz : z < n) :
    c.Graph param n ^#z y ↔ y = c.bvar param n z := by
  constructor
  · intro H
    rcases Graph.case_iff.mp H with ⟨_, (⟨_, h, rfl⟩ | ⟨_, h, _⟩ | ⟨_, _, _, _, _, h, _⟩)⟩
    · simp at h; rcases h; rfl
    · simp [qqBvar, qqFvar] at h
    · simp [qqBvar, qqFunc] at h
  · rintro rfl; exact Graph.case_iff.mpr ⟨by simp [hz], Or.inl ⟨z, by simp⟩⟩

lemma graph_fvar_iff (x) :
    c.Graph param n ^&x y ↔ y = c.fvar param n x := by
  constructor
  · intro H
    rcases Graph.case_iff.mp H with ⟨_, (⟨_, h, _⟩ | ⟨_, h, rfl⟩ | ⟨_, _, _, _, _, h, _⟩)⟩
    · simp [qqFvar, qqBvar] at h
    · simp [qqFvar, qqFvar] at h; rcases h; rfl
    · simp [qqFvar, qqFunc] at h
  · rintro rfl; exact Graph.case_iff.mpr ⟨by simp, Or.inr <| Or.inl ⟨x, by simp⟩⟩

lemma graph_func {n k f v w} (hkr : L.Func k f) (hv : L.SemitermVec k n v)
    (hkw : k = len w) (hw : ∀ i < k, c.Graph param n v.[i] w.[i]) :
    c.Graph param n (^func k f v) (c.func param n k f v w) := by
  exact Graph.case_iff.mpr ⟨by simp [hkr, hv], Or.inr <| Or.inr ⟨k, f, v, w, ⟨hkw, hw⟩, by simp⟩⟩

lemma graph_func_inv {n k f v y} :
    c.Graph param n (^func k f v) y → ∃ w,
      (k = len w ∧ ∀ i < k, c.Graph param n v.[i] w.[i]) ∧
      y = c.func param n k f v w := by
  intro H
  rcases Graph.case_iff.mp H with ⟨_, (⟨_, h, _⟩ | ⟨_, h, rfl⟩ | ⟨k, f, v, w, hw, h, rfl⟩)⟩
  · simp [qqFunc, qqBvar] at h
  · simp [qqFunc, qqFvar] at h
  · simp [qqFunc, qqFunc] at h; rcases h with ⟨rfl, rfl, rfl⟩
    exact ⟨w, hw, by rfl⟩

variable {c} (param n)

lemma graph_exists {t : V} : L.Semiterm n t → ∃ y, c.Graph param n t y := by
  apply Language.Semiterm.induction 𝚺 (P := fun t ↦ ∃ y, c.Graph param n t y) (by definability)
  case hbvar =>
    intro z hz; exact ⟨c.bvar param n z, by simp [c.graph_bvar_iff hz]⟩
  case hfvar =>
    intro x; exact ⟨c.fvar param n x, by simp [c.graph_fvar_iff]⟩
  case hfunc =>
    intro k f v hkf hv ih
    have : ∃ w, len w = k ∧ ∀ i < k, c.Graph param n v.[i] w.[i] := sigmaOne_skolem_vec
      (by apply Definable.comp₂ (by definability) (by definability) (c.termSubst_definable₂ param n)) ih
    rcases this with ⟨w, hwk, hvw⟩
    exact ⟨c.func param n k f v w, c.graph_func hkf hv (Eq.symm hwk) hvw⟩

lemma graph_unique {t y₁ y₂ : V} : c.Graph param n t y₁ → c.Graph param n t y₂ → y₁ = y₂ := by
  revert y₁ y₂
  suffices L.Semiterm n t → ∀ y₁ y₂, c.Graph param n t y₁ → c.Graph param n t y₂ → y₁ = y₂
  by intro u₁ u₂ h₁ h₂; exact this (c.graph_dom_isSemiterm h₁) u₁ u₂ h₁ h₂
  intro ht
  apply Language.Semiterm.induction 𝚷 ?_ ?_ ?_ ?_ t ht
  · definability
  · intro z hz; simp [c.graph_bvar_iff hz]
  · intro x; simp [c.graph_fvar_iff]
  · intro k f v _ _ ih y₁ y₂ h₁ h₂
    rcases c.graph_func_inv h₁ with ⟨w₁, ⟨hk₁, hv₁⟩, rfl⟩
    rcases c.graph_func_inv h₂ with ⟨w₂, ⟨hk₂, hv₂⟩, rfl⟩
    have : w₁ = w₂ :=
      nth_ext (by simp [←hk₁, ←hk₂]) (fun i hi ↦
        ih i (by simpa [hk₁] using hi) _ _
          (hv₁ i (by simpa [hk₁] using hi)) (hv₂ i (by simpa [hk₁] using hi)))
    rw [this]

variable (c)

lemma graph_existsUnique {t : V} (ht : L.Semiterm n t) : ∃! y, c.Graph param n t y := by
  rcases graph_exists param n ht with ⟨y, hy⟩
  exact ExistsUnique.intro y hy (fun y' h' ↦ graph_unique param n h' hy)

lemma graph_existsUnique_total (t : V) : ∃! y,
    (L.Semiterm n t → c.Graph param n t y) ∧ (¬L.Semiterm n t → y = 0) := by
  by_cases ht : L.Semiterm n t <;> simp [ht]; exact c.graph_existsUnique _ _ ht

def result (t : V) : V := Classical.choose! (c.graph_existsUnique_total param n t)

def result_prop {t : V} (ht : L.Semiterm n t) : c.Graph param n t (c.result param n t) :=
  Classical.choose!_spec (c.graph_existsUnique_total param n t) |>.1 ht

def result_prop_not {t : V} (ht : ¬L.Semiterm n t) : c.result param n t = 0 :=
  Classical.choose!_spec (c.graph_existsUnique_total param n t) |>.2 ht

variable {c param n}

lemma result_eq_of_graph {t y} (ht : L.Semiterm n t) (h : c.Graph param n t y) :
    c.result param n t = y := Eq.symm <| Classical.choose_uniq (c.graph_existsUnique_total param n t) (by simp [h, ht])

@[simp] lemma result_bvar {z} (hz : z < n) : c.result param n (^#z) = c.bvar param n z :=
  c.result_eq_of_graph (by simp [hz]) (by simp [c.graph_bvar_iff hz])

@[simp] lemma result_fvar (x) : c.result param n (^&x) = c.fvar param n x :=
  c.result_eq_of_graph (by simp) (by simp [c.graph_fvar_iff])

lemma result_func {k f v w} (hkf : L.Func k f) (hv : L.SemitermVec k n v)
    (hkw : k = len w) (hw : ∀ i < k, c.result param n v.[i] = w.[i]) :
    c.result param n (^func k f v) = c.func param n k f v w :=
  c.result_eq_of_graph (by simp [hkf, hv]) (c.graph_func hkf hv hkw (fun i hi ↦ by
    simpa [hw i hi] using c.result_prop param n (hv.prop hi)))

section vec

lemma graph_existsUnique_vec {k n w : V} (hw : L.SemitermVec k n w) :
    ∃! w' : V, k = len w' ∧ ∀ i < k, c.Graph param n w.[i] w'.[i] := by
  have : ∀ i < k, ∃ y, c.Graph param n w.[i] y := by
    intro i hi; exact ⟨c.result param n w.[i], c.result_prop param n (hw.prop hi)⟩
  rcases sigmaOne_skolem_vec
    (by apply Definable.comp₂ (by definability) (by definability) (c.termSubst_definable₂ param n)) this
    with ⟨w', hw'k, hw'⟩
  refine ExistsUnique.intro w' ⟨hw'k.symm, hw'⟩ ?_
  intro w'' ⟨hkw'', hw''⟩
  refine nth_ext (by simp [hw'k, ←hkw'']) (by
    intro i hi;
    exact c.graph_unique param n (hw'' i (by simpa [hkw''] using hi)) (hw' i (by simpa [hkw''] using hi)))

variable (c param)

lemma graph_existsUnique_vec_total (k n w : V) : ∃! w',
    (L.SemitermVec k n w → k = len w' ∧ ∀ i < k, c.Graph param n w.[i] w'.[i]) ∧
    (¬L.SemitermVec k n w → w' = 0) := by
  by_cases h : L.SemitermVec k n w <;> simp [h]; exact c.graph_existsUnique_vec h

def resultVec (k n w : V) : V := Classical.choose! (c.graph_existsUnique_vec_total param k n w)

@[simp] lemma resultVec_lh {k n w : V} (hw : L.SemitermVec k n w) : len (c.resultVec param k n w) = k :=
  Eq.symm <| Classical.choose!_spec (c.graph_existsUnique_vec_total param k n w) |>.1 hw |>.1

lemma graph_of_mem_resultVec {k n w : V} (hw : L.SemitermVec k n w) {i : V} (hi : i < k) :
    c.Graph param n w.[i] (c.resultVec param k n w).[i] :=
  Classical.choose!_spec (c.graph_existsUnique_vec_total param k n w) |>.1 hw |>.2 i hi

lemma nth_resultVec {k n w i : V} (hw : L.SemitermVec k n w) (hi : i < k) :
    (c.resultVec param k n w).[i] = c.result param n w.[i] :=
  c.result_eq_of_graph (hw.prop hi) (c.graph_of_mem_resultVec param hw hi) |>.symm

@[simp] def resultVec_of_not {k n w : V} (hw : ¬L.SemitermVec k n w) : c.resultVec param k n w = 0 :=
  Classical.choose!_spec (c.graph_existsUnique_vec_total param k n w) |>.2 hw

@[simp] lemma resultVec_nil (n : V) :
    c.resultVec param 0 n 0 = 0 := len_zero_iff_eq_nil.mp (by simp)

lemma resultVec_cons {k n w t : V} (hw : L.SemitermVec k n w) (ht : L.Semiterm n t) :
    c.resultVec param (k + 1) n (t ∷ w) = c.result param n t ∷ c.resultVec param k n w :=
  nth_ext (by simp [hw, hw.cons ht]) (by
    intro i hi
    have hi : i < k + 1 := by simpa [hw.cons ht, resultVec_lh] using hi
    rw [c.nth_resultVec param (hw.cons ht) hi]
    rcases zero_or_succ i with (rfl | ⟨i, rfl⟩)
    · simp [nth_resultVec]
    · simp [c.nth_resultVec param hw (by simpa using hi)])

end vec

variable (c)

@[simp] lemma result_func' {k f v} (hkf : L.Func k f) (hv : L.SemitermVec k n v) :
    c.result param n (^func k f v) = c.func param n k f v (c.resultVec param k n v) :=
  c.result_func hkf hv (by simp [hv]) (fun i hi ↦ c.nth_resultVec param hv hi |>.symm)

section

lemma result_defined : Arith.DefinedFunction (fun v ↦ c.result (v ·.succ.succ) (v 0) (v 1)) β.result := by
  intro v
  simp [Blueprint.result, HSemiformula.val_sigma, (isSemiterm_defined L).proper.iff',
    eval_isSemitermDef L, c.eval_graphDef, result, Classical.choose!_eq_iff]
  rfl

@[simp] lemma result_graphDef (v) :
    Semiformula.Evalbm V v β.result.val ↔ v 0 = c.result (v ·.succ.succ.succ) (v 1) (v 2) := (result_defined c).df.iff v

private lemma resultVec_graph {w' k n w} :
    w' = c.resultVec param k n w ↔
    ( (L.SemitermVec k n w → k = len w' ∧ ∀ i < k, c.Graph param n w.[i] w'.[i]) ∧
      (¬L.SemitermVec k n w → w' = 0) ) :=
  Classical.choose!_eq_iff (c.graph_existsUnique_vec_total param k n w)

lemma resultVec_defined : Arith.DefinedFunction (fun v ↦ c.resultVec (v ·.succ.succ.succ) (v 0) (v 1) (v 2)) β.resultVec := by
  intro v
  simpa [Blueprint.resultVec, HSemiformula.val_sigma, (semitermVec_defined L).proper.iff',
    eval_semitermVecDef L, c.eval_graphDef] using c.resultVec_graph

lemma eval_resultVec (v : Fin (arity + 4) → V) :
    Semiformula.Evalbm V v β.resultVec.val ↔
    v 0 = c.resultVec (v ·.succ.succ.succ.succ) (v 1) (v 2) (v 3) := c.resultVec_defined.df.iff v

end

end Construction

end Language.TermRec

end LO.Arith

end
