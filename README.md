# SIH Work‑Capacity Sankey (Questionnaire → Surgery)
___

This repo/script visualizes work‑capacity trajectories across three timepoints:
Before SIH → After symptom onset → Last follow‑up (post‑surgery), using an alluvial/Sankey diagram.
___
What the provided script does (Sankey.R)

1. Reads the Excel input: Data/Sankey Plot for kev.xlsx (sheet: Sheet1).
2. Recodes raw codes → labels (exactly as in your legend):
  a. Before SIH: 1000 = Full capacity, 555 = Voluntary reduction (non‑physical), 666 = Unemployed.
  b. After / Last FU: 100 = Full capacity, 99 = Adapted but full capacity, 80 = Reduced to 50–80%, 20 = Reduced to 20–50%, 0 = Unable to work / sick leave.
3. Aggregates paired trajectories (Before → After → Last) and computes within‑gender percentages.
4. Builds alluvial/Sankey plots with ggalluvial, using:
5. Saves two PDFs in the Plots/ folder:
  a. Plots/sankey_sih_perc_gender.pdf — faceted by Gender (y‑axis in % within gender).
  b. Plots/sankey_sih_perc.pdf — integrated (all patients) (also % scale).

The script uses percent scale (y = pct) so male/female panels are comparable by proportion.
