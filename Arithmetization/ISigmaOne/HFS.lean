import Arithmetization.ISigmaOne.Bit

/-!

# Hereditary Finite Set Theory in $\mathsf{I} \Sigma_1$

-/

noncomputable section

namespace LO.FirstOrder.Arith.Model

variable {M : Type*} [Zero M] [One M] [Add M] [Mul M] [LT M]

variable [M ⊧ₘ* 𝐈𝚺₁]

@[simp] lemma susbset_insert (x a : M) : a ⊆ insert x a := by intro z hz; simp [hz]

@[simp] lemma bitRemove_susbset (x a : M) : bitRemove x a ⊆ a := by intro z; simp

lemma lt_of_mem_dom {x y m : M} (h : ⟪x, y⟫ ∈ m) : x < m := lt_of_le_of_lt (by simp) (lt_of_mem h)

lemma lt_of_mem_rng {x y m : M} (h : ⟪x, y⟫ ∈ m) : y < m := lt_of_le_of_lt (by simp) (lt_of_mem h)

section sUnion

lemma sUnion_exists_unique (s : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔ ∃ t ∈ s, x ∈ t) := by
  have : 𝚺₁-Predicate fun x ↦ ∃ t ∈ s, x ∈ t := by definability
  exact finite_comprehension₁! this
    ⟨s, fun i ↦ by
      rintro ⟨t, ht, hi⟩; exact lt_trans _ _ _ (lt_of_mem hi) (lt_of_mem ht)⟩

def sUnion (s : M) : M := Classical.choose! (sUnion_exists_unique s)

prefix:80 "⋃ʰᶠ " => sUnion

@[simp] lemma mem_sUnion_iff {a b : M} : a ∈ ⋃ʰᶠ b ↔ ∃ c ∈ b, a ∈ c := Classical.choose!_spec (sUnion_exists_unique b) a

@[simp] lemma sUnion_empty : (⋃ʰᶠ ∅ : M) = ∅ := mem_ext (by simp)

lemma sUnion_lt_of_pos {a : M} (ha : 0 < a) : ⋃ʰᶠ a < a :=
  lt_of_lt_log ha (by simp; intro i x hx hi; exact lt_of_lt_of_le (lt_of_mem hi) (le_log_of_mem hx))

@[simp] lemma sUnion_le (a : M) : ⋃ʰᶠ a ≤ a := by
  rcases zero_le a with (rfl | pos)
  · simp [←emptyset_def]
  · exact le_of_lt (sUnion_lt_of_pos pos)

lemma sUnion_graph {u s : M} : u = ⋃ʰᶠ s ↔ ∀ x < u + s, (x ∈ u ↔ ∃ t ∈ s, x ∈ t) :=
  ⟨by rintro rfl; simp, by
    intro h; apply mem_ext
    intro x; simp
    constructor
    · intro hx
      exact h x (lt_of_lt_of_le (lt_of_mem hx) (by simp)) |>.mp hx
    · rintro ⟨c, hc, hx⟩
      exact h x (lt_of_lt_of_le (lt_trans _ _ _ (lt_of_mem hx) (lt_of_mem hc)) (by simp)) |>.mpr ⟨c, hc, hx⟩⟩

def _root_.LO.FirstOrder.Arith.sUnionDef : 𝚺₀-Semisentence 2 := .mkSigma
  “∀[#0 < #1 + #2](#0 ∈ #1 ↔ [∃∈ #2](#1 ∈ #0))” (by simp)

lemma sUnion_defined : 𝚺₀-Function₁ ((⋃ʰᶠ ·) : M → M) via sUnionDef := by
  intro v; simp [sUnionDef, sUnion_graph]

@[simp] lemma sUnion_defined_iff (v) :
    Semiformula.Evalbm M v sUnionDef.val ↔ v 0 = ⋃ʰᶠ v 1 := sUnion_defined.df.iff v

instance sUnion_definable : DefinableFunction₁ ℒₒᵣ 𝚺₀ ((⋃ʰᶠ ·) : M → M) := Defined.to_definable _ sUnion_defined

instance sUnion_definable' (Γ) : DefinableFunction₁ ℒₒᵣ Γ ((⋃ʰᶠ ·) : M → M) := .of_zero sUnion_definable _

end sUnion

section union

def union (a b : M) : M := ⋃ʰᶠ {a, b}

scoped instance : Union M := ⟨union⟩

@[simp] lemma mem_cup_iff {a b c : M} : a ∈ b ∪ c ↔ a ∈ b ∨ a ∈ c := by simp [Union.union, union]

private lemma union_graph {u s t : M} : u = s ∪ t ↔ ∀ x < u + s + t, (x ∈ u ↔ x ∈ s ∨ x ∈ t) :=
  ⟨by rintro rfl; simp, by
    intro h; apply mem_ext
    intro x; simp
    constructor
    · intro hx; exact h x (lt_of_lt_of_le (lt_of_mem hx) (by simp [add_assoc])) |>.mp hx
    · rintro (hx | hx)
      · exact h x (lt_of_lt_of_le (lt_of_mem hx) (by simp )) |>.mpr (Or.inl hx)
      · exact h x (lt_of_lt_of_le (lt_of_mem hx) (by simp )) |>.mpr (Or.inr hx)⟩

def _root_.LO.FirstOrder.Arith.unionDef : 𝚺₀-Semisentence 3 := .mkSigma
  “∀[#0 < #1 + #2 + #3](#0 ∈ #1 ↔ #0 ∈ #2 ∨ #0 ∈ #3)” (by simp)

lemma union_defined : 𝚺₀-Function₂ ((· ∪ ·) : M → M → M) via unionDef := by
  intro v; simp [unionDef, union_graph]

@[simp] lemma union_defined_iff (v) :
    Semiformula.Evalbm M v unionDef.val ↔ v 0 = v 1 ∪ v 2 := union_defined.df.iff v

instance union_definable : DefinableFunction₂ ℒₒᵣ 𝚺₀ ((· ∪ ·) : M → M → M) := Defined.to_definable _ union_defined

instance union_definable' (Γ) : DefinableFunction₂ ℒₒᵣ Γ ((· ∪ ·) : M → M → M) := .of_zero union_definable _

lemma insert_eq_union_singleton (a s : M) : insert a s = {a} ∪ s := mem_ext (fun x ↦ by simp)

@[simp] lemma union_polybound (a b : M) : a ∪ b ≤ 2 * (a + b) := le_iff_lt_succ.mpr
  <| lt_of_lt_log (by simp) (by
    simp; rintro i (hi | hi)
    · calc
        i ≤ log (a + b) := le_trans (le_log_of_mem hi) (log_monotone (by simp))
        _ < log (2 * (a + b)) := by simp [log_two_mul_of_pos (show 0 < a + b from by simp [pos_of_nonempty hi])]
        _ ≤ log (2 * (a + b) + 1) := log_monotone (by simp)
    · calc
        i ≤ log (a + b) := le_trans (le_log_of_mem hi) (log_monotone (by simp))
        _ < log (2 * (a + b)) := by simp [log_two_mul_of_pos (show 0 < a + b from by simp [pos_of_nonempty hi])]
        _ ≤ log (2 * (a + b) + 1) := log_monotone (by simp))

instance : Bounded₂ ℒₒᵣ ((· ∪ ·) : M → M → M) := ⟨ᵀ“2 * (#0 + #1)”, λ _ ↦ by simp⟩

lemma union_comm (a b : M) : a ∪ b = b ∪ a := mem_ext (by simp [or_comm])

end union

section sInter

lemma sInter_exists_unique (s : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔ s ≠ ∅ ∧ ∀ t ∈ s, x ∈ t) := by
  have : 𝚺₁-Predicate fun x ↦ s ≠ ∅ ∧ ∀ t ∈ s, x ∈ t := by definability
  exact finite_comprehension₁! this
    ⟨s, fun i ↦ by
      rintro ⟨hs, h⟩
      have : log s ∈ s := log_mem_of_pos <| pos_iff_ne_zero.mpr hs
      exact _root_.trans (lt_of_mem <| h (log s) this) (lt_of_mem this)⟩

def sInter (s : M) : M := Classical.choose! (sInter_exists_unique s)

prefix:80 "⋂ʰᶠ " => sInter

lemma mem_sInter_iff {x s : M} : x ∈ ⋂ʰᶠ s ↔ s ≠ ∅ ∧ ∀ t ∈ s, x ∈ t := Classical.choose!_spec (sInter_exists_unique s) x

@[simp] lemma mem_sInter_iff_empty : ⋂ʰᶠ (∅ : M) = ∅ := mem_ext (by simp [mem_sInter_iff])

lemma mem_sInter_iff_of_pos {x s : M} (h : s ≠ ∅) : x ∈ ⋂ʰᶠ s ↔ ∀ t ∈ s, x ∈ t := by simp [mem_sInter_iff, h]

end sInter

section inter

def inter (a b : M) : M := ⋂ʰᶠ {a, b}

scoped instance : Inter M := ⟨inter⟩

@[simp] lemma mem_inter_iff {a b c : M} : a ∈ b ∩ c ↔ a ∈ b ∧ a ∈ c := by
  simp [Inter.inter, inter, mem_sInter_iff_of_pos (s := {b, c}) (nonempty_iff.mpr ⟨b, by simp⟩)]

lemma inter_comm (a b : M) : a ∩ b = b ∩ a := mem_ext (by simp [and_comm])

end inter

section product

lemma product_exists_unique (a b : M) :
    ∃! u : M, ∀ x, (x ∈ u ↔ ∃ y ∈ a, ∃ z ∈ b, x = ⟪y, z⟫) := by
  have : 𝚺₁-Predicate fun x ↦ ∃ y ∈ a, ∃ z ∈ b, x = ⟪y, z⟫ := by definability
  exact finite_comprehension₁! this
    ⟨⟪log a, log b⟫ + 1, fun i ↦ by
      rintro ⟨y, hy, z, hz, rfl⟩
      simp [lt_succ_iff_le]
      exact pair_le_pair (le_log_of_mem hy) (le_log_of_mem hz)⟩

def product (a b : M) : M := Classical.choose! (product_exists_unique a b)

infixl:60 " ×ʰᶠ " => product

lemma mem_product_iff {x a b : M} : x ∈ a ×ʰᶠ b ↔ ∃ y ∈ a, ∃ z ∈ b, x = ⟪y, z⟫ := Classical.choose!_spec (product_exists_unique a b) x

lemma mem_product_iff' {x a b : M} : x ∈ a ×ʰᶠ b ↔ π₁ x ∈ a ∧ π₂ x ∈ b := by
  simp [mem_product_iff]
  constructor
  · rintro ⟨y, hy, z, hz, rfl⟩; simp [*]
  · rintro ⟨h₁, h₂⟩; exact ⟨π₁ x, h₁, π₂ x, h₂, by simp⟩

@[simp] lemma pair_mem_product_iff {x y a b : M} : ⟪x, y⟫ ∈ a ×ʰᶠ b ↔ x ∈ a ∧ y ∈ b := by simp [mem_product_iff']

lemma pair_mem_product {x y a b : M} (hx : x ∈ a) (hy : y ∈ b) : ⟪x, y⟫ ∈ a ×ʰᶠ b := by
  simp [mem_product_iff]; exact ⟨hx, hy⟩

private lemma product_graph {u a b : M} : u = a ×ʰᶠ b ↔ ∀ x < u + (a + b + 1) ^ 2, (x ∈ u ↔ ∃ y ∈ a, ∃ z ∈ b, x = ⟪y, z⟫) :=
  ⟨by rintro rfl x _; simp [mem_product_iff], by
    intro h
    apply mem_ext; intro x; simp [mem_product_iff]
    constructor
    · intro hx; exact h x (lt_of_lt_of_le (lt_of_mem hx) (by simp)) |>.mp hx
    · rintro ⟨y, hy, z, hz, rfl⟩
      exact h ⟪y, z⟫ (lt_of_lt_of_le (pair_lt_pair (lt_of_mem hy) (lt_of_mem hz))
        (le_trans (pair_polybound a b) <| by simp)) |>.mpr ⟨y, hy, z, hz, rfl⟩⟩

def _root_.LO.FirstOrder.Arith.productDef : 𝚺₀-Semisentence 3 := .mkSigma
  “∀[#0 < #1 + (#2 + #3 + 1) ^' 2](#0 ∈ #1 ↔ [∃∈ #2][∃∈ #4](!pairDef.val [#2, #1, #0]))” (by simp)

lemma product_defined : 𝚺₀-Function₂ ((· ×ʰᶠ ·) : M → M → M) via productDef := by
  intro v; simp [productDef, product_graph]

@[simp] lemma product_defined_iff (v) :
    Semiformula.Evalbm M v productDef.val ↔ v 0 = v 1 ×ʰᶠ v 2 := product_defined.df.iff v

instance product_definable : DefinableFunction₂ ℒₒᵣ 𝚺₀ ((· ×ʰᶠ ·) : M → M → M) := Defined.to_definable _ product_defined

instance product_definable' (Γ) : DefinableFunction₂ ℒₒᵣ Γ ((· ×ʰᶠ ·) : M → M → M) := .of_zero product_definable _

end product

section domain

lemma domain_exists_unique (s : M) :
    ∃! d : M, ∀ x, x ∈ d ↔ ∃ y, ⟪x, y⟫ ∈ s := by
  have : 𝚺₁-Predicate fun x ↦ ∃ y, ⟪x, y⟫ ∈ s :=
    DefinablePred.of_iff (fun x ↦ ∃ y < s, ⟪x, y⟫ ∈ s)
      (fun x ↦ ⟨by rintro ⟨y, hy⟩; exact ⟨y, lt_of_le_of_lt (le_pair_right x y) (lt_of_mem hy), hy⟩,
                by rintro ⟨y, _, hy⟩; exact ⟨y, hy⟩⟩)
      (by definability)
  exact finite_comprehension₁!
    this
    (⟨s, fun x ↦ by rintro ⟨y, hy⟩; exact lt_of_le_of_lt (le_pair_left x y) (lt_of_mem hy)⟩)

def domain (s : M) : M := Classical.choose! (domain_exists_unique s)

lemma mem_domain_iff {x s : M} : x ∈ domain s ↔ ∃ y, ⟪x, y⟫ ∈ s := Classical.choose!_spec (domain_exists_unique s) x

private lemma domain_graph {u s : M} : u = domain s ↔ ∀ x < u + s, (x ∈ u ↔ ∃ y < s, ∃ z ∈ s, z = ⟪x, y⟫) :=
  ⟨by rintro rfl x _; simp [mem_domain_iff]
      exact ⟨by rintro ⟨y, hy⟩; exact ⟨y, lt_of_le_of_lt (le_pair_right x y) (lt_of_mem hy), hy⟩, by
        rintro ⟨y, _, hy⟩; exact ⟨y, hy⟩⟩,
   by intro h; apply mem_ext; intro x; simp [mem_domain_iff]
      constructor
      · intro hx
        rcases h x (lt_of_lt_of_le (lt_of_mem hx) (by simp)) |>.mp hx with ⟨y, _, _, hy, rfl⟩; exact ⟨y, hy⟩
      · rintro ⟨y, hy⟩
        exact h x (lt_of_lt_of_le (lt_of_le_of_lt (le_pair_left x y) (lt_of_mem hy)) (by simp))
          |>.mpr ⟨y, lt_of_le_of_lt (le_pair_right x y) (lt_of_mem hy), _, hy, rfl⟩⟩

def _root_.LO.FirstOrder.Arith.domainDef : 𝚺₀-Semisentence 2 := .mkSigma
  “∀[#0 < #1 + #2](#0 ∈ #1 ↔ ∃[#0 < #3] [∃∈ #3](!pairDef.val [#0, #2, #1]))” (by simp)

lemma domain_defined : 𝚺₀-Function₁ (domain : M → M) via domainDef := by
  intro v; simp [domainDef, domain_graph]

@[simp] lemma domain_defined_iff (v) :
    Semiformula.Evalbm M v domainDef.val ↔ v 0 = domain (v 1) := domain_defined.df.iff v

instance domain_definable : DefinableFunction₁ ℒₒᵣ 𝚺₀ (domain : M → M) := Defined.to_definable _ domain_defined

instance domain_definable' (Γ) : DefinableFunction₁ ℒₒᵣ Γ (domain : M → M) := .of_zero domain_definable _

@[simp] lemma domain_empty : domain (∅ : M) = ∅ := mem_ext (by simp [mem_domain_iff])

@[simp] lemma domain_union (a b : M) : domain (a ∪ b) = domain a ∪ domain b := mem_ext (by
  simp [mem_domain_iff]
  intro x; constructor
  · rintro ⟨y, (hy | hy)⟩
    · left; exact ⟨y, hy⟩
    · right; exact ⟨y, hy⟩
  · rintro (⟨y, hy⟩ | ⟨y, hy⟩)
    · exact ⟨y, Or.inl hy⟩
    · exact ⟨y, Or.inr hy⟩)

@[simp] lemma domain_singleton (x y : M) : (domain {⟪x, y⟫} : M) = {x} := mem_ext (by simp [mem_domain_iff])

@[simp] lemma domain_insert (x y s : M) : domain (insert ⟪x, y⟫ s) = insert x (domain s) := by simp [insert_eq_union_singleton]

/-- TODO: prove `domain s ≤ s` -/
@[simp] lemma domain_bound (s : M) : domain s ≤ 2 * s := le_iff_lt_succ.mpr
  <| lt_of_lt_log (by simp) (by
    simp [mem_domain_iff]; intro i x hix
    exact lt_of_le_of_lt (le_trans (le_pair_left i x) (le_log_of_mem hix))
      (by simp [log_two_mul_add_one_of_pos (pos_of_nonempty hix)]))

instance : Bounded₁ ℒₒᵣ (domain : M → M) := ⟨ᵀ“2 * #0”, λ _ ↦ by simp⟩

lemma mem_domain_of_pair_mem {x y s : M} (h : ⟪x, y⟫ ∈ s) : x ∈ domain s := mem_domain_iff.mpr ⟨y, h⟩

lemma domain_subset_domain_of_subset {s t : M} (h : s ⊆ t) : domain s ⊆ domain t := by
  intro x hx
  rcases mem_domain_iff.mp hx with ⟨y, hy⟩
  exact mem_domain_iff.mpr ⟨y, h hy⟩

@[simp] lemma domain_eq_empty_iff_eq_empty {s : M} : domain s = ∅ ↔ s = ∅ :=
  ⟨by simp [isempty_iff, mem_domain_iff]
      intro h x hx
      exact h (π₁ x) (π₂ x) (by simpa using hx), by rintro rfl; simp⟩

/-
@[simp] lemma domain_le_self {P : M → Prop}
    (hempty : P ∅) (hinsert : ∀ s x, x ∉ s → P s → P (insert x s)) : ∀ x, P x := by {  }

@[simp] lemma domain_le_self (P : M → Prop) (s : M) : domain s ≤ s := le_iff_lt_succ.mpr
-/

end domain

section range

/-
lemma range_exists_unique (s : M) :
    ∃! r : M, ∀ y, y ∈ r ↔ ∃ x, ⟪x, y⟫ ∈ s := by
  have : 𝚺₁-Predicate fun y ↦ ∃ x, ⟪x, y⟫ ∈ s :=
    DefinablePred.of_iff (fun y ↦ ∃ x < s, ⟪x, y⟫ ∈ s)
      (fun y ↦ ⟨by rintro ⟨x, hy⟩; exact ⟨x, lt_of_le_of_lt (le_pair_left x y) (lt_of_mem hy), hy⟩,
                by rintro ⟨y, _, hy⟩; exact ⟨y, hy⟩⟩)
      (by definability)
  exact finite_comprehension₁!
    this
    (⟨s, fun y ↦ by rintro ⟨x, hx⟩; exact lt_of_le_of_lt (le_pair_right x y) (lt_of_mem hx)⟩)
-/

end range

section disjoint

def Disjoint (s t : M) : Prop := s ∩ t = ∅

lemma Disjoint.iff {s t : M} : Disjoint s t ↔ ∀ x, x ∉ s ∨ x ∉ t := by simp [Disjoint, isempty_iff, imp_iff_not_or]

lemma Disjoint.not_of_mem {s t x : M} (hs : x ∈ s) (ht : x ∈ t) : ¬Disjoint s t := by
  simp [Disjoint.iff, not_or]; exact ⟨x, hs, ht⟩

lemma Disjoint.symm {s t : M} (h : Disjoint s t) : Disjoint t s := by simpa [Disjoint, inter_comm t s] using h

@[simp] lemma Disjoint.singleton_iff {a : M} : Disjoint ({a} : M) s ↔ a ∉ s := by simp [Disjoint, isempty_iff]

end disjoint

section mapping

def IsMapping (m : M) : Prop := ∀ x ∈ domain m, ∃! y, ⟪x, y⟫ ∈ m

lemma IsMapping.get_exists_uniq {m : M} (h : IsMapping m) {x : M} (hx : x ∈ domain m) : ∃! y, ⟪x, y⟫ ∈ m := h x hx

def IsMapping.get {m : M} (h : IsMapping m) {x : M} (hx : x ∈ domain m) : M := Classical.choose! (IsMapping.get_exists_uniq h hx)

@[simp] lemma IsMapping.get_mem {m : M} (h : IsMapping m) {x : M} (hx : x ∈ domain m) :
    ⟪x, h.get hx⟫ ∈ m := Classical.choose!_spec (IsMapping.get_exists_uniq h hx)

lemma IsMapping.get_uniq {m : M} (h : IsMapping m) {x : M} (hx : x ∈ domain m) (hy : ⟪x, y⟫ ∈ m) : y = h.get hx :=
    (h x hx).unique hy (by simp)

@[simp] lemma IsMapping.empty : IsMapping (∅ : M) := by intro x; simp

lemma IsMapping.union_of_disjoint_domain {m₁ m₂ : M}
    (h₁ : IsMapping m₁) (h₂ : IsMapping m₂) (disjoint : Disjoint (domain m₁) (domain m₂)) : IsMapping (m₁ ∪ m₂) := by
  intro x
  simp; rintro (hx | hx)
  · exact ExistsUnique.intro (h₁.get hx) (by simp) (by
      intro y
      rintro (hy | hy)
      · exact h₁.get_uniq hx hy
      · by_contra; exact Disjoint.not_of_mem hx (mem_domain_of_pair_mem hy) disjoint)
  · exact ExistsUnique.intro (h₂.get hx) (by simp) (by
      intro y
      rintro (hy | hy)
      · by_contra; exact Disjoint.not_of_mem hx (mem_domain_of_pair_mem hy) disjoint.symm
      · exact h₂.get_uniq hx hy)

@[simp] lemma IsMapping.singleton (x y : M) : IsMapping ({⟪x, y⟫} : M) := by
  intro x; simp; rintro rfl; exact ExistsUnique.intro y (by simp) (by rintro _ ⟨_, rfl⟩; simp)

lemma IsMapping.insert {x y m : M}
    (h : IsMapping m) (disjoint : x ∉ domain m) : IsMapping (insert ⟪x, y⟫ m) := by
  simp [insert_eq_union_singleton]
  exact IsMapping.union_of_disjoint_domain (by simp) h (by simpa)

lemma IsMapping.of_subset {m m' : M} (h : IsMapping m) (ss : m' ⊆ m) : IsMapping m' := fun x hx ↦ by
  rcases mem_domain_iff.mp hx with ⟨y, hy⟩
  have : ∃! y, ⟪x, y⟫ ∈ m := h x (domain_subset_domain_of_subset ss hx)
  exact ExistsUnique.intro y hy (fun y' hy' ↦ this.unique (ss hy') (ss hy))

lemma IsMapping.uniq {m x y₁ y₂ : M} (h : IsMapping m) : ⟪x, y₁⟫ ∈ m → ⟪x, y₂⟫ ∈ m → y₁ = y₂ := fun h₁ h₂ ↦
  h x (mem_domain_iff.mpr ⟨y₁, h₁⟩) |>.unique h₁ h₂

private lemma isMapping_iff {m : M} : IsMapping m ↔ ∃ d ≤ 2 * m, d = domain m ∧ ∀ x ∈ d, ∃ y < m, ⟪x, y⟫ ∈ m ∧ ∀ y' < m, ⟪x, y'⟫ ∈ m → y' = y :=
  ⟨by intro hm
      exact ⟨domain m, by simp, rfl, fun x hx ↦ by
        rcases hm x hx with ⟨y, hy, uniq⟩
        exact ⟨y, lt_of_mem_rng hy, hy, fun y' _ h' ↦ uniq y' h'⟩⟩,
   by rintro ⟨_, _, rfl, h⟩ x hx
      rcases h x hx with ⟨y, _, hxy, h⟩
      exact ExistsUnique.intro y hxy (fun y' hxy' ↦ h y' (lt_of_mem_rng hxy') hxy')⟩

def _root_.LO.FirstOrder.Arith.isMappingDef : 𝚺₀-Semisentence 1 := .mkSigma
  “∃[#0 < 2 * #1 + 1](!domainDef.val [#0, #1] ∧ [∀∈ #0] ∃[#0 < #3](#1 ~[#3] #0 ∧ ∀[#0 < #4](#2 ~[#4] #0 → #0 = #1)))” (by simp)

lemma isMapping_defined : 𝚺₀-Predicate (IsMapping : M → Prop) via isMappingDef := by
  intro v; simp [isMappingDef, isMapping_iff, lt_succ_iff_le]

@[simp] lemma isMapping_defined_iff (v) :
    Semiformula.Evalbm M v isMappingDef.val ↔ IsMapping (v 0) := isMapping_defined.df.iff v

instance isMapping_definable : 𝚺₀-Predicate (IsMapping : M → Prop) := Defined.to_definable _ isMapping_defined

instance isMapping_definable' (Γ) : Γ-Predicate (IsMapping : M → Prop) := .of_zero isMapping_definable _

end mapping

section seq

def Seq (s : M) : Prop := IsMapping s ∧ ∃ l, domain s = under l

def Seq.isMapping {s : M} (h : Seq s) : IsMapping s := h.1

private lemma seq_iff (s : M) : Seq s ↔ IsMapping s ∧ ∃ l < 2 * s + 1, ∃ d < 2 * s + 1, d = domain s ∧ d = under l :=
  ⟨by rintro ⟨hs, l, h⟩
      exact ⟨hs, l, lt_succ_iff_le.mpr (by
      calc
        l ≤ domain s := by simp [h]
        _ ≤ 2 * s    := by simp), ⟨domain s , by simp [lt_succ_iff_le], rfl, h⟩⟩,
   by rintro ⟨hs, l, _, _, _, rfl, h⟩; exact ⟨hs, l, h⟩⟩

def _root_.LO.FirstOrder.Arith.seqDef : 𝚺₀-Semisentence 1 := .mkSigma
  “!isMappingDef.val [#0] ∧ ∃[#0 < 2 * #1 + 1] ∃[#0 < 2 * #2 + 1] (!domainDef.val [#0, #2] ∧ !underDef.val [#0, #1])” (by simp)

lemma seq_defined : 𝚺₀-Predicate (Seq : M → Prop) via seqDef := by
  intro v; simp [seqDef, seq_iff]

@[simp] lemma seq_defined_iff (v) :
    Semiformula.Evalbm M v seqDef.val ↔ Seq (v 0) := seq_defined.df.iff v

instance seq_definable : 𝚺₀-Predicate (Seq : M → Prop) := Defined.to_definable _ seq_defined

@[simp, definability] instance seq_definable' (Γ) : Γ-Predicate (Seq : M → Prop) := .of_zero seq_definable _

lemma lh_exists_uniq (s : M) : ∃! l, (Seq s → domain s = under l) ∧ (¬Seq s → l = 0) := by
  by_cases h : Seq s
  · rcases h with ⟨h, l, hl⟩
    exact ExistsUnique.intro l
      (by simp [show Seq s from ⟨h, l, hl⟩, hl])
      (by simp [show Seq s from ⟨h, l, hl⟩, hl])
  · simp [h]

def lh (s : M) : M := Classical.choose! (lh_exists_uniq s)

lemma lh_prop (s : M) : (Seq s → domain s = under (lh s)) ∧ (¬Seq s → lh s = 0) := Classical.choose!_spec (lh_exists_uniq s)

lemma lh_prop_of_not_seq {s : M} (h : ¬Seq s) : lh s = 0 := (lh_prop s).2 h

lemma Seq.domain_eq {s : M} (h : Seq s) : domain s = under (lh s) := (Model.lh_prop s).1 h

lemma Seq.exists {s : M} (h : Seq s) {x : M} (hx : x < lh s) : ∃ y, ⟪x, y⟫ ∈ s := h.isMapping x (by simpa [h.domain_eq] using hx) |>.exists

lemma Seq.nth_exists_uniq {s : M} (h : Seq s) {x : M} (hx : x < lh s) : ∃! y, ⟪x, y⟫ ∈ s := h.isMapping x (by simpa [h.domain_eq] using hx)

def Seq.nth {s : M} (h : Seq s) {x : M} (hx : x < lh s) : M := Classical.choose! (h.nth_exists_uniq hx)

@[simp] lemma Seq.nth_mem {s : M} (h : Seq s) {x : M} (hx : x < lh s) :
    ⟪x, h.nth hx⟫ ∈ s := Classical.choose!_spec (h.nth_exists_uniq hx)

lemma Seq.nth_uniq {s : M} (h : Seq s) {x y : M} (hx : x < lh s) (hy : ⟪x, y⟫ ∈ s) : y = h.nth hx :=
    (h.nth_exists_uniq hx).unique hy (by simp)

@[simp] lemma Seq.nth_lt {s : M} (h : Seq s) {x} (hx : x < lh s) : h.nth hx < s := lt_of_mem_rng (h.nth_mem hx)

lemma Seq.lt_lh_iff {s : M} (h : Seq s) {i} : i < lh s ↔ i ∈ domain s := by simp [h.domain_eq]

lemma Seq.lt_lh_of_mem {s : M} (h : Seq s) {i x} (hix : ⟪i, x⟫ ∈ s) : i < lh s := by simp [h.lt_lh_iff, mem_domain_iff]; exact ⟨x, hix⟩

def seqCons (x s : M) : M := insert ⟪lh s, x⟫ s

@[simp] lemma seq_empty : Seq (∅ : M) := ⟨by simp, 0, by simp⟩

@[simp] lemma lh_empty : lh (∅ : M) = 0 := by
  have : under (lh ∅ : M) = under 0 := by simpa using Eq.symm <| Seq.domain_eq (M := M) (s := ∅) (by simp)
  exact under_inj.mp this

infixr:67 " ::ˢ " => seqCons

@[simp] lemma Seq.subset_seqCons (s x : M) : s ⊆ x ::ˢ s := by simp [seqCons]

lemma Seq.lt_seqCons {s} (hs : Seq s) (x : M) : s < x ::ˢ s :=
  lt_iff_le_and_ne.mpr <| ⟨le_of_subset <| by simp, by
    simp [seqCons]; intro A
    have : ⟪lh s, x⟫ ∈ s := by simpa [←A] using mem_insert ⟪lh s, x⟫ s
    simpa using hs.lt_lh_of_mem this⟩

@[simp] lemma Seq.mem_seqCons (s x : M) : ⟪lh s, x⟫ ∈ x ::ˢ s := by simp [seqCons]

protected lemma Seq.seqCons {s : M} (h : Seq s) (x : M) : Seq (x ::ˢ s) :=
  ⟨h.isMapping.insert (by simp [h.domain_eq]), lh s + 1, by simp [seqCons, h.domain_eq]⟩

@[simp] lemma Seq.lh_seqCons (x : M) {s} (h : Seq s) : lh (x ::ˢ s) = lh s + 1 := by
  have : under (lh s + 1) = under (lh (x ::ˢ s)) := by
    simpa [seqCons, h.domain_eq] using (h.seqCons x).domain_eq
  exact Eq.symm <| under_inj.mp this

lemma mem_seqCons_iff {i x z s : M} : ⟪i, x⟫ ∈ z ::ˢ s ↔ (i = lh s ∧ x = z) ∨ ⟪i, x⟫ ∈ s := by simp [seqCons]

@[simp] lemma lh_mem_seqCons (s z : M) : ⟪lh s, z⟫ ∈ z ::ˢ s := by simp [seqCons]

lemma domain_bitRemove_of_isMapping_of_mem {x y s : M} (hs : IsMapping s) (hxy : ⟪x, y⟫ ∈ s) :
    domain (bitRemove ⟪x, y⟫ s) = bitRemove x (domain s) := by
  apply mem_ext; simp [mem_domain_iff]; intro x₁
  constructor
  · rintro ⟨y₁, hy₁, hx₁y₁⟩; exact ⟨by rintro rfl; exact hy₁ rfl (hs.uniq hx₁y₁ hxy), y₁, hx₁y₁⟩
  · intro ⟨hx, y₁, hx₁y₁⟩
    exact ⟨y₁, by intro _; contradiction, hx₁y₁⟩

/-- TODO: move to Lemmata.lean-/
lemma ne_zero_iff_one_le {a : M} : a ≠ 0 ↔ 1 ≤ a := Iff.trans pos_iff_ne_zero.symm (pos_iff_one_le (a := a))

lemma Seq.cases_iff {s : M} : Seq s ↔ s = ∅ ∨ ∃ x s', Seq s' ∧ s = x ::ˢ s' := ⟨fun h ↦ by
  by_cases hs : lh s = 0
  · left
    simpa [hs] using h.domain_eq
  · right
    let i := lh s - 1
    have hi : i < lh s := pred_lt_self_of_pos (pos_iff_ne_zero.mpr hs)
    have lhs_eq : lh s = i + 1 := Eq.symm <| tsub_add_cancel_of_le <| ne_zero_iff_one_le.mp hs
    let s' := bitRemove ⟪i, h.nth hi⟫ s
    have his : ⟪i, h.nth hi⟫ ∈ s := h.nth_mem hi
    have hdoms' : domain s' = under i := by
      simp only [domain_bitRemove_of_isMapping_of_mem h.isMapping his, h.domain_eq, s']
      apply mem_ext
      simp [lhs_eq, and_or_left]
      intro j hj; exact ne_of_lt hj
    have hs' : Seq s' := ⟨ h.isMapping.of_subset (by simp [s']), i, hdoms' ⟩
    have hs'i : lh s' = i := by simpa [hs'.domain_eq] using hdoms'
    exact ⟨h.nth hi, s', hs', mem_ext <| fun v ↦ by
      simp only [seqCons, hs'i, mem_bitInsert_iff]
      simp [s']
      by_cases hv : v = ⟪i, h.nth hi⟫ <;> simp [hv]⟩,
  by  rintro (rfl | ⟨x, s', hs', rfl⟩)
      · simp
      · exact hs'.seqCons x⟩

alias ⟨Seq.cases, _⟩ := Seq.cases_iff

/-- TODO: move to Ind.lean -/
@[elab_as_elim] lemma order_induction_h_iSigmaOne (Γ)
    {P : M → Prop} (hP : DefinablePred ℒₒᵣ (Γ, 1) P)
    (ind : ∀ x, (∀ y < x, P y) → P x) : ∀ x, P x := order_induction_hh ℒₒᵣ Γ 1 hP ind

theorem seq_induction {P : M → Prop} (hP : DefinablePred ℒₒᵣ (Γ, 1) P)
  (hnil : P ∅) (hcons : ∀ s x, Seq s → P s → P (x ::ˢ s)) :
    ∀ {s : M}, Seq s → P s := by
  intro s sseq
  induction s using order_induction_h_iSigmaOne
  · exact Γ
  · definability
  case ind s ih =>
    have : s = ∅ ∨ ∃ x s', Seq s' ∧ s = x ::ˢ s' := sseq.cases
    rcases this with (rfl | ⟨x, s, hs, rfl⟩)
    · exact hnil
    · exact hcons s x hs (ih s (hs.lt_seqCons x) hs)

/-- `!⟨x, y, z, ...⟩` notation for `Seq` -/
syntax (name := vecNotation) "!⟨" term,* "⟩" : term

macro_rules
  | `(!⟨$term:term, $terms:term,*⟩) => `(seqCons $term !⟨$terms,*⟩)
  | `(!⟨$term:term⟩) => `(seqCons $term ∅)
  | `(!⟨⟩) => `(∅)

@[app_unexpander seqCons]
def vecConsUnexpander : Lean.PrettyPrinter.Unexpander
  | `($_ $term !⟨$term2, $terms,*⟩) => `(!⟨$term, $term2, $terms,*⟩)
  | `($_ $term !⟨$term2⟩) => `(!⟨$term, $term2⟩)
  | `($_ $term ∅) => `(!⟨$term⟩)
  | _ => throw ()

@[simp] lemma singleton_seq (x : M) : Seq !⟨x⟩ := by apply Seq.seqCons; simp

end seq

namespace PR

structure Formulae (k : ℕ) where
  zero : HSemisentence ℒₒᵣ (k + 1) 𝚺₁
  succ : HSemisentence ℒₒᵣ (k + 3) 𝚺₁

variable (M)

structure Construction {k : ℕ} (p : Formulae k) where
  zero : (Fin k → M) → M
  succ : (Fin k → M) → M → M → M
  zero_defined : DefinedFunction ℒₒᵣ 𝚺₁ zero p.zero
  succ_defined : DefinedFunction ℒₒᵣ 𝚺₁ (fun v ↦ succ (v ·.succ.succ) (v 1) (v 0)) p.succ

variable {M}

namespace Construction

variable {k : ℕ} {p : Formulae k} (c : Construction M p) (v : Fin k → M)

def CSeq (s : M) : Prop := Seq s ∧ ⟪0, c.zero v⟫ ∈ s ∧ ∀ i < lh s - 1, ∀ z, ⟪i, z⟫ ∈ s → ⟪i + 1, c.succ v i z⟫ ∈ s

variable {c v}

section

variable {s : M} (h : c.CSeq v s)

lemma CSeq.seq : Seq s := h.1

lemma CSeq.zero : ⟪0, c.zero v⟫ ∈ s := h.2.1

lemma CSeq.succ : ∀ i < lh s - 1, ∀ z, ⟪i, z⟫ ∈ s → ⟪i + 1, c.succ v i z⟫ ∈ s := h.2.2

lemma CSeq.unique {s₁ s₂ : M} (H₁ : c.CSeq v s₁) (H₂ : c.CSeq v s₂) (h₁₂ : lh s₁ ≤ lh s₂) {i} (hi : i < lh s₁) {z₁ z₂} :
    ⟪i, z₁⟫ ∈ s₁ → ⟪i, z₂⟫ ∈ s₂ → z₁ = z₂ := by
  revert z₁ z₂
  suffices ∀ z₁ < s₁, ∀ z₂ < s₂, ⟪i, z₁⟫ ∈ s₁ → ⟪i, z₂⟫ ∈ s₂ → z₁ = z₂
  by intro z₁ z₂ hz₁ hz₂; exact this z₁ (lt_of_mem_rng hz₁) z₂ (lt_of_mem_rng hz₂) hz₁ hz₂
  intro z₁ hz₁ z₂ hz₂ h₁ h₂
  induction i using induction_iSigmaOne generalizing z₁ z₂
  · definability
  case zero =>
    have : z₁ = c.zero v := H₁.seq.isMapping.uniq h₁ H₁.zero
    have : z₂ = c.zero v := H₂.seq.isMapping.uniq h₂ H₂.zero
    simp_all
  case succ i ih =>
    have hi' : i < lh s₁ := lt_of_le_of_lt (by simp) hi
    let z' := H₁.seq.nth hi'
    have ih₁ : ⟪i, z'⟫ ∈ s₁ := H₁.seq.nth_mem hi'
    have ih₂ : ⟪i, z'⟫ ∈ s₂ := by
      have : z' = H₂.seq.nth (lt_of_lt_of_le hi' h₁₂) :=
        ih hi' z' (by simp [z']) (H₂.seq.nth (lt_of_lt_of_le hi' h₁₂)) (by simp [z']) (by simp [z']) (by simp)
      simp [this]
    have h₁' : ⟪i + 1, c.succ v i z'⟫ ∈ s₁ := H₁.succ i (by simp [lt_tsub_iff_right, hi]) z' ih₁
    have h₂' : ⟪i + 1, c.succ v i z'⟫ ∈ s₂ := H₂.succ i (by simp [lt_tsub_iff_right]; exact lt_of_lt_of_le hi h₁₂) z' ih₂
    have e₁ : z₁ = c.succ v i z' := H₁.seq.isMapping.uniq h₁ h₁'
    have e₂ : z₂ = c.succ v i z' := H₂.seq.isMapping.uniq h₂ h₂'
    simp [e₁, e₂]

end

variable (c v)

def initial : M := !⟨c.zero v⟩

variable {c v}

@[simp] lemma CSeq.initial : c.CSeq v (c.initial v) :=
  ⟨by simp [Construction.initial], by simp [Construction.initial, seqCons], by simp [Construction.initial]⟩

lemma CSeq.successor {s l z : M} (Hs : c.CSeq v s) (hl : l + 1 = lh s) (hz : ⟪l, z⟫ ∈ s) :
    c.CSeq v (c.succ v l z ::ˢ s) :=
  ⟨ Hs.seq.seqCons _, by simp [seqCons, Hs.zero], by
    simp [Hs.seq.lh_seqCons]
    intro i hi w hiw
    have hiws : ⟪i, w⟫ ∈ s := by
      simp [mem_seqCons_iff] at hiw; rcases hiw with (⟨rfl, rfl⟩ | h)
      · simp at hi
      · assumption
    have : i ≤ l := by simpa [←hl, lt_succ_iff_le] using hi
    rcases this with (rfl | hil)
    · have : w = z := Hs.seq.isMapping.uniq hiws hz
      simp [this, hl]
    · simp [mem_seqCons_iff]; right
      exact Hs.succ i (by simp [←hl, hil]) w hiws ⟩

variable (c v)

lemma CSeq.exists (l : M) : ∃ s, c.CSeq v s ∧ l + 1 = lh s := by
  induction l using induction_iSigmaOne
  · sorry
  case zero =>
    exact ⟨c.initial v, by simp, by simp [Construction.initial]⟩
  case succ l ih =>
    rcases ih with ⟨s, Hs, hls⟩
    have hl : l < lh s := by simp [←hls]
    have : ∃ z, ⟪l, z⟫ ∈ s := Hs.seq.exists hl
    rcases this with ⟨z, hz⟩
    exact ⟨c.succ v l z ::ˢ s, Hs.successor hls hz, by simp [Hs.seq, hls]⟩

lemma cSeq_result_existsUnique (l : M) : ∃! z, ∃ s, c.CSeq v s ∧ l + 1 = lh s ∧ ⟪l, z⟫ ∈ s := by
  rcases CSeq.exists c v l with ⟨s, Hs, h⟩
  have : ∃ z, ⟪l, z⟫ ∈ s := Hs.seq.exists (show l < lh s from by simp [←h])
  rcases this with ⟨z, hz⟩
  exact ExistsUnique.intro z ⟨s, Hs, h, hz⟩ (by
    rintro z' ⟨s', Hs', h', hz'⟩
    exact Eq.symm <| Hs.unique Hs' (by simp [←h, ←h']) (show l < lh s from by simp [←h]) hz hz')

def result (k : M) : M := Classical.choose! (c.cSeq_result_existsUnique v k)

lemma result_spec (k : M) : ∃ s, c.CSeq v s ∧ k + 1 = lh s ∧ ⟪k, c.result v k⟫ ∈ s := Classical.choose!_spec (c.cSeq_result_existsUnique v k)

@[simp] theorem result_zero : c.result v 0 = c.zero v := by
  rcases c.result_spec v 0 with ⟨s, Hs, _, h0⟩
  exact Hs.seq.isMapping.uniq h0 Hs.zero

theorem result_succ (k : M) : c.result v (k + 1) = c.succ v k (c.result v k) := by
  rcases c.result_spec v k with ⟨s, Hs, hk, h⟩
  have : CSeq c v (c.succ v k (result c v k) ::ˢ s) := Hs.successor hk h
  exact Eq.symm
    <| Classical.choose_uniq (c.cSeq_result_existsUnique v (k + 1))
    ⟨_, this, by simp [Hs.seq, hk], by simp [hk]⟩

end Construction

end PR

end LO.FirstOrder.Arith.Model

end
