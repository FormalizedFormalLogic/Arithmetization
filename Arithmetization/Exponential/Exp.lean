import Arithmetization.Exponential.PPow2
import Mathlib.Tactic.Linarith

namespace LO.FirstOrder

namespace Arith

noncomputable section

variable {M : Type} [Zero M] [One M] [Add M] [Mul M] [LT M] [𝐏𝐀⁻.Mod M]

namespace Model

section ISigma₀

variable [𝐈𝚺₀.Mod M]

def ext (u z : M) : M := z / u mod u

lemma ext_graph (a b c : M) : a = ext b c ↔ ∃ x ≤ c, x = c / b ∧ a = x mod b := by
  simp [ext]; constructor
  · rintro rfl; exact ⟨c / b, by simp, rfl, by rfl⟩
  · rintro ⟨_, _, rfl, rfl⟩; simp

def extdef : Σᴬ[0] 3 :=
  ⟨“∃[#0 < #3 + 1] (!divdef [#0, #3, #2] ∧ !remdef [#1, #0, #2])”, by simp⟩

lemma ext_defined : Σᴬ[0]-Function₂ (λ a b : M ↦ ext a b) extdef := by
  intro v; simp [Matrix.vecHead, Matrix.vecTail, extdef,
    ext_graph, Semiformula.eval_substs, div_defined.pval, rem_defined.pval, le_iff_lt_succ]

instance : DefinableFunction₂ b s (ext : M → M → M) := defined_to_with_param₀ _ ext_defined

@[simp] lemma ext_le_add (u z : M) : ext u z ≤ z :=
  le_trans (remainder_le (z / u) u) (by simp [add_comm])

instance : PolyBounded₂ (ext : M → M → M) := ⟨#1, by intro v; simp⟩

@[simp] lemma ext_lt {u} (z : M) (pos : 0 < u) : ext u z < u := by simp [ext, pos]

lemma ext_add_of_dvd_sq_right {u z₁ z₂ : M} (pos : 0 < u) (h : u^2 ∣ z₂) : ext u (z₁ + z₂) = ext u z₁ := by
  simp [ext]
  have : ∃ z', z₂ = z' * u * u := by rcases h with ⟨u', rfl⟩; exact ⟨u', by simp [mul_comm _ u', mul_assoc]; simp [sq]⟩
  rcases this with ⟨z₂, rfl⟩
  simp [div_add_mul_self, pos]

lemma ext_add_of_dvd_sq_left {u z₁ z₂ : M} (pos : 0 < u) (h : u^2 ∣ z₁) : ext u (z₁ + z₂) = ext u z₂ := by
  rw [add_comm]; exact ext_add_of_dvd_sq_right pos h

lemma ext_rem {i j z : M} (ppi : PPow2 i) (ppj : PPow2 j) (hij : i < j) : ext i (z mod j) = ext i z := by
  have := div_add_remainder z j
  have : i^2 ∣ j := ppi.pow2.sq.dvd_of_le ppj.pow2 (PPow2.sq_le_of_lt ppi ppj hij)
  calc
    ext i (z mod j) = ext i (j * (z / j) + (z mod j)) := by symm; exact ext_add_of_dvd_sq_left ppi.pos (Dvd.dvd.mul_right this (z / j))
    _               = ext i z                          := by simp [div_add_remainder]

def Exp.Seq₀ (X Y : M) : Prop := ext 4 X = 1 ∧ ext 4 Y = 2

def Exp.Seqₛ.Even (X Y u : M) : Prop := ext (u^2) X = 2 * ext u X ∧ ext (u^2) Y = (ext u Y)^2

def Exp.Seqₛ.Odd (X Y u : M) : Prop := ext (u^2) X = 2 * ext u X + 1 ∧ ext (u^2) Y = 2 * (ext u Y)^2

def Exp.Seqₛ (y X Y : M) : Prop := ∀ u ≤ y, u ≠ 2 → PPow2 u → Seqₛ.Even X Y u ∨ Seqₛ.Odd X Y u

def Exp.Seqₘ (x y X Y : M) : Prop := ∃ u ≤ y^2, u ≠ 2 ∧ PPow2 u ∧ ext u X = x ∧ ext u Y = y

def Exp (x y : M) : Prop := (x = 0 ∧ y = 1) ∨ ∃ X ≤ y^4, ∃ Y ≤ y^4, Exp.Seq₀ X Y ∧ Exp.Seqₛ y X Y ∧ Exp.Seqₘ x y X Y

lemma Exp.Seqₛ.iff (y X Y : M) :
  Exp.Seqₛ y X Y ↔
  ∀ u ≤ y, u ≠ 2 → PPow2 u →
    ((∃ ext_u_X ≤ X, ext_u_X = ext u X ∧ 2 * ext_u_X = ext (u^2) X)     ∧ (∃ ext_u_Y ≤ Y, ext_u_Y = ext u Y ∧ ext_u_Y^2 = ext (u^2) Y)) ∨
    ((∃ ext_u_X ≤ X, ext_u_X = ext u X ∧ 2 * ext_u_X + 1 = ext (u^2) X) ∧ (∃ ext_u_Y ≤ Y, ext_u_Y = ext u Y ∧ 2 * ext_u_Y^2 = ext (u^2) Y)) :=
  ⟨by intro H u hu ne2 ppu
      rcases H u hu ne2 ppu with (H | H)
      · exact Or.inl ⟨⟨ext u X, by simp [H.1]⟩, ⟨ext u Y, by simp [H.2]⟩⟩
      · exact Or.inr ⟨⟨ext u X, by simp [H.1]⟩, ⟨ext u Y, by simp [H.2]⟩⟩,
   by intro H u hu ne2 ppu
      rcases H u hu ne2 ppu with (⟨⟨_, _, rfl, hx⟩, ⟨_, _, rfl, hy⟩⟩ | ⟨⟨_, _, rfl, hx⟩, ⟨_, _, rfl, hy⟩⟩)
      · exact Or.inl ⟨by simp [hx, hy], by simp [hx, hy]⟩
      · exact Or.inr ⟨by simp [hx, hy], by simp [hx, hy]⟩⟩

def Exp.Seqₛ.def : Σᴬ[0] 3 := ⟨
  “∀[#0 < #1 + 1](#0 ≠ 2 → !ppow2def [#0] →
    ( ∃[#0 < #3 + 1] (!extdef [#0, #1, #3] ∧ !extdef [2 * #0, #1 * #1, #3]) ∧
      ∃[#0 < #4 + 1] (!extdef [#0, #1, #4] ∧ !extdef [#0 * #0, #1 * #1, #4]) ) ∨
    ( ∃[#0 < #3 + 1] (!extdef [#0, #1, #3] ∧ !extdef [2 * #0 + 1, #1 * #1, #3]) ∧
      ∃[#0 < #4 + 1] (!extdef [#0, #1, #4] ∧ !extdef [2 * (#0 * #0), #1 * #1, #4])))”, by simp⟩

lemma Exp.Seqₛ.defined : Σᴬ[0]-Relation₃ (Exp.Seqₛ : M → M → M → Prop) Exp.Seqₛ.def := by
  intro v; simp [Exp.Seqₛ.iff, Exp.Seqₛ.def, ppow2_defined.pval, ext_defined.pval, ←le_iff_lt_succ, sq]

lemma Exp.graph_iff (x y : M) :
    Exp x y ↔
    (x = 0 ∧ y = 1) ∨ ∃ X ≤ y^4, ∃ Y ≤ y^4,
      (1 = ext 4 X ∧ 2 = ext 4 Y) ∧
      Exp.Seqₛ y X Y ∧
      (∃ u ≤ y^2, u ≠ 2 ∧ PPow2 u ∧ x = ext u X ∧ y = ext u Y) :=
  ⟨by rintro (H | ⟨X, bX, Y, bY, H₀, Hₛ, ⟨u, hu, ne2, ppu, hX, hY⟩⟩)
      · exact Or.inl H
      · exact Or.inr ⟨X, bX, Y, bY, ⟨H₀.1.symm, H₀.2.symm⟩, Hₛ, ⟨u, hu, ne2, ppu, hX.symm, hY.symm⟩⟩,
   by rintro (H | ⟨X, bX, Y, bY, H₀, Hₛ, ⟨u, hu, ne2, ppu, hX, hY⟩⟩)
      · exact Or.inl H
      · exact Or.inr ⟨X, bX, Y, bY, ⟨H₀.1.symm, H₀.2.symm⟩, Hₛ, ⟨u, hu, ne2, ppu, hX.symm, hY.symm⟩⟩⟩

def Exp.def : Σᴬ[0] 2 := ⟨
  “(#0 = 0 ∧ #1 = 1) ∨ (
    ∃[#0 < #2 * #2 * #2 * #2 + 1] ∃[#0 < #3 * #3 * #3 * #3 + 1] (
      (!extdef [1, 4, #1] ∧ !extdef [2, 4, #0]) ∧
      !Exp.Seqₛ.def [#3, #1, #0] ∧
      ∃[#0 < #4 * #4 + 1] (#0 ≠ 2 ∧ !ppow2def [#0] ∧ !extdef [#3, #0, #2] ∧!extdef [#4, #0, #1])))”, by { simp }⟩

lemma Exp.defined : Σᴬ[0]-Relation (Exp : M → M → Prop) Exp.def := by
  intro v; simp [Exp.graph_iff, Exp.def, ppow2_defined.pval, ext_defined.pval, Exp.Seqₛ.defined.pval, ←le_iff_lt_succ, pow_four, sq]

instance {b s} : DefinableRel b s (Exp : M → M → Prop) := defined_to_with_param₀ _ Exp.defined

namespace Exp

def seqX₀ : M := 4

def seqY₀ : M := 2 * 4

lemma one_lt_four : (1 : M) < 4 := by
  rw [←three_add_one_eq_four]
  exact lt_add_of_pos_left 1 three_pos

lemma two_lt_three : (2 : M) < 3 := by rw [←two_add_one_eq_three]; exact lt_add_one 2

lemma three_lt_four : (3 : M) < 4 := by rw [←three_add_one_eq_four]; exact lt_add_one 3

lemma two_lt_four : (2 : M) < 4 := lt_trans _ _ _ two_lt_three three_lt_four

lemma seq₀_zero_two : Seq₀ (seqX₀ : M) (seqY₀ : M) := by simp [seqX₀, seqY₀, Seq₀, ext, one_lt_four, two_lt_four]

lemma Seq₀.rem {X Y i : M} (h : Seq₀ X Y) (ppi : PPow2 i) (hi : 4 < i) :
    Seq₀ (X mod i) (Y mod i) := by
  rw [Seq₀, ext_rem, ext_rem] <;> try simp [ppi, hi]
  exact h

lemma Seqₛ.rem {y y' X Y i : M} (h : Seqₛ y X Y) (ppi : PPow2 i) (hi : y'^2 < i) (hy : y' ≤ y) :
    Seqₛ y' (X mod i) (Y mod i) := by
  intro j hj ne2 ppj
  have : j^2 < i := lt_of_le_of_lt (sq_le_sq_iff.mp hj) hi
  have : j < i := lt_of_le_of_lt (le_trans hj $ by simp) hi
  rcases h j (le_trans hj hy) ne2 ppj with (H | H)
  · left; simpa [Seqₛ.Even, ext_rem, ppj, ppj.sq, ppi, *] using H
  · right; simpa [Seqₛ.Odd, ext_rem, ppj, ppj.sq, ppi, *] using H

lemma seqₛ_one_zero_two : Seqₛ (1 : M) (seqX₀ : M) (seqY₀ : M) := by
  intro u leu; rcases le_one_iff_eq_zero_or_one.mp leu with (rfl | rfl) <;> simp

def append (i X z : M) : M := (X mod i) + z * i

lemma append_lt (i X : M) {z} (hz : z < i) : append i X z < i^2 := calc
  append i X z = (X mod i) + z * i := rfl
  _            < (1 + z) * i       := by simp [add_mul]; exact remainder_lt _ (pos_of_gt hz)
  _            ≤ i^2               := by simp [sq, add_comm]; exact mul_le_mul_of_nonneg_right (lt_iff_succ_le.mp hz) (by simp)

lemma ext_append_last (i X : M) {z} (hz : z < i) :
    ext i (append i X z) = z := by
  simp [ext, append, div_add_mul_self, show 0 < i from pos_of_gt hz, hz]

lemma ext_append_of_lt {i j : M} (hi : PPow2 i) (hj : PPow2 j) (hij : i < j) (X z : M) :
    ext i (append j X z) = ext i X := by
  have : i^2 ∣ j := Pow2.dvd_of_le hi.pow2.sq hj.pow2 (PPow2.sq_le_of_lt hi hj hij)
  calc
    ext i (append j X z) = ext i ((X mod j) + z * j)       := rfl
    _                    = ext i (X mod j)                 := ext_add_of_dvd_sq_right hi.pos (Dvd.dvd.mul_left this z)
    _                    = ext i (j * (X / j) + (X mod j)) := by rw [add_comm]; refine Eq.symm <| ext_add_of_dvd_sq_right hi.pos (Dvd.dvd.mul_right this _)
    _                    = ext i X                         := by simp [div_add_remainder]

lemma Seq₀.append {X Y i x y : M} (H : Seq₀ X Y) (ppi : PPow2 i) (hi : 4 < i) :
    Seq₀ (append i X x) (append i Y y) := by
  rw [Seq₀, ext_append_of_lt, ext_append_of_lt] <;> try simp [ppi, hi]
  exact H

lemma Seqₛ.append {z x y X Y i : M} (h : Seqₛ z X Y) (ppi : PPow2 i) (hz : z < i) :
    Seqₛ z (append (i^2) X x) (append (i^2) Y y) := by
  intro j hj ne2 ppj
  have : j < i^2 := lt_of_lt_of_le (lt_of_le_of_lt hj hz) (by simp)
  have : j^2 < i^2 := sq_lt_sq_iff.mp (lt_of_le_of_lt hj hz)
  rcases h j hj ne2 ppj with (H | H) <;> simp [Even, Odd]
  · left; rw [ext_append_of_lt, ext_append_of_lt, ext_append_of_lt, ext_append_of_lt] <;> try simp [ppi.sq, ppj.sq, *]
    exact H
  · right; rw [ext_append_of_lt, ext_append_of_lt, ext_append_of_lt, ext_append_of_lt] <;> try simp [ppi.sq, ppj.sq, *]
    exact H

@[simp] lemma exp_zero_one : Exp (0 : M) 1 := Or.inl (by simp)

@[simp] lemma exp_one_two : Exp (1 : M) 2 :=
  Or.inr ⟨
    4, by simp [pow_four_eq_sq_sq, two_pow_two_eq_four],
    2 * 4, by simp [pow_four_eq_sq_sq, two_pow_two_eq_four, sq (4 : M)]; exact le_of_lt two_lt_four,
    by simp [Seq₀, ext, one_lt_four, two_lt_four],
    by simp [Seqₛ]; intro i hi ne2 ppi; exact False.elim <| not_le.mpr (ppi.two_lt ne2) hi,
    ⟨4, by simp [two_pow_two_eq_four], by simp, by simp [ext, one_lt_four, two_lt_four]⟩⟩

lemma pow2_ext_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : Pow2 (ext i Y) := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ei : i = 4
    · rcases ei with rfl; simp [h₀.2]
    · have ppsq : Pow2 (ext (√i) Y) :=
        IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ei) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ei) (ppi.sqrt ne2) with (heven | hodd)
      · have : ext i Y = (ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using heven.2
        simp [this, ppsq]
      · have : ext i Y = 2*(ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using hodd.2
        simp [this, ppsq]

lemma range_pow2 {x y : M} (h : Exp x y) : Pow2 y := by
  rcases h with (⟨rfl, rfl⟩ | ⟨X, bX, Y, bY, H₀, Hₛ, ⟨u, hu, ne2, ppu, rfl, rfl⟩⟩)
  · simp
  · exact pow2_ext_of_seq₀_of_seqₛ H₀ Hₛ ne2 hu ppu

lemma le_sq_ext_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : i ≤ (ext i Y)^2 := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ei : i = 4
    · rcases ei with rfl; simp [h₀.2, two_pow_two_eq_four]
    · have IH : √i ≤ (ext (√i) Y)^2 :=
        IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ei) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ei) (ppi.sqrt ne2) with (heven | hodd)
      · have : ext i Y = (ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using heven.2
        have : √i ≤ ext i Y := by simpa [this] using IH
        simpa [ppi.sq_sqrt_eq ne2] using sq_le_sq_iff.mp this
      · have : ext i Y = 2*(ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using hodd.2
        have : 2 * √i ≤ ext i Y := by simpa [this] using mul_le_mul_left (a := 2) IH
        have : √i ≤ ext i Y := le_trans (le_mul_of_pos_left $ by simp) this
        simpa [ppi.sq_sqrt_eq ne2] using sq_le_sq_iff.mp this

example {a b c : ℕ} : a * (b * c) = b * (a * c) := by exact Nat.mul_left_comm a b c

lemma two_mul_ext_le_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : 2 * ext i Y ≤ i := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ei : i = 4
    · rcases ei with rfl; simp [h₀.2, two_mul_two_eq_four]
    · have IH : 2 * ext (√i) Y ≤ √i :=
        IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ei) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ei) (ppi.sqrt ne2) with (heven | hodd)
      · have : ext i Y = (ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using heven.2
        calc
          2 * ext i Y ≤ 2 * (2 * ext i Y)  := le_mul_of_pos_left (by simp)
          _           = (2 * ext (√i) Y)^2 := by simp [this, sq, mul_left_comm, mul_assoc]
          _           ≤ (√i)^2             := sq_le_sq_iff.mp IH
          _           = i                  := ppi.sq_sqrt_eq ne2
      · have : ext i Y = 2*(ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2] using hodd.2
        calc
          2 * ext i Y = (2 * ext (√i) Y)^2 := by simp [this, sq, mul_left_comm, mul_assoc]
          _           ≤ (√i)^2             := sq_le_sq_iff.mp IH
          _           = i                  := ppi.sq_sqrt_eq ne2

lemma exp_exists_sq_of_exp_even {x y : M} : Exp (2 * x) y → ∃ y', y = y'^2 ∧ Exp x y' := by
  rintro (⟨hx, rfl⟩ | ⟨X, _, Y, _, hseq₀, hseqₛ, i, hi, ne2, ppi, hXx, hYy⟩)
  · exact ⟨1, by simp [show x = 0 from by simpa using hx]⟩
  by_cases ne4 : i = 4
  · rcases ne4 with rfl
    have ex : 1 = 2 * x := by simpa [hseq₀.1] using hXx
    have : (2 : M) ∣ 1 := by rw [ex]; simp
    have : ¬(2 : M) ∣ 1 := not_dvd_of_lt (by simp) one_lt_two
    contradiction
  have : Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) :=
    hseqₛ (√i) (sqrt_le_of_le_sq hi) (ppi.sqrt_ne_two ne2 ne4) (ppi.sqrt ne2)
  rcases this with (⟨hXi, hYi⟩ | ⟨hXi, _⟩)
  · have hXx : x = ext (√i) X := by simpa [ppi.sq_sqrt_eq ne2, hXx] using hXi
    have hYy : y = (ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2, hYy] using hYi
    let X' := X mod i
    let Y' := Y mod i
    have bX' : X' ≤ (ext (√i) Y)^4 := by simp [pow_four_eq_sq_sq, ←hYy]; exact le_trans (le_of_lt $ by simp [ppi.pos]) hi
    have bY' : Y' ≤ (ext (√i) Y)^4 := by simp [pow_four_eq_sq_sq, ←hYy]; exact le_trans (le_of_lt $ by simp [ppi.pos]) hi
    have hseqₛ' : Seqₛ (ext (√i) Y) X' Y' :=
      hseqₛ.rem ppi (sq_lt_of_lt_sqrt $ ext_lt Y (ppi.sqrt ne2).pos) (by simp [hYy])
    have hseqₘ' : Seqₘ x (ext (√i) Y) X' Y' :=
      ⟨√i, sqrt_le_of_le_sq $ by simp [←hYy, hi], ppi.sqrt_ne_two ne2 ne4, ppi.sqrt ne2,
       by have : √i < i := sqrt_lt_self_of_one_lt ppi.one_lt
          simp [this, ext_rem, ppi, ppi.sqrt ne2, hXx]⟩
    have : Exp x (ext (√i) Y) :=
      Or.inr ⟨X', bX', Y', bY', hseq₀.rem ppi (ppi.four_lt ne2 ne4), hseqₛ', hseqₘ'⟩
    exact ⟨ext (√i) Y, hYy, this⟩
  · have : 2 ∣ ext i X := by simp [hXx]
    have : ¬2 ∣ ext i X := by
      simp [show ext i X = 2 * ext (√i) X + 1 from by simpa [ppi.sq_sqrt_eq ne2] using hXi,
        ←remainder_eq_zero_iff_dvd, one_lt_two]
    contradiction

lemma bit_zero {x y : M} : Exp x y → Exp (2 * x) (y ^ 2) := by
  rintro (⟨hx, rfl⟩ | ⟨X, _, Y, _, hseq₀, hseqₛ, i, hi, ne2, ppi, hXx, hYy⟩)
  · rcases hx with rfl; simp
  have hxsqi : 2 * x < i ^ 2 := lt_of_lt_of_le (by simp [←hXx, ppi.pos]) (two_mul_le_sq ppi.two_le)
  have hysqi : y ^ 2 < i ^ 2 := sq_lt_sq_iff.mp $ by simp [←hYy, ppi.pos]
  have hiisq : i < i^2 := lt_square_of_lt ppi.one_lt
  let X' := append (i^2) X (2 * x)
  let Y' := append (i^2) Y (y ^ 2)
  have bX' : X' ≤ (y^2)^4 := by
    have : X' < i^4 := by simpa [pow_four_eq_sq_sq] using append_lt (i^2) X hxsqi
    exact le_trans (le_of_lt this) (pow_le_pow_left (by simp) hi 4)
  have bY' : Y' ≤ (y^2)^4 := by
    have : Y' < i^4 := by simpa [pow_four_eq_sq_sq] using append_lt (i^2) Y hysqi
    exact le_trans (le_of_lt this) (pow_le_pow_left (by simp) hi 4)
  have hseq₀' : Seq₀ X' Y' := hseq₀.append ppi.sq (ppi.sq.four_lt ppi.sq_ne_two (ppi.sq_ne_four ne2))
  have hseqₛ' : Seqₛ (y ^ 2) X' Y' := by
    intro j hj jne2 ppj
    by_cases hjy : j ≤ y
    · have : Seqₛ y X' Y' := hseqₛ.append ppi (by simp [←hYy, ppi.pos])
      exact this j hjy jne2 ppj
    · have : i = j := by
        have : Pow2 y := by simpa [hYy] using pow2_ext_of_seq₀_of_seqₛ hseq₀ hseqₛ ne2 hi ppi
        exact PPow2.sq_uniq this ppi ppj
          ⟨by simp [←hYy, ppi.pos], hi⟩ ⟨by simpa using hjy, hj⟩
      rcases this with rfl
      left; simp [Seqₛ.Even]
      rw [ext_append_last, ext_append_last, ext_append_of_lt , ext_append_of_lt] <;>
        simp [ppi, ppi.sq, hxsqi, hysqi, hiisq, hXx, hYy]
  have hseqₘ' : Seqₘ (2 * x) (y ^ 2) X' Y' :=
    ⟨i ^ 2, sq_le_sq_iff.mp hi, ppi.sq_ne_two, ppi.sq,
     by simp; rw [ext_append_last, ext_append_last] <;> try simp [hxsqi, hysqi]⟩
  exact Or.inr <| ⟨X', bX', Y', bY', hseq₀', hseqₛ', hseqₘ'⟩

lemma exp_even {x y : M} : Exp (2 * x) y ↔ ∃ y', y = y'^2 ∧ Exp x y' :=
  ⟨exp_exists_sq_of_exp_even, by rintro ⟨y, rfl, h⟩; exact bit_zero h⟩

lemma exp_even_sq {x y : M} : Exp (2 * x) (y ^ 2) ↔ Exp x y :=
  ⟨by intro h
      rcases exp_exists_sq_of_exp_even h with ⟨y', e, h⟩
      simpa [show y = y' from by simpa using e] using h,
   bit_zero⟩

lemma exp_exists_sq_of_exp_odd {x y : M} : Exp (2 * x + 1) y → ∃ y', y = 2 * y'^2 ∧ Exp x y' := by
  rintro (⟨hx, rfl⟩ | ⟨X, _, Y, _, hseq₀, hseqₛ, i, hi, ne2, ppi, hXx, hYy⟩)
  · simp at hx
  by_cases ne4 : i = 4
  · rcases ne4 with rfl
    have ex : x = 0 := by simpa [hseq₀.1] using hXx
    have ey : y = 2 := by simpa [hseq₀.2] using Eq.symm hYy
    exact ⟨1, by simp [ex, ey]⟩
  have : Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) :=
    hseqₛ (√i) (sqrt_le_of_le_sq hi) (ppi.sqrt_ne_two ne2 ne4) (ppi.sqrt ne2)
  rcases this with (⟨hXi, _⟩ | ⟨hXi, hYi⟩)
  · have hXx : 2 * x + 1 = 2 * ext (√i) X := by simpa [ppi.sq_sqrt_eq ne2, hXx] using hXi
    have : 2 ∣ 2 * x + 1 := by rw [hXx]; simp
    have : ¬2 ∣ 2 * x + 1 := by simp [←remainder_eq_zero_iff_dvd, one_lt_two]
    contradiction
  · have hXx : x = ext (√i) X := by simpa [ppi.sq_sqrt_eq ne2, hXx] using hXi
    have hYy : y = 2 * (ext (√i) Y)^2 := by simpa [ppi.sq_sqrt_eq ne2, hYy] using hYi
    let X' := X mod i
    let Y' := Y mod i
    have bsqi : √i ≤ (ext (√i) Y)^2 := le_sq_ext_of_seq₀_of_seqₛ hseq₀ hseqₛ (ppi.sqrt_ne_two ne2 ne4) (le_trans (by simp) hi) (ppi.sqrt ne2)
    have bi : i ≤ ext (√i) Y^4 := by simpa [pow_four_eq_sq_sq, ppi.sq_sqrt_eq ne2] using sq_le_sq_iff.mp bsqi
    have bX' : X' ≤ (ext (√i) Y)^4 := le_trans (le_of_lt $ by simp [ppi.pos]) bi
    have bY' : Y' ≤ (ext (√i) Y)^4 := le_trans (le_of_lt $ by simp [ppi.pos]) bi
    have hseqₛ' : Seqₛ (ext (√i) Y) X' Y' :=
      hseqₛ.rem ppi (sq_lt_of_lt_sqrt $ ext_lt Y (ppi.sqrt ne2).pos) (le_trans (le_sq _)
        (by simp [hYy]))
    have hseqₘ' : Seqₘ x (ext (√i) Y) X' Y' :=
      ⟨√i, bsqi, ppi.sqrt_ne_two ne2 ne4, ppi.sqrt ne2,
       by have : √i < i := sqrt_lt_self_of_one_lt ppi.one_lt
          simp [this, ext_rem, ppi, ppi.sqrt ne2, hXx]⟩
    have : Exp x (ext (√i) Y) :=
      Or.inr ⟨X', bX', Y', bY', hseq₀.rem ppi (ppi.four_lt ne2 ne4), hseqₛ', hseqₘ'⟩
    exact ⟨ext (√i) Y, hYy, this⟩

lemma bit_one {x y : M} : Exp x y → Exp (2 * x + 1) (2 * y ^ 2) := by
  rintro (⟨hx, rfl⟩ | ⟨X, _, Y, _, hseq₀, hseqₛ, i, hi, ne2, ppi, hXx, hYy⟩)
  · rcases hx with rfl; simp
  have hxsqi : 2 * x + 1 < i ^ 2 := calc
    2 * x + 1 < 2 * i + 1 := by simp [←hXx, ppi.pos]
    _         ≤ i ^ 2     := lt_iff_succ_le.mp (two_mul_lt_sq $ ppi.two_lt ne2)
  have hysqi : 2 * y ^ 2 < i ^ 2 := by
    have : 2 * ext i Y ≤ i := two_mul_ext_le_of_seq₀_of_seqₛ hseq₀ hseqₛ ne2 hi ppi
    suffices : 2 * (2 * y ^ 2) < 2 * i ^ 2
    · exact lt_of_mul_lt_mul_left this
    calc
      2 * (2 * y ^ 2) = (2 * y)^2 := by simp [sq, mul_assoc, mul_left_comm y 2]
      _               ≤ i^2       := sq_le_sq_iff.mp (by simpa [hYy] using this)
      _               < 2 * i^2   := lt_mul_of_one_lt_left ppi.sq.pos one_lt_two
  have hiisq : i < i^2 := lt_square_of_lt ppi.one_lt
  let X' := append (i^2) X (2 * x + 1)
  let Y' := append (i^2) Y (2 * (y^2))
  have bX' : X' ≤ (2 * y ^ 2)^4 := by
    have : X' < i^4 := by simpa [pow_four_eq_sq_sq] using append_lt (i^2) X hxsqi
    exact le_trans (le_of_lt this) (pow_le_pow_left (by simp) (le_trans hi $ by simp) 4)
  have bY' : Y' ≤ (2 * y ^ 2)^4 := by
    have : Y' < i^4 := by simpa [pow_four_eq_sq_sq] using append_lt (i^2) Y hysqi
    exact le_trans (le_of_lt this) (pow_le_pow_left (by simp) (le_trans hi $ by simp) 4)
  have hseq₀' : Seq₀ X' Y' := hseq₀.append ppi.sq (ppi.sq.four_lt ppi.sq_ne_two (ppi.sq_ne_four ne2))
  have hseqₛ' : Seqₛ (2 * y ^ 2) X' Y' := by
    intro j hj jne2 ppj
    by_cases hjy : j ≤ y
    · have : Seqₛ y X' Y' := hseqₛ.append ppi (by simp [←hYy, ppi.pos])
      exact this j hjy jne2 ppj
    · have : i = j := by
        have : Pow2 y := by simpa [hYy] using pow2_ext_of_seq₀_of_seqₛ hseq₀ hseqₛ ne2 hi ppi
        exact PPow2.two_mul_sq_uniq this ppi ppj
          ⟨by simp [←hYy, ppi.pos], le_trans hi (by simp)⟩ ⟨by simpa using hjy, hj⟩
      rcases this with rfl
      right; simp [Seqₛ.Odd]
      rw [ext_append_last, ext_append_last, ext_append_of_lt , ext_append_of_lt] <;>
        simp [ppi, ppi.sq, hxsqi, hysqi, hiisq, hXx, hYy]
  have hseqₘ' : Seqₘ (2 * x + 1) (2 * y ^ 2) X' Y' :=
    ⟨i ^ 2, sq_le_sq_iff.mp (le_trans hi $ by simp), ppi.sq_ne_two, ppi.sq,
     by simp; rw [ext_append_last, ext_append_last] <;> try simp [hxsqi, hysqi]⟩
  exact Or.inr <| ⟨X', bX', Y', bY', hseq₀', hseqₛ', hseqₘ'⟩

lemma exp_odd {x y : M} : Exp (2 * x + 1) y ↔ ∃ y', y = 2 * y' ^ 2 ∧ Exp x y' :=
  ⟨exp_exists_sq_of_exp_odd, by rintro ⟨y, rfl, h⟩; exact bit_one h⟩

lemma exp_odd_two_mul_sq {x y : M} : Exp (2 * x + 1) (2 * y ^ 2) ↔ Exp x y :=
  ⟨by intro h
      rcases exp_exists_sq_of_exp_odd h with ⟨y', e, h⟩
      simpa [show y = y' from by simpa using e] using h,
   bit_one⟩

lemma two_le_ext_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : 2 ≤ ext i Y := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ei : i = 4
    · rcases ei with rfl; simp [h₀.2]
    · have IH : 2 ≤ ext (√i) Y :=
        IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ei) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ei) (ppi.sqrt ne2) with (heven | hodd)
      · calc
          2 ≤ ext (√i) Y     := IH
          _ ≤ (ext (√i) Y)^2 := by simp
          _ = ext i Y        := by simpa [ppi.sq_sqrt_eq ne2] using Eq.symm heven.2
      · calc
          2 ≤ ext (√i) Y         := IH
          _ ≤ (ext (√i) Y)^2     := by simp
          _ ≤ 2 * (ext (√i) Y)^2 := by simp
          _ = ext i Y            := by simpa [ppi.sq_sqrt_eq ne2] using Eq.symm hodd.2

lemma ext_le_ext_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : ext i X < ext i Y := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ne4 : i = 4
    · rcases ne4 with rfl; simp [h₀.1, h₀.2, one_lt_two]
    · have IH : ext (√i) X < ext (√i) Y :=
      IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ne4) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ne4) (ppi.sqrt ne2) with (heven | hodd)
      · calc
          ext i X = 2 * ext (√i) X := by simpa [ppi.sq_sqrt_eq ne2] using heven.1
          _       < 2 * ext (√i) Y := by simpa using IH
          _       ≤ ext (√i) Y^2   := two_mul_le_sq (two_le_ext_of_seq₀_of_seqₛ h₀ hₛ (ppi.sqrt_ne_two ne2 ne4) (le_trans (by simp) hi) (ppi.sqrt ne2))
          _       = ext i Y        := by simpa [ppi.sq_sqrt_eq ne2] using Eq.symm heven.2
      · calc
          ext i X = 2 * ext (√i) X + 1 := by simpa [ppi.sq_sqrt_eq ne2] using hodd.1
          _       < 2 * ext (√i) Y + 1 := by simpa using IH
          _       ≤ 2 * ext (√i) Y^2   := lt_iff_succ_le.mp
            (by simp [sq]; exact lt_mul_self (lt_iff_succ_le.mpr $ by
                  simp [one_add_one_eq_two]; exact (two_le_ext_of_seq₀_of_seqₛ h₀ hₛ (ppi.sqrt_ne_two ne2 ne4) (le_trans (by simp) hi) (ppi.sqrt ne2))))
          _       = ext i Y            := by simpa [ppi.sq_sqrt_eq ne2] using Eq.symm hodd.2

lemma range_pos {x y : M} (h : Exp x y) : 0 < y := by
  rcases h with (⟨rfl, rfl⟩ | ⟨X, bX, Y, bY, H₀, Hₛ, ⟨u, hu, ne2, ppu, rfl, rfl⟩⟩)
  · simp
  · have : 2 ≤ ext u Y := two_le_ext_of_seq₀_of_seqₛ H₀ Hₛ ne2 hu ppu
    exact lt_of_lt_of_le (by simp) this

lemma dom_lt_range {x y : M} (h : Exp x y) : x < y := by
  rcases h with (⟨rfl, rfl⟩ | ⟨X, bX, Y, bY, H₀, Hₛ, ⟨u, hu, ne2, ppu, rfl, rfl⟩⟩)
  · simp
  · exact ext_le_ext_of_seq₀_of_seqₛ H₀ Hₛ ne2 hu ppu

lemma not_exp_of_le {x y : M} (h : x ≤ y) : ¬Exp y x := by
  intro hxy; exact not_le.mpr (dom_lt_range hxy) h

@[simp] lemma one_not_even (a : M) : 1 ≠ 2 * a := by
  intro h
  have : (2 : M) ∣ 1 := by rw [h]; simp
  have : ¬(2 : M) ∣ 1 := not_dvd_of_lt (by simp) one_lt_two
  contradiction

@[simp] lemma exp_two_four : Exp (2 : M) 4 := by
  simpa [two_pow_two_eq_four] using (show Exp (1 : M) 2 from by simp).bit_zero

lemma exp_succ {x y : M} : Exp (x + 1) y ↔ ∃ z, y = 2 * z ∧ Exp x z := by
  suffices : x < y → (Exp (x + 1) y ↔ ∃ z ≤ y, y = 2 * z ∧ Exp x z)
  · by_cases hxy : x < y
    · simp [this hxy]
      exact ⟨by rintro ⟨z, _, rfl, hz⟩; exact ⟨z, rfl, hz⟩,
             by rintro ⟨z, rfl, hz⟩; exact ⟨z, by simpa using hz⟩⟩
    · simp [not_exp_of_le (show y ≤ x + 1 from le_add_right (by simpa using hxy))]
      rintro z rfl
      exact not_exp_of_le (le_trans le_two_mul_left $  by simpa using hxy)
  · revert x
    induction y using hierarchy_order_induction_sigma₀
    · definability
    case ind y IH =>
      intro x hxy
      rcases even_or_odd x with ⟨x, (rfl | rfl)⟩
      · constructor
        · intro H
          rcases exp_odd.mp H with ⟨y, rfl, H'⟩
          exact ⟨y^2, by simp, rfl, H'.bit_zero⟩
        · rintro ⟨y, hy, rfl, H⟩
          rcases exp_even.mp H with ⟨y, rfl, H'⟩
          exact H'.bit_one
      · constructor
        · intro H
          have : Exp (2 * (x + 1)) y := by simpa [mul_add, add_assoc, one_add_one_eq_two] using H
          rcases exp_even.mp this with ⟨y, rfl, H'⟩
          have : 1 < y := by
            simpa using (show 1 < y^2 from lt_of_le_of_lt (by simp) hxy)
          have : Exp (x + 1) y ↔ ∃ z ≤ y, y = 2 * z ∧ Exp x z :=
            IH y (lt_square_of_lt $ this) (lt_trans _ _ _ (by simp) H'.dom_lt_range)
          rcases this.mp H' with ⟨y, _, rfl, H''⟩
          exact ⟨2 * y ^ 2, by simp [sq, mul_assoc, mul_left_comm y 2],
            by simp [sq, mul_assoc, mul_left_comm y 2], H''.bit_one⟩
        · rintro ⟨y, _, rfl, H⟩
          rcases exp_odd.mp H with ⟨y, rfl, H'⟩
          by_cases ne1 : y = 1
          · rcases ne1 with rfl
            rcases (show x = 0 from by simpa using H'.dom_lt_range)
            simp [one_add_one_eq_two, two_mul_two_eq_four]
          have : y < y^2 := lt_square_of_lt $ one_lt_iff_two_le.mpr $ H'.range_pow2.two_le ne1
          have : Exp (x + 1) (2 * y) ↔ ∃ z ≤ 2 * y, 2 * y = 2 * z ∧ Exp x z :=
            IH (2 * y) (by simp; exact lt_of_lt_of_le this le_two_mul_left)
              (lt_of_lt_of_le H'.dom_lt_range $ by simp)
          have : Exp (x + 1) (2 * y) := this.mpr ⟨y, by simp, rfl, H'⟩
          simpa [sq, mul_add, add_assoc, mul_assoc, one_add_one_eq_two, mul_left_comm y 2] using this.bit_zero

lemma exp_succ_mul_two {x y : M} : Exp (x + 1) (2 * y) ↔ Exp x y :=
  ⟨by intro h; rcases exp_succ.mp h with ⟨y', e, h⟩; simpa [show y = y' from by simpa using e] using h,
   by intro h; exact exp_succ.mpr ⟨y, rfl, h⟩⟩

lemma one_le_ext_of_seq₀_of_seqₛ {y X Y : M} (h₀ : Exp.Seq₀ X Y) (hₛ : Exp.Seqₛ y X Y)
    {i} (ne2 : i ≠ 2) (hi : i ≤ y^2) (ppi : PPow2 i) : 1 ≤ ext i X := by
  revert ne2 hi ppi
  induction i using hierarchy_order_induction_sigma₀
  · definability
  case ind i IH =>
    intro ne2 hi ppi
    by_cases ne4 : i = 4
    · rcases ne4 with rfl; simp [h₀.1, h₀.2, one_lt_two]
    · have IH : 1 ≤ ext (√i) X :=
      IH (√i) (sqrt_lt_self_of_one_lt ppi.one_lt) (ppi.sqrt_ne_two ne2 ne4) (le_trans (by simp) hi) (ppi.sqrt ne2)
      rcases show Seqₛ.Even X Y (√i) ∨ Seqₛ.Odd X Y (√i) from
        hₛ (√i) (sqrt_le_of_le_sq $ hi) (ppi.sqrt_ne_two ne2 ne4) (ppi.sqrt ne2) with (heven | hodd)
      · have : ext i X = 2 * ext (√i) X := by simpa [ppi.sq_sqrt_eq ne2] using heven.1
        exact le_trans IH (by simp [this])
      · have : ext i X = 2 * ext (√i) X + 1 := by simpa [ppi.sq_sqrt_eq ne2] using hodd.1
        simp [this]

lemma zero_uniq {y : M} (h : Exp 0 y) : y = 1 := by
  rcases h with (⟨_, rfl⟩ | ⟨X, _, Y, _, H₀, Hₛ, ⟨u, hu, ne2, ppu, hX, _⟩⟩)
  · rfl
  · have : 1 ≤ ext u X  := one_le_ext_of_seq₀_of_seqₛ H₀ Hₛ ne2 hu ppu
    simp [hX] at this

lemma succ_lt_s {y : M} (h : Exp (x + 1) y) : 2 ≤ y := by
  rcases h with (⟨h, rfl⟩ | ⟨X, _, Y, _, H₀, Hₛ, ⟨u, hu, ne2, ppu, _, hY⟩⟩)
  · simp at h
  · simpa [hY] using two_le_ext_of_seq₀_of_seqₛ H₀ Hₛ ne2 hu ppu

protected lemma uniq {x y₁ y₂ : M} : Exp x y₁ → Exp x y₂ → y₁ = y₂ := by
  intro h₁ h₂
  wlog h : y₁ ≤ y₂
  · exact Eq.symm <| this h₂ h₁ (show y₂ ≤ y₁ from le_of_not_ge h)
  revert x h y₁
  suffices : ∀ x < y₂, ∀ y₁ ≤ y₂, Exp x y₁ → Exp x y₂ → y₁ = y₂
  · intro x y₁ h₁ h₂ hy; exact this x h₂.dom_lt_range y₁ hy h₁ h₂
  induction y₂ using hierarchy_order_induction_sigma₀
  · definability
  case ind y₂ IH =>
    intro x _ y₁ h h₁ h₂
    rcases zero_or_succ x with (rfl | ⟨x, rfl⟩)
    · simp [h₁.zero_uniq, h₂.zero_uniq]
    · rcases exp_succ.mp h₁ with ⟨y₁, rfl, h₁'⟩
      rcases exp_succ.mp h₂ with ⟨y₂, rfl, h₂'⟩
      have : y₁ = y₂ := IH y₂ (lt_mul_of_pos_of_one_lt_left h₂'.range_pos one_lt_two)
        x h₂'.dom_lt_range y₁ (by simpa using h) h₁' h₂'
      simp [this]

protected lemma inj {x₁ x₂ y : M} : Exp x₁ y → Exp x₂ y → x₁ = x₂ := by
  intro h₁ h₂
  revert x₁ x₂ h₁ h₂
  suffices : ∀ x₁ < y, ∀ x₂ < y, Exp x₁ y → Exp x₂ y → x₁ = x₂
  · intro x₁ x₂ h₁ h₂; exact this x₁ h₁.dom_lt_range x₂ h₂.dom_lt_range h₁ h₂
  induction y using hierarchy_order_induction_sigma₀
  · definability
  case ind y IH =>
    intro x₁ _ x₂ _ h₁ h₂
    rcases zero_or_succ x₁ with (rfl | ⟨x₁, rfl⟩) <;> rcases zero_or_succ x₂ with (rfl | ⟨x₂, rfl⟩)
    · rfl
    · rcases h₁.zero_uniq
      rcases exp_succ.mp h₂ with ⟨z, hz⟩
      simp at hz
    · rcases h₂.zero_uniq
      rcases exp_succ.mp h₁ with ⟨z, hz⟩
      simp at hz
    · rcases exp_succ.mp h₁ with ⟨y, rfl, hy₁⟩
      have hy₂ : Exp x₂ y := exp_succ_mul_two.mp h₂
      have : x₁ = x₂ :=
        IH y (lt_mul_of_pos_of_one_lt_left hy₁.range_pos one_lt_two)
          x₁ hy₁.dom_lt_range x₂ hy₂.dom_lt_range hy₁ hy₂
      simp [this]

lemma exp_elim {x y : M} : Exp x y ↔ (x = 0 ∧ y = 1) ∨ ∃ x', ∃ y', x = x' + 1 ∧ y = 2 * y' ∧ Exp x' y' :=
  ⟨by intro h
      rcases zero_or_succ x with (rfl | ⟨x', rfl⟩)
      · simp [h.zero_uniq]
      · right; rcases exp_succ.mp h with ⟨y', rfl, H⟩
        exact ⟨x', y', rfl, rfl, H⟩,
   by rintro (⟨rfl, rfl⟩ | ⟨x, y, rfl, rfl, h⟩)
      · simp
      · exact exp_succ_mul_two.mpr h⟩

lemma monotone {x₁ x₂ y₁ y₂ : M} : Exp x₁ y₁ → Exp x₂ y₂ → x₁ < x₂ → y₁ < y₂ := by
  revert x₁ x₂ y₂
  suffices : ∀ x₁ < y₁, ∀ y₂ ≤ y₁, ∀ x₂ < y₂, Exp x₁ y₁ → Exp x₂ y₂ → x₂ ≤ x₁
  · intro x₁ x₂ y₂ h₁ h₂; contrapose; simp
    intro hy
    exact this x₁ h₁.dom_lt_range y₂ hy x₂ h₂.dom_lt_range h₁ h₂
  induction y₁ using hierarchy_order_induction_sigma₀
  · definability
  case ind y₁ IH =>
    intro x₁ _ y₂ hy x₂ _ h₁ h₂
    rcases zero_or_succ x₁ with (rfl | ⟨x₁, rfl⟩) <;> rcases zero_or_succ x₂ with (rfl | ⟨x₂, rfl⟩)
    · simp
    · rcases show y₁ = 1 from h₁.zero_uniq
      rcases le_one_iff_eq_zero_or_one.mp hy with (rfl | rfl)
      · have := h₂.range_pos; simp at this
      · exact False.elim <| not_lt.mpr h₂.succ_lt_s one_lt_two
    · simp
    · rcases exp_succ.mp h₁ with ⟨y₁, rfl, h₁'⟩
      rcases exp_succ.mp h₂ with ⟨y₂, rfl, h₂'⟩
      have : x₂ ≤ x₁ := IH y₁ (lt_mul_of_pos_of_one_lt_left h₁'.range_pos one_lt_two)
        x₁ h₁'.dom_lt_range y₂ (le_of_mul_le_mul_left hy (by simp)) x₂ h₂'.dom_lt_range h₁' h₂'
      simpa using this

lemma monotone_le {x₁ x₂ y₁ y₂ : M} (h₁ : Exp x₁ y₁) (h₂ : Exp x₂ y₂) : x₁ ≤ x₂ → y₁ ≤ y₂ := by
  rintro (rfl | h)
  · exact (h₁.uniq h₂).le
  · exact le_of_lt (monotone h₁ h₂ h)

lemma monotone_iff {x₁ x₂ y₁ y₂ : M} (h₁ : Exp x₁ y₁) (h₂ : Exp x₂ y₂) : x₁ < x₂ ↔ y₁ < y₂ := by
  constructor
  · exact monotone h₁ h₂
  · contrapose; simp; exact monotone_le h₂ h₁

lemma add_mul {x₁ x₂ y₁ y₂ : M} (h₁ : Exp x₁ y₁) (h₂ : Exp x₂ y₂) : Exp (x₁ + x₂) (y₁ * y₂) := by
  wlog hy : y₁ ≥ y₂
  · simpa [add_comm, mul_comm] using this h₂ h₁ (le_of_not_ge hy)
  revert y₂
  suffices : ∀ y₂ ≤ y₁, Exp x₂ y₂ → Exp (x₁ + x₂) (y₁ * y₂)
  · intro y₂ h₂ hy; exact this y₂ hy h₂
  induction x₂ using hierarchy_induction_sigma₀
  · definability
  case zero =>
    intro y₂ _ h₂
    simpa [show y₂ = 1 from h₂.zero_uniq] using h₁
  case succ x₂ IH =>
    intro y₂ hy h₂
    rcases exp_succ.mp h₂ with ⟨y₂, rfl, H₂⟩
    have : Exp (x₁ + x₂) (y₁ * y₂) := IH y₂ (le_trans (by simp) hy) H₂
    simpa [←add_assoc, mul_left_comm y₁ 2 y₂] using exp_succ_mul_two.mpr this

end Exp

lemma log_exists_unique_pos {y : M} (hy : 0 < y) : ∃! x, x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y' := by
  have : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y' := by
    revert hy
    induction y using hierarchy_polynomial_induction_sigma₀
    · definability
    case zero => simp
    case even y IH =>
      intro hy
      rcases (IH (by simpa using hy) : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') with ⟨x, hxy, y', gey, H, lty⟩
      exact ⟨x + 1, lt_of_lt_of_le (by simp [hxy]) (succ_le_double_of_pos (pos_of_gt hxy)),
        2 * y', by simpa using gey, Exp.exp_succ_mul_two.mpr H, by simpa using lty⟩
    case odd y IH =>
      intro hy
      rcases (zero_le y : 0 ≤ y) with (rfl | pos)
      · simp; exact ⟨1, by simp [one_lt_two]⟩
      · rcases (IH pos : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') with ⟨x, hxy, y', gey, H, lty⟩
        exact ⟨x + 1, by simp; exact lt_of_lt_of_le hxy (by simp),
          2 * y', le_trans (by simpa using gey) le_self_add, Exp.exp_succ_mul_two.mpr H, two_mul_add_one_lt_two_mul_of_lt lty⟩
  rcases this with ⟨x, hx⟩
  exact ExistsUnique.intro x hx (fun x' ↦ by
    intro hx'
    by_contra A
    wlog lt : x < x'
    · exact this hy x' hx' x hx (Ne.symm A) (lt_of_le_of_ne (by simpa using lt) A)
    rcases hx with ⟨_, z, _, H, hyz⟩
    rcases hx' with ⟨_, z', hzy', H', _⟩
    have : z < z' := Exp.monotone H H' lt
    have : y < y := calc
      y < 2 * z := hyz
      _ ≤ z'    := (Pow2.lt_iff_two_mul_le H.range_pow2 H'.range_pow2).mp this
      _ ≤ y     := hzy'
    simp at this)

lemma log_exists_unique (y : M) : ∃! x, (y = 0 → x = 0) ∧ (0 < y → x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') := by
  by_cases hy : y = 0
  · rcases hy; simp
  · simp [hy, pos_iff_ne_zero.mpr hy, log_exists_unique_pos]

def log (a : M) : M := Classical.choose! (log_exists_unique a)

@[simp] lemma log_zero : log (0 : M) = 0 :=
  (Classical.choose!_spec (log_exists_unique (0 : M))).1 rfl

lemma log_pos {y : M} (pos : 0 < y) : ∃ y' ≤ y, Exp (log y) y' ∧ y < 2 * y' :=
  ((Classical.choose!_spec (log_exists_unique y)).2 pos).2

lemma log_lt_self_of_pos {y : M} (pos : 0 < y) : log y < y :=
  ((Classical.choose!_spec (log_exists_unique y)).2 pos).1

@[simp] lemma log_le_self (a : M) : log a ≤ a := by
  rcases zero_le a with (rfl | pos)
  · simp
  · exact le_of_lt <| log_lt_self_of_pos pos

lemma log_graph {x y : M} : x = log y ↔ (y = 0 → x = 0) ∧ (0 < y → x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') := Classical.choose!_eq_iff _

def logdef : Σᴬ[0] 2 := ⟨“(#1 = 0 → #0 = 0) ∧ (0 < #1 → #0 < #1 ∧ ∃[#0 < #2 + 1] (!Exp.def [#1, #0] ∧ #2 < 2 * #0))”, by simp⟩

lemma log_defined : Σᴬ[0]-Function₁ (log : M → M) logdef := by
  intro v; simp [logdef, log_graph, Exp.defined.pval, ←le_iff_lt_succ]

instance {b s} : DefinableFunction₁ b s (log : M → M) := defined_to_with_param₀ _ log_defined

instance : PolyBounded₁ (log : M → M) := ⟨#0, λ _ ↦ by simp⟩

lemma log_eq_of_pos {x y : M} (pos : 0 < y) {y'} (H : Exp x y') (hy' : y' ≤ y) (hy : y < 2 * y') : log y = x :=
  (log_exists_unique_pos pos).unique ⟨log_lt_self_of_pos pos, log_pos pos⟩ ⟨lt_of_lt_of_le H.dom_lt_range hy', y', hy', H, hy⟩

@[simp] lemma log_one : log (1 : M) = 0 := log_eq_of_pos (by simp) (y' := 1) (by simp) (by rfl) (by simp [one_lt_two])

lemma log_two_mul_of_pos {y : M} (pos : 0 < y) : log (2 * y) = log y + 1 := by
  rcases log_pos pos with ⟨y', hy', H, hy⟩
  exact log_eq_of_pos (by simpa using pos) (Exp.exp_succ_mul_two.mpr H) (by simpa using hy') (by simpa using hy)

lemma log_two_mul_add_one_of_pos {y : M} (pos : 0 < y) : log (2 * y + 1) = log y + 1 := by
  rcases log_pos pos with ⟨y', hy', H, hy⟩
  exact log_eq_of_pos (by simp) (Exp.exp_succ_mul_two.mpr H)
    (le_trans (by simpa using hy') le_self_add) (two_mul_add_one_lt_two_mul_of_lt hy)

lemma log_eq_of_exp {x y : M} (H : Exp x y) : log y = x :=
  log_eq_of_pos H.range_pos H (by { rfl }) (lt_mul_of_pos_of_one_lt_left H.range_pos one_lt_two)

lemma exp_of_pow2 {p : M} (pp : Pow2 p) : Exp (log p) p := by
  rcases log_pos pp.pos with ⟨q, hq, H, hp⟩
  suffices : p = q
  · simpa [this] using H
  by_contra ne
  have : q < p := lt_of_le_of_ne hq (Ne.symm ne)
  have : 2 * q < 2 * q := calc
    2 * q ≤ p     := (Pow2.lt_iff_two_mul_le H.range_pow2 pp).mp this
    _     < 2 * q := hp
  simp at this

lemma log_mul_pow2 {a p : M} (pos : 0 < a) (pp : Pow2 p) : log (a * p) = log a + log p := by
  rcases log_pos pos with ⟨a', ha', Ha, ha⟩
  rcases log_pos pp.pos with ⟨p', hp', Hp, hp⟩
  exact log_eq_of_pos (mul_pos pos pp.pos) (Exp.add_mul Ha Hp) (mul_le_mul' ha' hp') (by
    rcases Hp.uniq (exp_of_pow2 pp)
    simp [←mul_assoc]; exact mul_lt_mul_of_pos_right ha pp.pos)

def binaryLength (a : M) : M := if 0 < a then log a + 1 else 0

notation "‖" a "‖" => binaryLength a

@[simp] lemma binary_length_zero : ‖(0 : M)‖ = 0 := by simp [binaryLength]

lemma binary_length_of_pos {a : M} (pos : 0 < a) : ‖a‖ = log a + 1 := by simp [binaryLength, pos]

@[simp] lemma binary_length_le (a : M) : ‖a‖ ≤ a := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [pos, binary_length_of_pos, ←lt_iff_succ_le, log_lt_self_of_pos]

lemma binary_length_graph {i a : M} : i = ‖a‖ ↔ (0 < a → ∃ k ≤ a, k = log a ∧ i = k + 1) ∧ (a = 0 → i = 0) := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [binary_length_of_pos, pos, pos_iff_ne_zero.mp pos]
    constructor
    · rintro rfl; exact ⟨log a, by simp⟩
    · rintro ⟨_, _, rfl, rfl⟩; rfl

def binarylengthdef : Σᴬ[0] 2 := ⟨“(0 < #1 → ∃[#0 < #2 + 1] (!logdef [#0, #2] ∧ #1 = #0 + 1)) ∧ (#1 = 0 → #0 = 0)”, by simp⟩

lemma binary_length_defined : Σᴬ[0]-Function₁ (binaryLength : M → M) binarylengthdef := by
  intro v; simp [binarylengthdef, binary_length_graph, log_defined.pval, ←le_iff_lt_succ]

instance {b s} : DefinableFunction₁ b s (binaryLength : M → M) := defined_to_with_param₀ _ binary_length_defined

instance : PolyBounded₁ (binaryLength : M → M) := ⟨#0, λ _ ↦ by simp⟩

@[simp] lemma binary_length_one : ‖(1 : M)‖ = 1 := by simp [binaryLength]

lemma binary_length_two_mul_of_pos {a : M} (pos : 0 < a) : ‖2 * a‖ = ‖a‖ + 1 := by
  simp [pos, binary_length_of_pos, log_two_mul_of_pos]

lemma binary_length_two_mul_add_one (a : M) : ‖2 * a + 1‖ = ‖a‖ + 1 := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [pos, binary_length_of_pos, log_two_mul_add_one_of_pos]

lemma binary_length_mul_pow2 {a p : M} (pos : 0 < a) (pp : Pow2 p) : ‖a * p‖ = ‖a‖ + log p := by
  simp [binary_length_of_pos, pos, pp.pos, log_mul_pow2 pos pp, add_right_comm (log a) (log p) 1]

end ISigma₀

section ISigma₁

variable [𝐈𝚺₁.Mod M]

namespace Exp

lemma range_exists (x : M) : ∃ y, Exp x y := by
  induction x using hierarchy_induction_sigma₁
  · definability
  case zero => exact ⟨1, by simp⟩
  case succ x IH =>
    rcases IH with ⟨y, IH⟩
    exact ⟨2 * y, exp_succ_mul_two.mpr IH⟩

lemma range_exists_unique (x : M) : ∃! y, Exp x y := by
  rcases range_exists x with ⟨y, h⟩
  exact ExistsUnique.intro y h (by intro y' h'; exact h'.uniq h)

end Exp

def exponential (a : M) : M := Classical.choose! (Exp.range_exists_unique a)

prefix:80 "exp " => exponential

section exponential

lemma exp_exponential (a : M) : Exp a (exp a) := Classical.choose!_spec (Exp.range_exists_unique a)

lemma exponential_graph {a b : M} : a = exp b ↔ Exp b a := Classical.choose!_eq_iff _

def expdef : Σᴬ[0] 2 := ⟨“!Exp.def [#1, #0]”, by simp⟩

lemma exp_defined : Σᴬ[0]-Function₁ (exponential : M → M) expdef := by
  intro v; simp [expdef, exponential_graph, Exp.defined.pval]

instance {b s} : DefinableFunction₁ b s (exponential : M → M) := defined_to_with_param₀ _ exp_defined

lemma exponential_of_exp {a b : M} (h : Exp a b) : exp a = b :=
  Eq.symm <| exponential_graph.mpr h

lemma exponential_inj : Function.Injective (exponential : M → M) := λ a _ H ↦
  (exp_exponential a).inj (exponential_graph.mp H)

@[simp] lemma exp_zero : exp (0 : M) = 1 := exponential_of_exp (by simp)

@[simp] lemma exp_one : exp (1 : M) = 2 := exponential_of_exp (by simp)

lemma exp_succ (a : M) : exp (a + 1) = 2 * exp a :=
  exponential_of_exp <| Exp.exp_succ_mul_two.mpr <| exp_exponential a

lemma exp_even (a : M) : exp (2 * a) = (exp a)^2 :=
  exponential_of_exp <| Exp.exp_even_sq.mpr <| exp_exponential a

@[simp] lemma lt_exp (a : M) : a < exp a := (exp_exponential a).dom_lt_range

@[simp] lemma exp_pos (a : M) : 0 < exp a := (exp_exponential a).range_pos

@[simp] lemma exp_pow2 (a : M) : Pow2 (exp a) := (exp_exponential a).range_pow2

@[simp] lemma exponential_monotone {a b : M} : exp a < exp b ↔ a < b :=
  Iff.symm <| Exp.monotone_iff (exp_exponential a) (exp_exponential b)

@[simp] lemma log_exponential (a : M) : log (exp a) = a := log_eq_of_exp (exp_exponential a)

@[simp] lemma binary_length_exponential (a : M) : ‖exp a‖ = a + 1 := by
  simp [binary_length_of_pos]

lemma exp_add (a b : M) : exp (a + b) = exp a * exp b :=
  exponential_of_exp (Exp.add_mul (exp_exponential a) (exp_exponential b))

lemma log_mul_exp {a : M} (pos : 0 < a) (i : M) : log (a * exp i) = log a + i := by
  simp [log_mul_pow2 pos (exp_pow2 i)]

lemma binary_length_mul_exp {a : M} (pos : 0 < a) (i : M) : ‖a * exp i‖ = ‖a‖ + i := by
  simp [binary_length_mul_pow2 pos (exp_pow2 i)]

end exponential

end ISigma₁

end Model

end

end Arith

end LO.FirstOrder
