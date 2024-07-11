import Arithmetization.ISigmaOne.Metamath.Formula.Functions
import Arithmetization.Definability.Absoluteness

noncomputable section

namespace LO.Arith

open FirstOrder FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

/-- TOFO: move to PeanoMinus -/
@[simp] lemma nat_cast_inj {n m : ℕ} : (n : V) = (m : V) ↔ n = m := by
  induction' n with n ih
  · cases m <;> simp
  · cases m <;> simp

lemma nat_cast_empty : ((∅ : ℕ) : V) = ∅ := rfl

def finArrowToVec : {k : ℕ} → (Fin k → V) → V
  | 0,     _ => 0
  | k + 1, v => v 0 ∷ finArrowToVec (k := k) (v ·.succ)

/-- quasi-quotation rather than Godel quotation -/
instance : GoedelQuote (Fin k → V) V := ⟨finArrowToVec⟩

lemma quote_matrix_def (v : Fin k → V) : ⌜v⌝ = finArrowToVec v := rfl

@[simp] lemma quote_nil : (⌜(![] : Fin 0 → V)⌝ : V) = 0 := rfl

@[simp] lemma quote_singleton (a : V) : (⌜![a]⌝ : V) = ?[a] := rfl

@[simp] lemma quote_doubleton (a b : V) : (⌜![a, b]⌝ : V) = ?[a, b] := rfl

@[simp] lemma quote_matrix_empty (v : Fin 0 → V) :
    (⌜v⌝ : V) = 0 := by rfl

lemma quote_matrix_succ (v : Fin (k + 1) → V) :
    (⌜v⌝ : V) = v 0 ∷ ⌜fun i : Fin k ↦ v i.succ⌝ := by simp [quote_matrix_def, finArrowToVec]

@[simp] lemma quote_cons (v : Fin k → V) (a : V) :
    (⌜a :> v⌝ : V) = a ∷ ⌜v⌝  := by simp [quote_matrix_succ]

@[simp] lemma quote_lh (v : Fin k → V) : len (⌜v⌝ : V) = k := by
  induction' k with k ih <;> simp [quote_matrix_succ, Matrix.empty_eq, *]

@[simp] lemma quote_nth_fin (v : Fin k → V) (i : Fin k) : (⌜v⌝ : V).[i] = v i := by
  induction' k with k ih <;> simp [quote_matrix_succ]
  · exact i.elim0
  · cases' i using Fin.cases with i <;> simp [ih]

lemma quote_matrix_absolute (v : Fin k → ℕ) : ((⌜v⌝ : ℕ) : V) = ⌜fun i ↦ (v i : V)⌝ := by
  induction' k with k ih
  · simp
  · simp [quote_matrix_succ, ih, cons_absolute]

end LO.Arith

namespace LO.FirstOrder.Semiterm

open LO.Arith FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

variable (V)

def codeIn {n} : SyntacticSemiterm L n → V
  | #z                    => ^#z
  | &x                    => ^&x
  | func (arity := k) f v => ^func (k : V) ⌜f⌝ ⌜fun i ↦ (v i).codeIn⌝

instance : GoedelQuote (SyntacticSemiterm L n) V := ⟨(·.codeIn V)⟩

lemma quote_syntacticSemiterm_def (t : SyntacticSemiterm L n) : ⌜t⌝ = t.codeIn V := rfl

lemma quote_bvar (z : Fin n) : ⌜(#z : SyntacticSemiterm L n)⌝ = ^#(z : V) := rfl

lemma quote_fvar (x : ℕ) : ⌜(&x : SyntacticSemiterm L n)⌝ = ^&(x : V) := rfl

lemma quote_func {k} (f : L.Func k) (v : Fin k → SyntacticSemiterm L n) :
    ⌜func f v⌝ = ^func (k : V) ⌜f⌝ ⌜fun i ↦ ⌜v i⌝⌝ := rfl

end LO.FirstOrder.Semiterm

namespace LO.Arith

open FirstOrder FirstOrder.Semiterm FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

/-- TODO: move-/
lemma eq_fin_of_lt_nat {n : ℕ} {x : V} (hx : x < n) : ∃ i : Fin n, x = i := by
  rcases eq_nat_of_lt_nat hx with ⟨x, rfl⟩
  exact ⟨⟨x, by simpa using hx⟩, by simp⟩

@[simp] lemma semiterm_codeIn {n} (t : SyntacticSemiterm L n) :
    (L.codeIn V).Semiterm n ⌜t⌝ := by
  induction t <;> simp [quote_bvar, quote_fvar, quote_func]
  case func k f v ih =>
    exact ⟨by simp, by
      rintro i hi
      rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
      simpa using ih i⟩

@[simp] lemma semitermVec_codeIn {k n} (v : Fin k → SyntacticSemiterm L n) :
    (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ :=
  ⟨by simp, by intro i hi; rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩; simp⟩

lemma termSubst_quote {n m} (t : SyntacticSemiterm L n) (w : Fin n → SyntacticSemiterm L m) :
    (L.codeIn V).termSubst ↑n ↑m ⌜fun i ↦ ⌜w i⌝⌝ ⌜t⌝ = ⌜Rew.substs w t⌝ := by
  induction t
  case bvar z => simp [quote_bvar, quote_fvar, quote_func]
  case fvar x => simp [quote_bvar, quote_fvar, quote_func]
  case func k f v ih =>
    have Hw : (L.codeIn V).SemitermVec n m ⌜fun i ↦ ⌜w i⌝⌝ := semitermVec_codeIn w
    have Hv : (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ := semitermVec_codeIn v
    simp only [Rew.func, Semiterm.quote_func, codeIn_func_quote, termSubst_func (codeIn_func_quote f) Hv]
    congr
    apply nth_ext (by simp [←Hw.termSubstVec Hv |>.lh])
    intro i hi
    have hi : i < k := by simpa [← Hw.termSubstVec Hv |>.lh] using hi
    rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
    simpa [nth_termSubstVec] using ih i

lemma termSubstVec_quote {k n m} (w : Fin n → SyntacticSemiterm L m) (v : Fin k → SyntacticSemiterm L n) :
    (L.codeIn V).termSubstVec ↑k ↑n ↑m ⌜fun i ↦ ⌜w i⌝⌝ ⌜fun i => ⌜v i⌝⌝ = ⌜fun i ↦ ⌜(Rew.substs w) (v i)⌝⌝ := by
  have Hw : (L.codeIn V).SemitermVec n m ⌜fun i ↦ ⌜w i⌝⌝ := semitermVec_codeIn w
  have Hv : (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ := semitermVec_codeIn v
  apply nth_ext (by simp [←Hw.termSubstVec Hv |>.lh])
  intro i hi
  have hi : i < k := by simpa [← Hw.termSubstVec Hv |>.lh] using hi
  rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
  simpa [nth_termSubstVec] using termSubst_quote (v i) w

lemma termShift_quote {n} (t : SyntacticSemiterm L n) :
    (L.codeIn V).termShift n ⌜t⌝ = ⌜Rew.shift t⌝ := by
  induction t
  case bvar => simp [quote_bvar, quote_fvar, quote_func]
  case fvar => simp [quote_bvar, quote_fvar, quote_func]
  case func k f v ih =>
    have Hv : (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ := semitermVec_codeIn v
    simp only [Rew.func, Semiterm.quote_func, codeIn_func_quote, termShift_func (codeIn_func_quote f) Hv]
    congr
    apply nth_ext (by simp [←Hv.termShiftVec |>.lh])
    intro i hi
    have hi : i < k := by simpa [← Hv.termShiftVec |>.lh] using hi
    rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
    simpa [nth_termShiftVec] using ih i

lemma termShiftVec_quote {k n} (v : Fin k → SyntacticSemiterm L n) :
    (L.codeIn V).termShiftVec k n ⌜fun i ↦ ⌜v i⌝⌝ = ⌜fun i ↦ ⌜Rew.shift (v i)⌝⌝ := by
  have Hv : (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ := semitermVec_codeIn v
  apply nth_ext (by simp [←Hv.termShiftVec |>.lh])
  intro i hi
  have hi : i < k := by simpa [← Hv.termShiftVec |>.lh] using hi
  rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
  simpa [nth_termShiftVec] using termShift_quote (v i)

lemma termBShift_quote {n} (t : SyntacticSemiterm L n) :
    (L.codeIn V).termBShift n ⌜t⌝ = ⌜Rew.bShift t⌝ := by
  induction t
  case bvar => simp [quote_bvar, quote_fvar, quote_func]
  case fvar => simp [quote_bvar, quote_fvar, quote_func]
  case func k f v ih =>
    have Hv : (L.codeIn V).SemitermVec k n ⌜fun i ↦ ⌜v i⌝⌝ := semitermVec_codeIn v
    simp only [Rew.func, Semiterm.quote_func, codeIn_func_quote, termBShift_func (codeIn_func_quote f) Hv]
    congr
    apply nth_ext (by simp [←Hv.termBShiftVec |>.lh])
    intro i hi
    have hi : i < k := by simpa [← Hv.termBShiftVec |>.lh] using hi
    rcases eq_fin_of_lt_nat hi with ⟨i, rfl⟩
    simpa [nth_termBShiftVec] using ih i

end LO.Arith

namespace LO.FirstOrder.Semiformula

open LO.Arith FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

variable (V)

def codeIn : {n : ℕ} → SyntacticSemiformula L n → V
  | n, rel (arity := k) R v  => ^rel (n : V) (k : V) ⌜R⌝ ⌜fun i ↦ ⌜v i⌝⌝
  | n, nrel (arity := k) R v => ^nrel (n : V) (k : V) ⌜R⌝ ⌜fun i ↦ ⌜v i⌝⌝
  | n, ⊤                     => ^⊤[n]
  | n, ⊥                     => ^⊥[n]
  | n, p ⋏ q                 => p.codeIn ^⋏[n] q.codeIn
  | n, p ⋎ q                 => p.codeIn ^⋎[n] q.codeIn
  | n, ∀' p                  => ^∀[n] p.codeIn
  | n, ∃' p                  => ^∃[n] p.codeIn

instance : GoedelQuote (SyntacticSemiformula L n) V := ⟨codeIn V⟩

lemma quote_syntacticSemiformula_def (p : SyntacticSemiformula L n) : ⌜p⌝ = p.codeIn V := rfl

lemma quote_rel {k} (R : L.Rel k) (v : Fin k → SyntacticSemiterm L n) :
    (⌜rel R v⌝ : V) = ^rel ↑n ↑k ⌜R⌝ ⌜fun i ↦ ⌜v i⌝⌝ := rfl
lemma quote_nrel {k} (R : L.Rel k) (v : Fin k → SyntacticSemiterm L n) :
    (⌜nrel R v⌝ : V) = ^nrel ↑n ↑k ⌜R⌝ ⌜fun i ↦ ⌜v i⌝⌝ := rfl
lemma quote_verum (n : ℕ) : ⌜(⊤ : SyntacticSemiformula L n)⌝ = ^⊤[(n : V)] := rfl
lemma quote_falsum (n : ℕ) : ⌜(⊥ : SyntacticSemiformula L n)⌝ = ^⊥[(n : V)] := rfl
lemma quote_and (p q : SyntacticSemiformula L n) : ⌜p ⋏ q⌝ = ⌜p⌝ ^⋏[(n : V)] ⌜q⌝ := rfl
lemma quote_or (p q : SyntacticSemiformula L n) : ⌜p ⋎ q⌝ = ⌜p⌝ ^⋎[(n : V)] ⌜q⌝ := rfl
lemma quote_all (p : SyntacticSemiformula L (n + 1)) : ⌜∀' p⌝ = ^∀[(n : V)] ⌜p⌝ := rfl
lemma quote_ex (p : SyntacticSemiformula L (n + 1)) : ⌜∃' p⌝ = ^∃[(n : V)] ⌜p⌝ := rfl

end LO.FirstOrder.Semiformula

namespace LO.Arith

open FirstOrder FirstOrder.Arith FirstOrder.Semiformula

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

@[simp] lemma semiformula_quote {n} (p : SyntacticSemiformula L n) :
    (L.codeIn V).Semiformula n ⌜p⌝ := by
  induction p using Semiformula.rec'
  case hrel n k r v => simp [Semiformula.quote_rel]
  case hnrel n k r v => simp [Semiformula.quote_nrel]
  case hverum n => simp [Semiformula.quote_verum]
  case hfalsum n => simp [Semiformula.quote_falsum]
  case hand n p q ihp ihq => simp [Semiformula.quote_and, ihp, ihq]
  case hor n p q ihp ihq => simp [Semiformula.quote_or, ihp, ihq]
  case hall n p ihp => simpa [Semiformula.quote_all] using ihp
  case hex n p ihp => simpa [Semiformula.quote_ex] using ihp

@[simp] lemma semiformula_quote_succ {n} (p : SyntacticSemiformula L (n + 1)) :
    (L.codeIn V).Semiformula (n + 1) ⌜p⌝ := by simpa using semiformula_quote p

lemma neg_quote {n} (p : SyntacticSemiformula L n) :
    (L.codeIn V).neg ⌜p⌝ = ⌜~p⌝ := by
  induction p using Semiformula.rec' <;>
    simp [*, quote_rel, quote_nrel, quote_verum, quote_falsum, quote_and, quote_or, quote_all, quote_ex]

lemma shift_quote {n} (p : SyntacticSemiformula L n) :
    (L.codeIn V).shift ⌜p⌝ = ⌜Rew.shift.hom p⌝ := by
  induction p using Semiformula.rec' <;>
    simp [*, quote_rel, quote_nrel, quote_verum, quote_falsum, quote_and, quote_or, quote_all, quote_ex,
      Rew.rel, Rew.nrel, termShiftVec_quote]

lemma qVec_quote (w : Fin n → SyntacticSemiterm L m) :
    (L.codeIn V).qVec ↑n ↑m ⌜fun i => ⌜w i⌝⌝ = ⌜^#0 :> fun i ↦ (⌜Rew.bShift (w i)⌝ : V)⌝ := by
  have Hw : (L.codeIn V).SemitermVec ↑n (↑m + 1) ((L.codeIn V).termBShiftVec ↑n ↑m ⌜fun i ↦ ⌜w i⌝⌝) :=
    (semitermVec_codeIn w).termBShiftVec
  have HqVec : (L.codeIn V).SemitermVec (↑n + 1) (↑m + 1) ((L.codeIn V).qVec ↑n ↑m ⌜fun i ↦ ⌜w i⌝⌝) :=
    (semitermVec_codeIn w).qVec
  apply nth_ext (by simp [←HqVec.lh])
  intro i hi
  have : i < ↑(n + 1) := by simpa [Language.qVec, ←Hw.lh] using hi
  rcases eq_fin_of_lt_nat this with ⟨i, rfl⟩
  cases' i using Fin.cases with i
  · simp [Language.qVec]
  · simp [Language.qVec, termBShift_quote]

lemma substs_quote {n m} (w : Fin n → SyntacticSemiterm L m) (p : SyntacticSemiformula L n) :
    (L.codeIn V).substs ↑m ⌜fun i ↦ ⌜w i⌝⌝ ⌜p⌝ = ⌜(Rew.substs w).hom p⌝ := by
  induction p using Semiformula.rec' generalizing m <;>
    simp [*, quote_rel, quote_nrel, quote_verum, quote_falsum, quote_and, quote_or, quote_all, quote_ex,
      Rew.rel, Rew.nrel, termSubstVec_quote, Rew.q_substs]
  case hall p ih => simp [←ih, qVec_quote, Semiterm.quote_bvar]
  case hex p ih => simp [←ih, qVec_quote, Semiterm.quote_bvar]

end LO.Arith

end
