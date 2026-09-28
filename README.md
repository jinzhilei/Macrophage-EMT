# Multi-Scale Mathematical Model: Macrophage-Regulated EMT in Squamous Cell Carcinoma

MATLAB implementation of the phase-structured integro-differential model
for the epithelial-to-mesenchymal transition (EMT) process in cutaneous
squamous cell carcinoma (SCC), incorporating a continuous macrophage
polarization spectrum as a quasi-steady sub-model.

> **Paper**: "Multiscale Mathematical Modeling of Macrophage Regulation of
> the EMT Process in Squamous Cell Carcinoma" — *SIAM J. Life Sci.*, 2026.

---

## Prerequisites

- **MATLAB R2020b or later**
- **Statistics and Machine Learning Toolbox** (for `partialcorr`)
- **Optimization Toolbox** *not* required (no optimisation is performed here)
- All `.dat` files are plain-text, comma-separated, CRLF-delimited.
  MATLAB's built-in `load` handles them directly — no custom parser needed.

---

## Directory Layout

```
Code_to_Github/
├── main.m                     ← entry point: baseline simulation (Fig. 1, Fig. 2)
├── control.m                  ← global time step τ, spatial step h, end time, N
├── parameter.m                ← global model parameters (Table 1 of the paper)
├── initial.m                  ← initial distribution Q₀(x) = Beta(2,10)·10⁴
├── solve.m                    ← forward-Euler time integrator (with delay τ)
├── fun.m                      ← RHS of the phase-structured PDE (call it "ODE")
├── Dynamic.m                  ← dynamic β(x), κ(x), μ  (macrophage-coupled)
├── Inherit.m                  ← epigenetic inheritance kernel P(x|y)
├── Integral.m                 ← composite Simpson quadrature (local function)
├── Distribution_mac.m         ← quasi-steady macrophage polarization Beta(φ)
│
├── cal_fig3.m                 ← local PRCC sensitivity analysis (100 LHS × 12 params)
├── cal_fig4.m                 ← single-parameter perturbation: ν ∈ {40,60,80}, σ ∈ {2,4,6}
├── cal_fig5.m                 ← fixed-macrophage experiments (no-mac, M1, MII, mix)
├── cal_fig6.m                 ← parameter sweeps: λ_β, λ_μ, K_Q (100 points each)
├── cal_fig7.m                 ← two-dimensional sweeps: (λ_β,λ_μ), (λ_μ,K_Q), (K_Q,λ_β)
├── virtual.m                  ← 100 virtual mice, untreated → notreat/all_data.mat
├── virtual_treat.m            ← 100 virtual mice, anti-CSF-1R → treat/all_data.mat
│
├── pic_fig1.m … pic_fig7.m    ← plotting scripts (one per figure)
├── pic_fig_other.m            ← combined Fig. 10–11 plotter (reads virtual_data/ data of plot + all_data.mat)
│
├── input/
│   ├── week3-4.dat            ← MCMC posterior draws, weeks 3–4 (6 × 6)
│   ├── week7-8.dat            ← MCMC posterior draws, weeks 7–8 (6 × 6)
│   ├── heterogeneity data.xlsx← raw Excel source (optional)
│   ├── better_par.dat         ← top-90 MCMC samples (90 × 12), not used in .m scripts
│   └── Excel_data.m           ← helper: extract week3-4 / week7-8 from xlsx
│
├── data/
│   ├── basic/tumor.dat        ← 143 × 101 grid: output of main.m
│   ├── PRCC/                  ← outputs of cal_fig3.m (ALL.mat is 10M; *.dat are small)
│   ├── par-dist/              ← outputs of cal_fig4.m
│   ├── fix_mac/               ← outputs of cal_fig5.m
│   ├── par-ratio/             ← outputs of cal_fig6.m (3 × 10M .mat)
│   └── double_par/            ← outputs of cal_fig7.m (3 × 20K _D.mat kept; 3 × 92M raw .mat omitted)
│
└── virtual_data/
    ├── cal_fig8.m             ← posterior statistics from para_10000.dat
    ├── pic_fig8.m … pic_fig11.m
    ├── virtual mouse/
    │   ├── mouse.dat          ← 100 × 4 seed parameters (β, μ, ν, σ)
    │   └── para_10000.dat     ← 10 000 × 13 MCMC posterior draws
    ├── notreat/all_data.mat   ← 100 virtual mice, untreated (output of virtual.m)
    ├── treat/all_data.mat     ← 100 virtual mice, anti-CSF-1R (output of virtual_treat.m)
    └── data of plot/         ← pre-computed posterior summaries for Fig. 8
```

---

## How to Run

All scripts are **functions** — call them from the MATLAB Command Window
or a wrapper script. Set the working directory to the repository root
(or add it to the path) before running.

### Step 0 — Set up

```matlab
cd /path/to/Code_to_Github
addpath(genpath('.'))
```

### Step 1 — Baseline simulation (reproduces Fig. 1 & Fig. 2)

```matlab
main()        % writes data/basic/tumor.dat
pic_fig1()    % plots week-3 and week-7 EMT distributions
pic_fig2()    % plots tumor load, EM-level heatmap, mean trajectory
```

### Step 2 — Sensitivity / parameter sweeps

```matlab
cal_fig3()    % 100 LHS samples × 12 parameters → PRCC (slowest single step)
cal_fig4()    % ν, σ single-parameter perturbation
cal_fig5()    % fixed-macrophage experiments (no-mac / M1 / MII / mix)
cal_fig6()    % 1-D sweeps of λ_β, λ_μ, K_Q
cal_fig7()    % 2-D sweeps (3 × 30 × 30 = 2 700 solves; slowest overall)
```

Each `cal_figN` script reads from `data/<subdir>/` and writes both `.mat`
and `.dat` outputs back to the same subdirectory.

### Step 3 — Virtual mouse cohort (reproduces Fig. 9–11)

```matlab
virtual()         % 100 untreated mice → virtual_data/notreat/all_data.mat
virtual_treat()   % 100 anti-CSF-1R mice → virtual_data/treat/all_data.mat
```

### Step 4 — Plotting

```matlab
pic_fig3() … pic_fig7()      % Fig. 3–7
cd virtual_data
cal_fig8()                   % posterior statistics (reads para_10000.dat)
pic_fig8() … pic_fig11()     % Fig. 8–11
cd ..
```

> The `.mat` result files for Fig. 6, Fig. 7, Fig. 9–11 are **pre-computed
> and shipped** in this repository. To regenerate them, run the
> corresponding `cal_figN()` or `virtual()` script first.

---

## Model Overview

The model tracks the phenotypic distribution Q(x,t) of SCC cells over the
continuous EMT axis x ∈ [0,1] (0 = fully epithelial, 1 = fully
mesenchymal) with an epigenetic-inheritance delay τ = 1 day.

| Equation | Role |
|----------|------|
| dQ/dt = −(β + κ) Q + 2 ∫ P(x\|y) β(y,t−τ)Q(y,t−τ) dy | Phase-structured birth-death |
| P(x\|y) = Beta(νφ, ν(1−φ)) | Epigenetic inheritance kernel (Inherit.m) |
| β(x) = β̄(1+f_β)(1−Q/θ_Q)(1+λ_β∫M·f_u) | Macrophage-modulated proliferation (Dynamic.m) |
| κ(x) = κ̄·x^n/(x^n+K_κ^n) | Contact inhibition / density limit |
| μ = μ̄(1+λ_μ∫M·g_u) | Macrophage-modulated apoptosis |
| M(u) = Beta(ν_u φ, ν_u(1−φ)) | Quasi-steady macrophage polarization (Distribution_mac.m) |

All numerical values are in `parameter.m` (Table 1 of the paper).

---

## Numerical Scheme

- **Time integration**: forward Euler, Δh = 0.5 day, τ = 1 day, T = 70 days
- **Spatial grid**: N = 101 nodes on [0,1]
- **Quadrature**: composite Simpson's rule (Integral.m), applied row-wise
- **Macrophage polarization**: quasi-steady, re-evaluated at each time step
  from the current tumor load (no stiff ODE for u is solved)

---

## Data Files Shipped in This Repository

| File | Rows × Cols | Description |
|------|:-----------:|-------------|
| `input/week3-4.dat` | 6 × 6 | MCMC posterior draws, 6 SCC phenotypic bins, weeks 3–4 |
| `input/week7-8.dat` | 6 × 6 | MCMC posterior draws, weeks 7–8 |
| `input/better_par.dat` | 90 × 12 | Top-90 MCMC samples (reference; not called by any script) |
| `data/basic/tumor.dat` | 143 × 101 | Baseline simulation output (main.m) |
| `virtual_data/virtual mouse/mouse.dat` | 100 × 4 | Virtual-mouse seed: (β, μ, ν, σ) |
| `virtual_data/virtual mouse/para_10000.dat` | 10 000 × 13 | Full MCMC posterior draws |

All `.mat` result files (PRCC, par-ratio, double_par `_D`, notreat/treat)
are pre-computed and included so that reviewers can verify figures without
re-running the (time-consuming) simulation loops.

**Omitted from this repository** (regenerate via the corresponding script):
- `data/double_par/{beta_mu, mu_KQ, KQ_beta}.mat` (3 × ~92 MB raw
  simulation arrays; the derived `_D.mat` files are shipped instead)
- `Figure/` (layout artwork: `.ai`, `.pdf`, `.png`)

---

## Citation

If you use this code, please cite:

```
@article{lei2026macrophage,
  author  = {Weizhi Wei and Jinzhi Lei},
  title   = {Multiscale Mathematical Modeling of Macrophage Regulation of
             the EMT Process in Squamous Cell Carcinoma},
  journal = {SIAM J. Life Sci.},
  year    = {2026},
  note    = {Code available at <URL>}
}
```

*(Replace `<URL>` with the repository URL when it is published.)*
