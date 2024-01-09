import Arithmetization.PAminus

namespace LO.FirstOrder

namespace Arith

namespace Theory

variable {L : Language} [L.ORing] {C C' : {n : ℕ} → (Semiformula L (Fin n) 1 → Prop)}

lemma mem_IndScheme_of_mem {p : Semiformula L (Fin n) 1} (hp : C p) :
    ∀ᵤ* succInd p ∈ IndScheme C := by
  simp[IndScheme, Formula.univClosure, Semiformula.univClosure_inj]
  exact ⟨n, p, hp, rfl⟩

lemma mem_Iopen_of_qfree {p : Semiformula L (Fin n) 1} (hp : p.Open) :
    ∀ᵤ* succInd p ∈ IOpen L := by
  simp[IndScheme, Formula.univClosure, Semiformula.univClosure_inj]
  exact ⟨n, p, hp, rfl⟩

lemma IndScheme_subset (h : ∀ {n} {p : Semiformula L (Fin n) 1},  C p → C' p) : IndScheme C ⊆ IndScheme C' := by
  intro _; simp [IndScheme]; rintro n p hp rfl; exact ⟨n, p, h hp, rfl⟩

abbrev ISigma₀ (L : Language) [L.ORing] := ISigma L 0

notation "𝐈𝚺₀" => ISigma₀ ℒₒᵣ

abbrev ISigma₁ (L : Language) [L.ORing] := ISigma L 1

notation "𝐈𝚺₁" => ISigma₁ ℒₒᵣ

end Theory

noncomputable section

variable {M : Type} [Inhabited M] [DecidableEq M] [ORingSymbol M]
  [Structure ℒₒᵣ M] [Structure.ORing ℒₒᵣ M]
  [𝐏𝐀⁻.Mod M]

namespace Model

section IndScheme

variable {C : {n : ℕ} → Set (Semiformula ℒₒᵣ (Fin n) 1)}
  [(Theory.IndScheme C).Mod M]

lemma induction_eval {n} {p : Semiformula ℒₒᵣ (Fin n) 1} (hp : p ∈ C) (v) :
    Semiformula.Eval! M ![0] v p →
    (∀ x, Semiformula.Eval! M ![x] v p → Semiformula.Eval! M ![x + 1] v p) →
    ∀ x, Semiformula.Eval! M ![x] v p := by
  have : M ⊧ₘ (∀ᵤ* succInd p) :=
    Theory.Mod.models (T := Theory.IndScheme C) M (by simpa [Theory.IOpen] using Theory.mem_IndScheme_of_mem hp)
  simp [models_iff, succInd, Semiformula.eval_substs, Semiformula.eval_rew_q Rew.toS, Function.comp, Matrix.constant_eq_singleton] at this
  exact this v

lemma induction {n} (P : (Fin n → M) → M → Prop) (hP : ∃ p ∈ @C n, ∀ v x, P v x ↔ Semiformula.Eval! M ![x] v p) (v) :
    P v 0 → (∀ x, P v x → P v (x + 1)) → ∀ x, P v x := by
  rcases hP with ⟨p, Cp, hp⟩; simpa [hp] using induction_eval Cp v

lemma induction₀ {P : M → Prop}
    (hP : ∃ p ∈ @C 0, ∀ x, P x ↔ Semiformula.Eval! M ![x] ![] p) :
    P 0 → (∀ x, P x → P (x + 1)) → ∀ x, P x := by
  rcases hP with ⟨p, Cp, hp⟩
  exact induction (C := C) (n := 0) (fun _ x ↦ P x) ⟨p, Cp, fun _ x ↦ by simpa [Matrix.empty_eq] using hp x ⟩ ![]

lemma induction₁ {P : M → M → Prop}
    (hP : ∃ p ∈ @C 1, ∀ x a, P a x ↔ Semiformula.Eval! M ![x] ![a] p) (a) :
    P a 0 → (∀ x, P a x → P a (x + 1)) → ∀ x, P a x := by
  rcases hP with ⟨p, Cp, hp⟩
  exact induction (C := C) (n := 1) (fun v x ↦ P (v 0) x)
    ⟨p, Cp, fun v x ↦ by simpa [Matrix.constant_eq_singleton, ←Matrix.constant_eq_singleton'] using hp x (v 0) ⟩ ![a]

lemma induction₂ {P : M → M → M → Prop}
    (hP : ∃ p ∈ @C 2, ∀ x a b, P a b x ↔ Semiformula.Eval! M ![x] ![a, b] p) (a b) :
    P a b 0 → (∀ x, P a b x → P a b (x + 1)) → ∀ x, P a b x := by
  rcases hP with ⟨p, Cp, hp⟩
  exact induction (C := C) (n := 2) (fun v x ↦ P (v 0) (v 1) x)
    ⟨p, Cp, fun v x ↦ by simpa [Matrix.constant_eq_singleton, ←Matrix.fun_eq_vec₂] using hp x (v 0) (v 1) ⟩ ![a, b]

lemma induction₃ {P : M → M → M → M → Prop}
    (hP : ∃ p ∈ @C 3, ∀ x a b c, P a b c x ↔ Semiformula.Eval! M ![x] ![a, b, c] p) (a b c) :
    P a b c 0 → (∀ x, P a b c x → P a b c (x + 1)) → ∀ x, P a b c x := by
  rcases hP with ⟨p, Cp, hp⟩
  exact induction (C := C) (n := 3) (fun v x ↦ P (v 0) (v 1) (v 2) x)
    ⟨p, Cp, fun v x ↦ by simpa [Matrix.constant_eq_singleton, ←Matrix.fun_eq_vec₃] using hp x (v 0) (v 1) (v 2)⟩ ![a, b, c]

end IndScheme

section IOpen

variable [𝐈open.Mod M]

lemma open_induction₁ {P : M → M → Prop}
    (hP : ∃ p : Semiformula ℒₒᵣ (Fin 1) 1, p.Open ∧ ∀ x a, P a x ↔ Semiformula.Eval! M ![x] ![a] p) (a) :
    P a 0 → (∀ x, P a x → P a (x + 1)) → ∀ x, P a x :=
  induction₁ (C := Semiformula.Open) (by simpa) a

lemma open_induction₂ {P : M → M → M → Prop}
    (hP : ∃ p : Semiformula ℒₒᵣ (Fin 2) 1, p.Open ∧ (∀ x a b, P a b x ↔ Semiformula.Eval! M ![x] ![a, b] p)) (a b) :
    P a b 0 → (∀ x, P a b x → P a b (x + 1)) → ∀ x, P a b x :=
  induction₂ (C := Semiformula.Open) (by simpa) a b

lemma open_leastNumber₁ {P : M → M → Prop}
    (hP : ∃ p : Semiformula ℒₒᵣ (Fin 1) 1, p.Open ∧ (∀ x a, P a x ↔ Semiformula.Eval! M ![x] ![a] p)) (a x) :
    P a 0 → ¬P a x → ∃ x, P a x ∧ ¬P a (x + 1) := fun h0 hx ↦ by
  simpa using (not_imp_not.mpr <| open_induction₁ hP a h0) (by simp; exact ⟨x, hx⟩)

lemma open_leastNumber₂ {P : M → M → M → Prop}
    (hP : ∃ p : Semiformula ℒₒᵣ (Fin 2) 1, p.Open ∧ (∀ x a b, P a b x ↔ Semiformula.Eval! M ![x] ![a, b] p)) (a b x) :
    P a b 0 → ¬P a b x → ∃ x, P a b x ∧ ¬P a b (x + 1) := fun h0 hx ↦ by
  simpa using (not_imp_not.mpr <| open_induction₂ hP a b h0) (by simp; exact ⟨x, hx⟩)

lemma remainder (a : M) {b} (pos : 0 < b) : ∃! u, ∃ v < b, a = b * u + v := by
  have : ∃! u, b * u ≤ a ∧ a < b * (u + 1) := by
    have : ∃ u, b * u ≤ a ∧ a < b * (u + 1) := by
      have : a < b * (a + 1) → ∃ u, b * u ≤ a ∧ a < b * (u + 1) := by
        simpa using open_leastNumber₂ (P := λ a b u ↦ b * u ≤ a) ⟨“&1 * #0 ≤ &0”, by simp, by simp⟩ a b (a + 1)
      simp at this
      have hx : a < b * (a + 1) := by
        have : a + 0 < b * a + b :=
          add_lt_add_of_le_of_lt (le_mul_self_of_pos_left pos) pos
        simpa [mul_add] using this
      exact this hx
    rcases this with ⟨u, hu⟩
    exact ExistsUnique.intro u hu (by
      intro u' hu'
      by_contra ne
      wlog lt : u < u'
      · exact this a pos u' hu' u hu (Ne.symm ne) (Ne.lt_of_le ne $ by simpa using lt)
      have : a < a := by calc
        a < b * (u + 1) := hu.2
        _ ≤ b * u'      := (mul_le_mul_left pos).mpr (lt_iff_succ_le.mp lt)
        _ ≤ a           := hu'.1
      exact LT.lt.false this)
  have iff : ∀ u, (∃ v < b, a = b * u + v) ↔ (b * u ≤ a ∧ a < b * (u + 1)) := by
    intro u; constructor
    · rintro ⟨v, hv, rfl⟩
      simp [mul_add, hv]
    · intro h
      let v := a ∸ b * u
      have e : a = b*u + v := by simp [add_tmsub_self_of_le h.1]
      have : v < b := by
        by_contra hyv
        have hyv : b ≤ v := by simpa using hyv
        have : a < a := by calc
          a < b * (u + 1) := h.2
          _ ≤ b * u + v   := by simpa [mul_add] using hyv
          _ = a           := e.symm
        exact LT.lt.false this
      exact ⟨v, this, e⟩
  exact (exists_unique_congr iff).mpr this

section ediv

lemma ediv_exists_unique (a b : M) : ∃! u, (0 < b → ∃ v < b, a = b * u + v) ∧ (b = 0 → u = 0) := by
  have : 0 ≤ b := by exact zero_le b
  rcases this with (rfl | pos) <;> simp [*]
  · simpa [pos_iff_ne_zero.mp pos] using remainder a pos

/-- Euclidean division -/
def ediv (a b : M) : M := Classical.choose! (ediv_exists_unique a b)

infix:70 " /ₑ " => ediv

lemma ediv_spec_of_pos (a : M) (h : 0 < b) : ∃ v < b, a = b * (a /ₑ b) + v :=
  (Classical.choose!_spec (ediv_exists_unique a b)).1 h

@[simp] lemma ediv_spec_zero (a : M) : a /ₑ 0 = 0 :=
  (Classical.choose!_spec (ediv_exists_unique a 0)).2 (by simp)

lemma ediv_graph {a b c : M} : c = a /ₑ b ↔ ((0 < b → ∃ v < b, a = b * c + v) ∧ (b = 0 → c = 0)) :=
  Classical.choose!_eq_iff _

def edivDefinition : Σᴬ[0] 3 :=
  ⟨“(0 < #2 → ∃[#0 < #3] (#2 = #3 * #1 + #0)) ∧ (#2 = 0 → #0 = 0)”, by simp[Hierarchy.pi_zero_iff_sigma_zero]⟩

lemma ediv_definable : Σᴬ[0]-Function₂ (λ a b : M ↦ a /ₑ b) edivDefinition := by
  intro v; simp[ediv_graph, edivDefinition, Matrix.vecHead, Matrix.vecTail]

lemma ediv_spec_of_pos' (a : M) (h : 0 < b) : ∃ v < b, a = (a /ₑ b) * b + v := by
  simpa [mul_comm] using ediv_spec_of_pos a h

@[simp] lemma mul_ediv_le (a b : M) : b * (a /ₑ b) ≤ a := by
  have : 0 ≤ b := by exact zero_le b
  rcases this with (rfl | pos) <;> simp [*]
  rcases ediv_spec_of_pos a pos with ⟨v, _, e⟩
  simpa [← e] using show b * (a /ₑ b) ≤ b * (a /ₑ b) + v from le_self_add

@[simp] lemma ediv_le (a b : M) : a /ₑ b ≤ a := by
  have : 0 ≤ b := by exact zero_le b
  rcases this with (rfl | pos) <;> simp [*]
  have : 1 * (a /ₑ b) ≤ b * (a /ₑ b) := mul_le_mul_of_nonneg_right (le_iff_lt_succ.mpr (by simp[pos])) (by simp)
  simpa using le_trans this (mul_ediv_le a b)

lemma ediv_polybounded : PolyBounded₂ (λ a b : M ↦ a /ₑ b) #0 := λ _ ↦ by simp

@[simp] lemma ediv_mul_le (a b : M) : a /ₑ b * b ≤ a := by rw [mul_comm]; exact mul_ediv_le _ _

lemma lt_mul_ediv (a : M) {b} (pos : 0 < b) : a < b * (a /ₑ b + 1) := by
  rcases ediv_spec_of_pos a pos with ⟨v, hv, e⟩
  calc a = b * (a /ₑ b) + v := e
       _ < b * (a /ₑ b + 1) := by simp [mul_add, hv]

@[simp] lemma ediv_one (a : M) : a /ₑ 1 = a :=
  le_antisymm (by simp) (le_iff_lt_succ.mpr $ by simpa using lt_mul_ediv a one_pos)

lemma ediv_mul_add (a : M) {b r} (pos : 0 < b) (hr : r < b) : (a * b + r) /ₑ b = a := by
  rcases ediv_spec_of_pos (a * b + r) pos with ⟨v, hv, e⟩
  symm; apply eq_of_le_of_not_lt
  · have : a * b < ((a * b + r) /ₑ b + 1) * b := calc
      a * b ≤ a * b + r                  := le_self_add
      _     = ((a * b + r) /ₑ b) * b + v := by simpa [@mul_comm _ _ b] using e
      _     < ((a * b + r) /ₑ b + 1) * b := by simp [add_mul, hv]
    exact le_iff_lt_succ.mpr <| lt_of_mul_lt_mul_of_nonneg_right this (by simp)
  · intro H
    have : ((a * b + r) /ₑ b) * b < (a + 1) * b := calc
      ((a * b + r) /ₑ b) * b ≤ a * b + r   := by simp
      _                      < (a + 1) * b := by simp [add_mul, hr]
    have : (a * b + r) /ₑ b ≤ a := le_iff_lt_succ.mpr ((mul_lt_mul_right pos).mp this)
    have : a < a := lt_of_lt_of_le H this
    exact LT.lt.false this

lemma ediv_add_mul_self (a c : M) {b} (pos : 0 < b) : (a + c * b) /ₑ b = a /ₑ b + c := by
  rcases ediv_spec_of_pos' a pos with ⟨r, hr, ex⟩
  simpa [add_mul, add_right_comm, ← ex] using ediv_mul_add (a /ₑ b + c) pos hr

lemma ediv_mul_add_self (a c : M) {b} (pos : 0 < b) : (a * b + c) /ₑ b = a + c /ₑ b := by
  simp [ediv_add_mul_self, pos, add_comm]

@[simp] lemma ediv_mul_left (a : M) {b} (pos : 0 < b) : (a * b) /ₑ b = a := by
  simpa using ediv_mul_add a pos pos

@[simp] lemma ediv_mul_right (a : M) {b} (pos : 0 < b) : (b * a) /ₑ b = a := by
  simpa [mul_comm] using ediv_mul_add a pos pos

@[simp] lemma ediv_eq_zero_of_lt (b : M) {a} (h : a < b) : a /ₑ b = 0 := by
  simpa using ediv_mul_add 0 (pos_of_gt h) h

@[simp] lemma ediv_self {a : M} (hx : 0 < a) : a /ₑ a = 1 := by
  simpa using ediv_mul_left 1 hx

@[simp] lemma zero_ediv (a : M) : 0 /ₑ a = 0 := by
  have : 0 ≤ a := by exact zero_le a
  rcases this with (rfl | pos) <;> simp [*]

@[simp] lemma ediv_mul' (a : M) {b} (pos : 0 < b) : (b * a) /ₑ b = a := by simp [mul_comm, pos]

end ediv

section remainder

def rem (a b : M) : M := a ∸ b * (a /ₑ b)

infix:60 " mod " => rem

def remDefinition : Σᴬ[0] 3 :=
  ⟨“∃[#0 < #2 + 1] (!edivDefinition [#0, #2, #3] ∧ !msubDefinition [#1, #2, #3 * #0])”, by simp⟩

lemma rem_graph (a b c : M) : a = b mod c ↔ ∃ x ≤ b, (x = b /ₑ c ∧ a = b ∸ c * x) := by
  simp [rem]; constructor
  · rintro rfl; exact ⟨b /ₑ c, by simp, rfl, by rfl⟩
  · rintro ⟨_, _, rfl, rfl⟩; simp

lemma rem_definable : Σᴬ[0]-Function₂ (λ a b : M ↦ a mod b) remDefinition := by
  intro v; simp [Matrix.vecHead, Matrix.vecTail, remDefinition,
    rem_graph, Semiformula.eval_substs, ediv_definable.pval, msub_definable.pval, le_iff_lt_succ]

lemma ediv_add_remainder (a b : M) : b * (a /ₑ b) + (a mod b) = a :=
  add_tmsub_self_of_le (mul_ediv_le a b)

lemma remainder_mul_add_of_lt (a : M) {b} (pos : 0 < b) {r} (hr : r < b) : (a * b + r) mod b = r := by
  simp [rem, ediv_mul_add a pos hr, mul_comm]

@[simp] lemma remainder_mul_add (a c : M) (pos : 0 < b) : (a * b + c) mod b = c mod b := by
  simp [rem, ediv_mul_add_self, pos, mul_add, ←msub_msub, show b * a = a * b from mul_comm _ _]

@[simp] lemma remainder_eq_self_of_lt {a b : M} (h : a < b) : a mod b = a := by
  simpa using remainder_mul_add_of_lt 0 (pos_of_gt h) h

@[simp] lemma remainder_zero (a : M) : a mod 0 = a := by simp [rem]

@[simp] lemma remainder_self {a : M} (pos : 0 < a) : a mod a = 0 := by simp [rem, pos]

end remainder

section sqrt

lemma sqrt_exists_unique (a : M) : ∃! x, x * x ≤ a ∧ a < (x + 1) * (x + 1) := by
  have : ∃ x, x * x ≤ a ∧ a < (x + 1) * (x + 1) := by
    have : a < (a + 1) * (a + 1) → ∃ x, x * x ≤ a ∧ a < (x + 1) * (x + 1) := by
      simpa using open_leastNumber₁ (P := λ a x ↦ x * x ≤ a) ⟨“#0 * #0 ≤ &0”, by simp, by simp⟩ a (a + 1)
    have hn : a < (a + 1) * (a + 1) := calc
      a ≤ a * a             := le_mul_self a
      _ < a * a + 1         := lt_add_one (a * a)
      _ ≤ (a + 1) * (a + 1) := by simp [add_mul_self_eq]
    exact this hn
  rcases this with ⟨x, hx⟩
  exact ExistsUnique.intro x hx (by
    intro y hy
    by_contra ne
    wlog lt : x < y
    · exact this a y hy x hx (Ne.symm ne) (Ne.lt_of_le ne $ by simpa using lt)
    have : a < a := calc
      a < (x + 1) * (x + 1) := hx.2
      _ ≤ y * y             := mul_self_le_mul_self (by simp) (lt_iff_succ_le.mp lt)
      _ ≤ a                 := hy.1
    simp at this)

def sqrt (a : M) : M := Classical.choose! (sqrt_exists_unique a)

prefix:75 "√" => sqrt

@[simp] lemma sqrt_spec_le (a : M) : √a * √a ≤ a := (Classical.choose!_spec (sqrt_exists_unique a)).1

@[simp] lemma sqrt_spec_lt (a : M) : a < (√a + 1) * (√a + 1) := (Classical.choose!_spec (sqrt_exists_unique a)).2

lemma sqrt_graph {a b : M} : b = √a ↔ b * b ≤ a ∧ a < (b + 1) * (b + 1) := Classical.choose!_eq_iff _

def sqrtDefinition : Σᴬ[0] 2 :=
  ⟨“#0 * #0 ≤ #1 ∧ #1 < (#0 + 1) * (#0 + 1)”, by simp[Hierarchy.pi_zero_iff_sigma_zero]⟩

lemma sqrt_definable : Σᴬ[0]-Function₁ (λ a : M ↦ √a) sqrtDefinition := by
  intro v; simp[sqrt_graph, sqrtDefinition, Matrix.vecHead, Matrix.vecTail]

lemma eq_sqrt (x a : M) : x * x ≤ a ∧ a < (x + 1) * (x + 1) → x = √a := Classical.choose_uniq (sqrt_exists_unique a)

@[simp] lemma sqrt_mul_self (a : M) : √(a * a) = a :=
  Eq.symm <| eq_sqrt a (a * a) (by simp; exact mul_self_lt_mul_self (by simp) (by simp))

end sqrt

section cpair

def cpair (a b : M) : M := ((a + b) * (a + b + 1)) /ₑ 2 + b

notation "⟨" a " ; " b "⟩" => cpair a b

lemma cpair_graph {a b c : M} :
    c = ⟨a ; b⟩ ↔ ∃ r < 2, (a + b) * (a + b + 1) + 2 * b = 2 * c + r := by
  simp [cpair, ediv_graph, ←ediv_add_mul_self, mul_comm]

def cpairDefinition : Σᴬ[0] 3 :=
  ⟨“∃[#0 < 2] (#2 + #3) * (#2 + #3 + 1) + 2 * #3 = 2 * #1 + #0”, by simp[Hierarchy.pi_zero_iff_sigma_zero]⟩

def cpairPolyBound : Polynomial 2 := ᵀ“(#0 + #1) * (#0 + #1 + 1) + #1 * 2”

lemma cpair_definable : Σᴬ[0]-Function₂ (λ a b : M ↦ ⟨a ; b⟩) cpairDefinition := by
  intro v; simp [Matrix.vecHead, Matrix.vecTail, Matrix.constant_eq_singleton, cpair_graph, cpairDefinition]

lemma cpair_polybounded : PolyBounded₂ (λ a b : M ↦ ⟨a ; b⟩) cpairPolyBound :=
  λ _ ↦ by simp[cpair, ←ediv_add_mul_self, cpairPolyBound]

end cpair

namespace LenBit

/-- $\mathrm{LenBit} (2^i, a) \iff \text{$i$th-bit of $a$ is $1$}$. -/
def LenBit (w a : M) : Prop := (a /ₑ w) mod 2 = 1

def lenBitDefinition : Σᴬ[0] 2 :=
  ⟨“∃[#0 < #2 + 1] !remDefinition [1, #0, 2]”, by simp⟩

end LenBit

end IOpen

section ISigma

lemma iSigma_subset_mono {s₁ s₂} (h : s₁ ≤ s₂) : 𝐈𝚺 s₁ ⊆ 𝐈𝚺 s₂ :=
  Theory.IndScheme_subset (fun H ↦ H.mono h)

def mod_IOpen_of_mod_ISigma (s) [(𝐈𝚺 s).Mod M] : 𝐈open.Mod M :=
  Theory.Mod.of_ss M (show 𝐈open ⊆ 𝐈𝚺 s from Theory.IndScheme_subset Hierarchy.Open)

def mod_ISigma_of_le {s₁ s₂} (h : s₁ ≤ s₂) [(𝐈𝚺 s₂).Mod M] : (𝐈𝚺 s₁).Mod M :=
  Theory.Mod.of_ss M (iSigma_subset_mono h)

instance [𝐈𝚺₀.Mod M] : 𝐈open.Mod M := mod_IOpen_of_mod_ISigma 0

instance [𝐈𝚺₁.Mod M] : 𝐈open.Mod M := mod_IOpen_of_mod_ISigma 1

instance [𝐈𝚺₁.Mod M] : 𝐈𝚺₀.Mod M := mod_ISigma_of_le (show 0 ≤ 1 from by simp)

end ISigma

namespace ISigma₀.Model

variable [𝐈𝚺₀.Mod M]


end ISigma₀.Model

end Model

end

end Arith

end LO.FirstOrder
