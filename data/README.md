# `data/` — Simulation & Analysis Output Directory

Every file in this tree is **produced by the analysis scripts** at the
repository root. Each sub-directory corresponds to one script (or to
`main.m`), and ships pre-computed so that figures can be verified without
re-running the (time-consuming) loops.

> **File format:** all `.dat` files are plain-text, comma-separated,
> CRLF-delimited matrices read directly by MATLAB `load`.
> All `.mat` files store a single variable whose name is given below.
>
> **Convention:** for a distribution matrix, **rows = time steps**
> (t = 0 … 70 days, Δh = 0.5, hence 141 interior steps → up to 143 rows
> depending on the saving routine) and **columns = spatial nodes**
> x = 0 … 1 with N = 101.

---

## Sub-directory ↔ script map

| Sub-directory | Produced by | Figures | Contents |
|:--------------|:-----------|:-------|:---------|
| `basic/`      | `main.m`            | Fig. 1, Fig. 2 | baseline simulation |
| `PRCC/`       | `cal_fig3.m`        | Fig. 3         | local PRCC sensitivity |
| `par-dist/`   | `cal_fig4.m`        | Fig. 4         | ν / σ single-parameter perturbation |
| `fix_mac/`    | `cal_fig5.m`        | Fig. 5         | fixed-macrophage experiments |
| `par-ratio/`  | `cal_fig6.m`        | Fig. 6         | 1-D parameter sweeps |
| `double_par/` | `cal_fig7.m`        | Fig. 7         | 2-D parameter sweeps |

---

## File-by-file detail

### `basic/`  — baseline (`main.m`)

| File | Shape | Variable / source | Note |
|:-----|:-----:|:-----------------|:-----|
| `tumor.dat` | 143 × 101 | `writematrix` in `main.m` | Distribution Q(x,t) over the full 70-day run; read by `pic_fig1.m` / `pic_fig2.m` |

### `PRCC/`  — local PRCC sensitivity (`cal_fig3.m`)

100 LHS samples over 12 parameters; the script saves `ALL.mat` plus five
small text files consumed by `pic_fig3.m`.

| File | Shape | Variable | Note |
|:-----|:-----:|:---------|:-----|
| `ALL.mat`   | 100 × 12 | `ALL`        | full LHS + outputs matrix (~10 MB) |
| `para_mat.dat` | 100 × 12 | —         | LHS design matrix (raw) |
| `target_p.dat` | 100 × 1  | —          | proliferation target per run |
| `target_r.dat` | 100 × 1  | —          | EMT-ratio target per run |
| `p_p.dat`   | 1 × 12  | —          | PRCC of proliferation vs. each of 12 params |
| `p_r.dat`   | 1 × 12  | —          | PRCC of EMT ratio vs. each of 12 params |

### `par-dist/`  — ν / σ perturbation (`cal_fig4.m`)

For each of ν ∈ {40, 60, 80} and σ ∈ {2, 4, 6}, one distribution snapshot
(5 rows × 101 columns) is saved; read by `pic_fig4.m`.

| File | Shape | Parameter value |
|:-----|:-----:|:----------------|
| `nu1.dat` / `nu2.dat` / `nu3.dat`     | 5 × 101 | ν = 40 / 60 / 80 |
| `sigma1.dat` / `sigma2.dat` / `sigma3.dat` | 5 × 101 | σ = 2 / 4 / 6 |

### `fix_mac/`  — fixed-macrophage experiments (`cal_fig5.m`)

Four fixed-macrophage polarisation conditions, each a full 143 × 101
distribution; read by `pic_fig5.m`.

| File | Shape | Condition |
|:-----|:-----:|:---------|
| `no_mac.dat` | 143 × 101 | no macrophages |
| `mac_I.dat`  | 143 × 101 | fixed M1-dominant |
| `mac_II.dat` | 143 × 101 | fixed M2-dominant |
| `mac_mix.dat`| 143 × 101 | fixed 50:50 mixture |

### `par-ratio/`  — 1-D sweeps (`cal_fig6.m`)

Each script saves variable **`A`** (stack of 100 sweep results, ~10 MB),
read by `pic_fig6.m`.

| File | Variable | Swept parameter |
|:-----|:--------:|:---------------|
| `L_beta.mat` | `A` | λ_β |
| `L_mu.mat`   | `A` | λ_μ |
| `K_Q.mat`    | `A` | K_Q |

### `double_par/`  — 2-D sweeps (`cal_fig7.m`)

For each pair the script saves the raw simulation stack **`A`** and a
small derived plotting array **`D`**. Only the 20 KB `*_D.mat` files are
shipped in this repository; the three ~92 MB raw `A` arrays are
intentionally omitted (they are regenerable).

| File | Shape / size | Variable | Shipped? |
|:-----|:-----------:|:---------|:--------:|
| `beta_mu_D.mat`  | 20 KB | `D` | ✅ yes |
| `mu_KQ_D.mat`    | 20 KB | `D` | ✅ yes |
| `KQ_beta_D.mat`  | 20 KB | `D` | ✅ yes |
| `beta_mu.mat`    | ~92 MB | `A` | ❌ re-run `cal_fig7` |
| `mu_KQ.mat`      | ~92 MB | `A` | ❌ re-run `cal_fig7` |
| `KQ_beta.mat`    | ~92 MB | `A` | ❌ re-run `cal_fig7` |

`pic_fig7.m` plots the three 2-D surfaces
(λ_β–λ_μ, λ_μ–K_Q, K_Q–λ_β) **from the `_D.mat` files only**, so
Figure 7 can be reproduced from the shipped data.

---

## Regenerating anything here

From the repository root:

```matlab
main()        % → basic/tumor.dat
cal_fig3()    % → PRCC/*
cal_fig4()    % → par-dist/*
cal_fig5()    % → fix_mac/*
cal_fig6()    % → par-ratio/*   (overwrites the three 10 MB .mat)
cal_fig7()    % → double_par/*  (recreates the omitted 92 MB raw arrays)
```

The pre-computed `.mat` files checked into this repository exist so that
reviewers can verify Figures 3–7 without re-running these loops; delete
them and re-run the matching `cal_figN()` to reproduce.
