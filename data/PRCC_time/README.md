# `PRCC_time/` — Empty (intentionally shipped with no files)

**This directory contains no data on purpose.** It is an empty
placeholder left in the repository tree; no script in this package
reads from or writes to it.

## Why it exists

The name refers to a **time-resolved PRCC** (Partial Rank Correlation
Coefficient) sensitivity analysis — i.e. repeating the local PRCC of
`cal_fig3.m` at multiple time points instead of only the single
end-of-simulation snapshot that `data/PRCC/` stores.

In the released implementation only the **global / end-point PRCC**
(`cal_fig3.m` → `data/PRCC/`) was carried through; the time-resolved
variant was not computed, so this directory was created as a stub and
never populated.

## What you should know

- **No code path references `PRCC_time`.** `cal_fig3.m` writes all
  PRCC output to `../PRCC/` (`ALL.mat`, `p_p.dat`, `p_r.dat`,
  `para_mat.dat`, `target_p.dat`, `target_r.dat`). Nothing looks for
  a `PRCC_time` folder.
- **It does not affect Figures 1–11.** No plotting script
  (`pic_fig*.m`, `virtual_data/*.m`) loads a file from here.
- **There is nothing to re-run** to fill it: the corresponding
  analysis was not part of the manuscript.

If you do want a time-resolved PRCC, the natural place to add it is a
new script (e.g. `cal_fig3_time.m`) that loops `cal_fig3` over selected
time points and writes one PRCC row per time point into this directory;
it would then be plotted by an extended `pic_fig3.m`. As it stands,
this folder is simply an empty placeholder.
