import Arithmetization.ISigmaOne.Metamath.Language

noncomputable section

namespace LO.FirstOrder.Arith.Model

variable {M : Type*} [Zero M] [One M] [Add M] [Mul M] [LT M] [M ⊧ₘ* 𝐈𝚺₁]

namespace FormalizedTerm

variable {L : Model.Language M} {pL : LDef} [Model.Language.Defined L pL]

section bvarSet

abbrev qqBvar (z : M) : M := ⟪0, z⟫ + 1

scoped prefix:max "^#" => qqBvar

lemma bvarSet_existsUnique (n s : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔ x ≤ s ∧ ∃ z < n, x = ^#z) := by
  have : 𝚺₁-Predicate fun x ↦ x ≤ s ∧ ∃ z < n, x = ^#z := by definability
  exact finite_comprehension₁! this
    ⟨s + 1, fun i ↦ by rintro ⟨hi, _⟩; exact lt_succ_iff_le.mpr hi⟩

def bvarSet (n s : M) : M := Classical.choose! (bvarSet_existsUnique n s)

lemma mem_bvarSet_iff {s n : M} :
    x ∈ bvarSet n s ↔ x ≤ s ∧ ∃ z < n, x = ^#z := Classical.choose!_spec (bvarSet_existsUnique n s) x

private lemma bvarSet_graph {u n s : M} :
    u = bvarSet n s ↔ ∀ x < u + (s + 1), x ∈ u ↔ x ≤ s ∧ ∃ z < n, ∃ x' < x, x = x' + 1 ∧ x' = ⟪0, z⟫ :=
  ⟨by rintro rfl x _; simp [mem_bvarSet_iff]
      intro hx; constructor
      · rintro ⟨z, hz, rfl⟩; exact ⟨z, hz, by simp, rfl⟩
      · rintro ⟨z, hz, _, rfl⟩; exact ⟨z, hz, rfl⟩,
   by intro h; apply mem_ext
      intro x; constructor
      · intro hx
        exact mem_bvarSet_iff.mpr (by
          rcases h x (lt_of_lt_of_le (lt_of_mem hx) le_self_add) |>.mp hx with ⟨hx, z, hz, _, _, rfl, rfl⟩
          exact ⟨hx, z, hz, rfl⟩)
      · intro hx
        exact h x (lt_of_lt_of_le (le_iff_lt_succ.mp (mem_bvarSet_iff.mp hx).1) le_add_self)|>.mpr (by
          rcases mem_bvarSet_iff.mp hx with ⟨hx, z, hz, rfl⟩
          exact ⟨hx, z, hz, ⟪0, z⟫, by simp, rfl, rfl⟩)⟩

def bvarSetDef : 𝚺₀-Semisentence 3 := .mkSigma
  “u n s | ∀ x < u + (s + 1), x ∈ u ↔ x ≤ s ∧ ∃ z < n, ∃ x' < x, x = x' + 1 ∧ !pairDef x' 0 z” (by simp)

lemma bvarSet_defined : 𝚺₀-Function₂ (bvarSet : M → M → M) via bvarSetDef := by
  intro v; simp [bvarSetDef, bvarSet_graph]

@[simp] lemma eval_bvarSetDef (v) :
    Semiformula.Evalbm M v bvarSetDef.val ↔ v 0 = bvarSet (v 1) (v 2) := bvarSet_defined.df.iff v

lemma mem_bvarSet {z n s : M} (hz : z < n) (h : ^#z ≤ s) : ^#z ∈ bvarSet n s := mem_bvarSet_iff.mpr ⟨h, z, hz, rfl⟩

end bvarSet

section fvarSet

abbrev qqFvar (x : M) : M := ⟪1, x⟫ + 1

scoped prefix:max "^&" => qqFvar

lemma fvarSet_existsUnique (s : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔ x ≤ s ∧ ∃ z < s, x = ^&z) := by
  have : 𝚺₁-Predicate fun x ↦ x ≤ s ∧ ∃ z < s, x = ^&z := by definability
  exact finite_comprehension₁! this
    ⟨s + 1, fun i ↦ by rintro ⟨hi, _⟩; exact lt_succ_iff_le.mpr hi⟩

def fvarSet (s : M) : M := Classical.choose! (fvarSet_existsUnique s)

lemma mem_fvarSet_iff' {s : M} :
    x ∈ fvarSet s ↔ x ≤ s ∧ ∃ z < s, x = ^&z := Classical.choose!_spec (fvarSet_existsUnique s) x

lemma mem_fvarSet_iff {s : M} :
    x ∈ fvarSet s ↔ x ≤ s ∧ ∃ z, x = ^&z := by
  simp [mem_fvarSet_iff']; intro hx;
  constructor
  · rintro ⟨z, _, rfl⟩; exact ⟨z, rfl⟩
  · rintro ⟨z, rfl⟩; exact ⟨z, lt_of_lt_of_le (lt_succ_iff_le.mpr (le_pair_right 1 z)) hx, rfl⟩

private lemma fvarSet_graph {u s : M} :
    u = fvarSet s ↔ ∀ x < u + (s + 1), x ∈ u ↔ x ≤ s ∧ ∃ z < s, ∃ x' < x, x = x' + 1 ∧ x' = ⟪1, z⟫ :=
  ⟨by rintro rfl x _; simp [mem_fvarSet_iff']
      intro hx; constructor
      · rintro ⟨z, hz, rfl⟩; exact ⟨z, hz, by simp, rfl⟩
      · rintro ⟨z, hz, _, rfl⟩; exact ⟨z, hz, rfl⟩,
   by intro h; apply mem_ext
      intro x; constructor
      · intro hx
        exact mem_fvarSet_iff'.mpr (by
          rcases h x (lt_of_lt_of_le (lt_of_mem hx) le_self_add) |>.mp hx with ⟨hx, z, hz, _, _, rfl, rfl⟩
          exact ⟨hx, z, hz, rfl⟩)
      · intro hx
        exact h x (lt_of_lt_of_le (le_iff_lt_succ.mp (mem_fvarSet_iff'.mp hx).1) le_add_self)|>.mpr (by
          rcases mem_fvarSet_iff'.mp hx with ⟨hx, z, hz, rfl⟩
          exact ⟨hx, z, hz, ⟪1, z⟫, by simp, rfl, rfl⟩)⟩

def fvarSetDef : 𝚺₀-Semisentence 2 := .mkSigma
  “u s | ∀ x < u + (s + 1), x ∈ u ↔ x ≤ s ∧ ∃ z < s, ∃ x' < x, x = x' + 1 ∧ !pairDef x' 1 z” (by simp)

lemma fvarSet_defined : 𝚺₀-Function₁ (fvarSet : M → M) via fvarSetDef := by
  intro v; simp [fvarSetDef, fvarSet_graph]

@[simp] lemma eval_fvarSetDef (v) :
    Semiformula.Evalbm M v fvarSetDef.val ↔ v 0 = fvarSet (v 1) := fvarSet_defined.df.iff v

lemma mem_fvarSet {z s : M} (h : ^&z ≤ s) : ^&z ∈ fvarSet s :=
  mem_fvarSet_iff.mpr ⟨h, z, rfl⟩

end fvarSet

section funcSet

abbrev qqFunc (k f v : M) : M := ⟪2, ⟪k, ⟪f, v⟫⟫⟫ + 1

scoped prefix:max "^func " => qqFunc

variable (L pL)

lemma funcSet_existsUnique (ih s : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔
      x ≤ s ∧
      ∃ k < s, ∃ f < s, ∃ v < s,
        L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i < v, ∀ b < v, ⟪i, b⟫ ∈ v → b ∈ ih) ∧ x = ^func k f v) := by
  have : 𝚺₁-Predicate fun x ↦ x ≤ s ∧
      ∃ k < s, ∃ f < s, ∃ v < s,
        L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i < v, ∀ b < v, ⟪i, b⟫ ∈ v → b ∈ ih) ∧ x = ^func k f v := by definability
  exact finite_comprehension₁! this
    ⟨s + 1, fun i ↦ by rintro ⟨hi, _⟩; exact lt_succ_iff_le.mpr hi⟩

def funcSet (ih s : M) : M := Classical.choose! (funcSet_existsUnique L pL ih s)

variable {L pL}

lemma mem_funcSet_iff' {s : M} :
    x ∈ funcSet L pL ih s ↔
    x ≤ s ∧
    ∃ k < s, ∃ f < s, ∃ v < s,
      L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i < v, ∀ b < v, ⟪i, b⟫ ∈ v → b ∈ ih) ∧ x = ^func k f v :=
  Classical.choose!_spec (funcSet_existsUnique L pL ih s) x

@[simp] lemma arity_lt_qqFunc (k f v : M) : k < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right 2 k) <| pair_le_pair_right 2 <| le_pair_left k ⟪f, v⟫

@[simp] lemma func_lt_qqFunc (k f v : M) : f < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_left f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

@[simp] lemma terms_lt_qqFunc (k f v : M) : v < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

lemma lt_qqFunc {i b k f v : M} (hi : ⟪i, b⟫ ∈ v) : b < ^func k f v :=
  _root_.lt_trans (lt_of_mem_rng hi) (terms_lt_qqFunc k f v)

lemma mem_funcSet_iff {ih s : M} :
    x ∈ funcSet L pL ih s ↔
    x ≤ s ∧ ∃ k f v, L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i b, ⟪i, b⟫ ∈ v → b ∈ ih) ∧ x = ^func k f v := by
  simp only [mem_funcSet_iff', and_congr_right_iff]; intro hx
  constructor
  · rintro ⟨k, _, f, _, v, _, hkf, Hv, rfl, hih, rfl⟩
    exact ⟨lh v, f, v, hkf, Hv, rfl, fun i b hib ↦ hih i (lt_of_mem_dom hib) b (lt_of_mem_rng hib) hib, rfl⟩
  · rintro ⟨k, f, v, hkf, Hv, rfl, hih, rfl⟩
    exact ⟨lh v, lt_of_lt_of_le (arity_lt_qqFunc (lh v) f v) hx,
      f, lt_of_lt_of_le (func_lt_qqFunc (lh v) f v) hx,
      v, lt_of_lt_of_le (terms_lt_qqFunc (lh v) f v) hx,
      hkf, Hv, rfl, fun i _  b _ hib ↦ hih i b hib, rfl⟩

section

private lemma qqFunc_graph {x k f v : M} :
    x = ^func k f v ↔ ∃ fv < x, fv = ⟪f, v⟫ ∧ ∃ kfv < x, kfv = ⟪k, fv⟫ ∧ ∃ x' < x, x' = ⟪2, kfv⟫ ∧ x = x' + 1 :=
  ⟨by rintro rfl
      exact ⟨⟪f, v⟫, lt_succ_iff_le.mpr <| le_trans (le_pair_right _ _) (le_pair_right _ _), rfl,
        ⟪k, ⟪f, v⟫⟫, lt_succ_iff_le.mpr <| by simp, rfl,
        ⟪2, ⟪k, ⟪f, v⟫⟫⟫, by simp, rfl, rfl⟩,
   by rintro ⟨_, _, rfl, _, _, rfl, _, _, rfl, rfl⟩; rfl⟩

def qqFuncDef : 𝚺₀-Semisentence 4 := .mkSigma
  “x k f v | ∃ fv < x, !pairDef fv f v ∧ ∃ kfv < x, !pairDef kfv k fv ∧ ∃ x' < x, !pairDef x' 2 kfv ∧ x = x' + 1” (by simp)

lemma qqFunc_defined : 𝚺₀-Function₃ (qqFunc : M → M → M → M) via qqFuncDef := by
  intro v; simp [qqFuncDef, qqFunc_graph]

@[simp] lemma eval_qqFuncDef (v) :
    Semiformula.Evalbm M v qqFuncDef.val ↔ v 0 = ^func (v 1) (v 2) (v 3) := qqFunc_defined.df.iff v

end

section

private lemma funcSet_graph {u ih s : M} :
    u = funcSet L pL ih s ↔ ∀ x < u + (s + 1),
      x ∈ u ↔ x ≤ s ∧
        ∃ k < s, ∃ f < s, ∃ v < s,
          L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i < v, ∀ b < v, ⟪i, b⟫ ∈ v → b ∈ ih) ∧ x = ^func k f v :=
  ⟨by rintro rfl x _; simp [mem_funcSet_iff'],
   by intro H; apply mem_ext; intro x
      constructor
      · intro hx; exact mem_funcSet_iff'.mpr <| H x (lt_of_lt_of_le (lt_of_mem hx) (by simp)) |>.mp hx
      · intro hx
        exact H x (lt_of_lt_of_le (le_iff_lt_succ.mp (mem_funcSet_iff'.mp hx).1) (by simp)) |>.mpr
          (mem_funcSet_iff'.mp hx)⟩

variable (L pL)

def funcSetDef : 𝚺₀-Semisentence 3 := .mkSigma
  “u ih s |
    ∀ x < u + (s + 1),
      x ∈ u ↔ x ≤ s ∧
        ∃ k < s, ∃ f < s, ∃ v < s,
          !pL.func k f ∧ :Seq v ∧ !lhDef k v ∧ (∀ i < v, ∀ b < v, i ~[v] b → b ∈ ih) ∧ !qqFuncDef x k f v”
  (by simp)

/-- TODO: move to Vorspiel. -/
@[simp] lemma cons_app_seven {n : ℕ} (a : α) (s : Fin n.succ.succ.succ.succ.succ.succ.succ → α) : (a :> s) 7 = s 6 := rfl

lemma funcSet_defined : 𝚺₀-Function₂ (funcSet L pL) via (funcSetDef pL) := by
  intro v; simp [funcSetDef, funcSet_graph, Language.Defined.eval_func (L := L) (pL := pL)]

@[simp] lemma eval_funcSetDef (v) :
    Semiformula.Evalbm M v (funcSetDef pL).val ↔ v 0 = funcSet L pL (v 1) (v 2) := (funcSet_defined L pL).df.iff v

variable {L pL}

end

end funcSet

variable (L pL)

def succGen (ih s n : M) : M := bvarSet n s ∪ fvarSet s ∪ funcSet L pL ih s

section

private lemma succGen_graph {u ih n s : M} :
    u = succGen L pL ih s n ↔
    ∃ bv ≤ u, bv = bvarSet n s ∧ ∃ fv ≤ u, fv = fvarSet s ∧ ∃ fc ≤ u, fc = funcSet L pL ih s ∧
      ∃ u' ≤ u, u' = bv ∪ fv ∧ u = u' ∪ fc :=
  ⟨by rintro rfl
      exact ⟨_, le_of_subset <| by simp [succGen], rfl, _, le_of_subset <| by simp [succGen], rfl,
        _, le_of_subset <| by simp [succGen], rfl, _, le_of_subset <| by simp [succGen], rfl,
        rfl⟩,
   by  rintro ⟨_, _, rfl, _, _, rfl, _, _, rfl, _, _, rfl, rfl⟩; rfl⟩

def succGenDef : 𝚺₀-Semisentence 4 := .mkSigma
  “u ih s n |
    ∃ bv <⁺ u, !bvarSetDef bv n s ∧ ∃ fv <⁺ u, !fvarSetDef fv s ∧ ∃ fc <⁺ u, !(funcSetDef pL) fc ih s ∧
      ∃ u' <⁺ u, !unionDef u' bv fv ∧ !unionDef u u' fc”
  (by simp)

lemma succGen_defined : 𝚺₀-Function₃ (succGen L pL) via (succGenDef pL) := by
  intro v; simp [succGenDef, succGen_graph, eval_funcSetDef L pL]

@[simp] lemma eval_succGenDef (v) :
    Semiformula.Evalbm M v (succGenDef pL).val ↔ v 0 = succGen L pL (v 1) (v 2) (v 3) := (succGen_defined L pL).df.iff v

end

def defFormulae : PR.Formulae 1 where
  zero := .mkSigma “y x | y = 0” (by simp)
  succ := .ofZero (succGenDef pL) _

def construction : PR.Construction M (defFormulae pL) where
  zero := fun _ ↦ ∅
  succ := fun n s ih ↦ succGen L pL ih s (n 0)
  zero_defined := by intro v; simp [defFormulae, emptyset_def]
  succ_defined := by intro v; simp [defFormulae, eval_succGenDef L pL]; rfl

def termSet (n s : M) : M := (construction L pL).result ![n] s

@[simp] lemma termSet_zero (n : M) : termSet L pL n 0 = ∅ := by simp [termSet, construction]

lemma termSet_succ (n : M) :
    termSet L pL n (s + 1) = bvarSet n s ∪ fvarSet s ∪ funcSet L pL (termSet L pL n s) s := by simp [termSet, construction]; rfl

def _root_.LO.FirstOrder.Arith.LDef.termSetDef : 𝚺₁-Semisentence 3 := (defFormulae pL).resultDef |>.rew (Rew.substs ![#0, #2, #1])

lemma termSet_defined : 𝚺₁-Function₂ (termSet L pL : M → M → M) via pL.termSetDef :=
  fun v ↦ by simp [(construction L pL).result_defined_iff, LDef.termSetDef]; rfl

@[simp] lemma termSet_defined_iff (v) :
    Semiformula.Evalbm M v pL.termSetDef.val ↔ v 0 = termSet L pL (v 1) (v 2) := (termSet_defined L pL).df.iff v

instance termSet_definable : 𝚺₁-Function₂ (termSet L pL : M → M → M) := Defined.to_definable _ (termSet_defined L pL)

@[simp, definability] instance termSet_definable' (Γ) : (Γ, m + 1)-Function₂ (termSet L pL : M → M → M) :=
  .of_sigmaOne (termSet_definable L pL) _ _

variable {L pL} {n : M}

local prefix:max "𝐓" => termSet L pL n

/-- TODO: move to Vorspiel -/
lemma _root_.and_or_distrib_left (P Q R : Prop) : P ∧ (Q ∨ R) ↔ (P ∧ Q) ∨ (P ∧ R) :=
  ⟨by rintro ⟨hp, (hq | hr)⟩ <;> simp [*], by rintro (⟨hp, hq⟩ | ⟨hp, hr⟩) <;> simp [*]⟩

lemma mem_termSet_succ_iff {t s : M} :
    t ∈ 𝐓 (s + 1) ↔ t ≤ s ∧
      ( (∃ z < n, t = ^#z) ∨
        (∃ x, t = ^&x) ∨
        (∃ k f v, L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i b, ⟪i, b⟫ ∈ v → b ∈ 𝐓 s) ∧ t = ^func k f v) ) := by
  simp [termSet_succ, mem_bvarSet_iff, mem_fvarSet_iff, mem_funcSet_iff, ← and_or_distrib_left, or_assoc]

lemma bvar_mem_termSet {z : M} (hz : z < n) (h : ^#z ≤ s) : ^#z ∈ 𝐓 (s + 1) :=
  mem_termSet_succ_iff.mpr ⟨h, Or.inl ⟨z, hz, rfl⟩⟩

lemma fvar_mem_termSet {x : M} (h : ^&x ≤ s) : ^&x ∈ 𝐓 (s + 1) :=
  mem_termSet_succ_iff.mpr ⟨h, Or.inr <| Or.inl ⟨x, rfl⟩⟩

lemma func_mem_termSet {k f v : M} (h : ^func k f v ≤ s)
    (hkf : L.Func k f) (Hv : Seq v) (hlh : k = lh v) (ih : ∀ i b, ⟪i, b⟫ ∈ v → b ∈ 𝐓 s) : ^func k f v ∈ 𝐓 (s + 1) :=
  mem_termSet_succ_iff.mpr ⟨h, Or.inr <| Or.inr <| ⟨k, f, v, hkf, Hv, hlh, ih, rfl⟩⟩

lemma termSet_cumulative {s s' : M} : s ≤ s' → 𝐓 s ⊆ 𝐓 s' := by
  induction s' using induction_iSigmaOne generalizing s
  · definability
  case zero =>
    simp; rintro rfl; simp
  case succ s' ih =>
    intro hs u hu
    rcases zero_or_succ s with (rfl | ⟨s, rfl⟩)
    · simp at hu
    have hs : s ≤ s' := by simpa using hs
    rcases (mem_termSet_succ_iff.mp hu) with ⟨hu, (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Hv, rfl, hv, rfl⟩)⟩
    · exact bvar_mem_termSet hz (le_trans hu hs)
    · exact fvar_mem_termSet (le_trans hu hs)
    · exact func_mem_termSet (le_trans hu hs) hkf Hv rfl (fun i b hib ↦ ih hs (hv i b hib))

lemma mem_termSet_self {u s : M} :
    u ∈ 𝐓 s → u ∈ 𝐓 (u + 1) := by
  induction u using order_induction_piOne generalizing s
  · definability
  case ind u ih =>
    rcases zero_or_succ s with (rfl | ⟨s, rfl⟩)
    · simp
    intro hu
    rcases mem_termSet_succ_iff.mp hu with ⟨hu, (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Hv, rfl, hv, rfl⟩)⟩
    · exact bvar_mem_termSet hz (by rfl)
    · exact fvar_mem_termSet (by rfl)
    · have : ∀ i b, ⟪i, b⟫ ∈ v → b ∈ 𝐓 (^func (lh v) f v) := fun i b hi ↦ by
        have : b ∈ 𝐓 (b + 1) := ih b (lt_qqFunc hi) (hv i b hi)
        exact termSet_cumulative (lt_iff_succ_le.mp <| lt_qqFunc hi) this
      exact func_mem_termSet (by rfl) hkf Hv rfl this

end FormalizedTerm

section

open FormalizedTerm

variable (L : Model.Language M) (pL : LDef) [Model.Language.Defined L pL] {n : M}

def IsSemiterm (n x : M) : Prop := ∃ s, x ∈ FormalizedTerm.termSet L pL n s

abbrev IsTerm (x : M) : Prop := IsSemiterm L pL 0 x

local prefix:max "𝐓" => termSet L pL n

local prefix:max "𝗧ⁿ" => IsSemiterm L pL n

variable {L pL}

lemma isSemiterm_iff {x : M} : IsSemiterm L pL n x ↔ x ∈ 𝐓 (x + 1) :=
  ⟨by rintro ⟨s, hs⟩; exact mem_termSet_self hs, fun h ↦ ⟨x + 1, h⟩⟩

variable (L pL)

section stx

def _root_.LO.FirstOrder.Arith.LDef.isSemitermDef : 𝚫₁-Semisentence 2 := .mkDelta
  (.mkSigma “n x | ∃ T, !pL.termSetDef T n (x + 1) ∧ x ∈ T” (by simp))
  (.mkPi “n x | ∀ T, !pL.termSetDef T n (x + 1) → x ∈ T” (by simp))

lemma isSemiterm_defined : 𝚫₁-Relation (IsSemiterm L pL) via pL.isSemitermDef :=
  ⟨by intro v; simp [LDef.isSemitermDef, termSet_defined_iff L pL],
   by intro v; simp [isSemiterm_iff, LDef.isSemitermDef, termSet_defined_iff L pL]⟩

@[simp] lemma eval_isSemiterm (v) :
    Semiformula.Evalbm M v pL.isSemitermDef.val ↔ IsSemiterm L pL (v 0) (v 1) := (isSemiterm_defined L pL).df.iff v

instance isSemiterm_definable : 𝚫₁-Relation (IsSemiterm L pL) := Defined.to_definable _ (isSemiterm_defined L pL)

@[simp, definability] instance isSemiterm_definable' (Γ) : (Γ, m + 1)-Relation (IsSemiterm L pL) :=
  .of_deltaOne (isSemiterm_definable L pL) _ _

def _root_.LO.FirstOrder.Arith.LDef.isTermDef : 𝚫₁-Semisentence 1 := pL.isSemitermDef.rew (Rew.substs ![‘0’, ‘y n x | x’])

lemma isTerm_defined : 𝚫₁-Predicate (IsTerm L pL) via pL.isTermDef :=
  ⟨by simp [LDef.isTermDef]; apply HSemiformula.ProperOn.rew ((isSemiterm_defined L pL).proper),
   by intro v; simp [LDef.isTermDef, eval_isSemiterm L pL, IsTerm]⟩

@[simp] lemma eval_isTerm (v) :
    Semiformula.Evalbm M v pL.isTermDef.val ↔ IsTerm L pL (v 0) := (isTerm_defined L pL).df.iff v

instance isTerm_definable : 𝚫₁-Predicate (IsTerm L pL) := Defined.to_definable _ (isTerm_defined L pL)

@[simp, definability] instance isTerm_definable' (Γ) : (Γ, m + 1)-Predicate (IsTerm L pL) :=
  .of_deltaOne (isTerm_definable L pL) _ _

end stx

variable {L pL}

lemma IsSemiterm.bvar {z : M} (hz : z < n) : 𝗧ⁿ ^#z := ⟨^#z + 1, bvar_mem_termSet hz (by rfl)⟩

lemma IsSemiterm.fvar (x : M) : 𝗧ⁿ ^&x := ⟨^&x + 1, fvar_mem_termSet (by rfl)⟩

lemma IsSemiterm.func {k f v : M} (hkf : L.Func k f) (Hv : Seq v) (hlh : k = lh v) (ih : ∀ i b, ⟪i, b⟫ ∈ v → 𝗧ⁿ b) :
    𝗧ⁿ (^func k f v) :=
  ⟨^func k f v + 1,
    func_mem_termSet (by rfl) hkf Hv hlh (fun i b hi ↦
      termSet_cumulative (lt_iff_succ_le.mp <| lt_qqFunc hi) (isSemiterm_iff.mp (ih i b hi)))⟩

lemma IsSemiterm.cases {t : M} :
    𝗧ⁿ t ↔
    (∃ z < n, t = ^#z) ∨
    (∃ x, t = ^&x) ∨
    (∃ k f v, L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i u, ⟪i, u⟫ ∈ v → 𝗧ⁿ u) ∧ t = ^func k f v) where
  mp := by
    intro h
    rcases mem_termSet_succ_iff.mp (isSemiterm_iff.mp h) with ⟨_, (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Hv, rfl, hv, _, rfl⟩)⟩
    · left; exact ⟨z, hz, rfl⟩
    · right; left; exact ⟨x, rfl⟩
    · right; right
      exact ⟨lh v, f, v, hkf, Hv, rfl, fun i u hi ↦ ⟨_, hv i u hi⟩, rfl⟩
  mpr := by
    rintro (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Hv, rfl, h, rfl⟩)
    · exact IsSemiterm.bvar hz
    · exact IsSemiterm.fvar x
    · exact IsSemiterm.func hkf Hv rfl h

lemma IsSemiterm.induction {Γ} {P : M → Prop} (hP : DefinablePred ℒₒᵣ (Γ, 1) P)
    (hbvar : ∀ z < n, P (^#z)) (hfvar : ∀ x, P (^&x))
    (hfunc : ∀ k f v, L.Func k f → Seq v → k = lh v → (∀ i b, ⟪i, b⟫ ∈ v → 𝗧ⁿ b → P b) → P (^func k f v)) :
    ∀ t, 𝗧ⁿ t → P t := by
  apply @order_induction_hh M _ _ _ _ _ _ ℒₒᵣ _ _ _ _ Γ 1 _
  · exact Definable.imp (Definable.comp₂' (by simp) (by simp)) (Definable.comp₁' (by simp))
  intro t ih ht
  rcases IsSemiterm.cases.mp ht with (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Hv, rfl, _, rfl⟩)
  · exact hbvar z hz
  · exact hfvar x
  · exact hfunc (lh v) f v hkf Hv rfl (fun i u hi ↦ ih u (lt_qqFunc hi))

end

end LO.FirstOrder.Arith.Model

end