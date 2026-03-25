# LPIPS Evaluation Results

Generated: 2026-03-01 15:42:41
Backbone: vgg
Lower LPIPS = more perceptually similar to ground truth.

## Overall Comparison

| Metric | craft | gpt4o | gpt52 |
|--------|------|------|------|
| LPIPS (mean) ↓ | 0.4021 | 0.2859 | **0.2794** |
| LPIPS (std) | 0.0882 | 0.1189 | 0.1151 |
| LPIPS (median) | 0.4104 | 0.3032 | **0.2922** |
| LPIPS (min) | 0.2195 | 0.0079 | 0.0091 |
| LPIPS (max) | 0.7279 | 0.5288 | 0.5237 |
| Evaluated | 463.0000 | 467.0000 | 462.0000 |
| Skipped | 5.0000 | 1.0000 | 6.0000 |

## Per-Tier Comparison


### Simple

| Metric | craft | gpt4o | gpt52 |
|--------|------|------|------|
| LPIPS ↓ | 0.3995 | **0.2087** | 0.2118 |
| Count | 158 | 159 | 159 |

### Medium

| Metric | craft | gpt4o | gpt52 |
|--------|------|------|------|
| LPIPS ↓ | 0.4072 | 0.3159 | **0.3086** |
| Count | 158 | 160 | 158 |

### Complex

| Metric | craft | gpt4o | gpt52 |
|--------|------|------|------|
| LPIPS ↓ | 0.3994 | 0.3365 | **0.3217** |
| Count | 147 | 148 | 145 |

## Top 10 Most Similar Pairs (craft, lowest LPIPS)

| Rank | Prompt ID | Tier | LPIPS |
|------|-----------|------|-------|
| 1 | tubing__PTFE2_3 | Medium | 0.2195 |
| 2 | ht_pipe__HT_75_pipe_1500 | Simple | 0.2235 |
| 3 | ht_pipe__HT_90_pipe_2000 | Simple | 0.2240 |
| 4 | ht_pipe__HT_110_pipe_2000 | Simple | 0.2243 |
| 5 | ht_pipe__HT_50_pipe_1500 | Simple | 0.2247 |
| 6 | tubing__PTFE20 | Medium | 0.2254 |
| 7 | ht_pipe__HT_50_pipe_1000 | Simple | 0.2260 |
| 8 | ht_pipe__HT_125_pipe_2000 | Simple | 0.2276 |
| 9 | ht_pipe__HT_32_pipe_2000 | Simple | 0.2291 |
| 10 | ht_pipe__HT_32_pipe_1000 | Simple | 0.2298 |

## Top 10 Most Different Pairs (craft, highest LPIPS)

| Rank | Prompt ID | Tier | LPIPS |
|------|-----------|------|-------|
| 1 | sheet__CF3 | Simple | 0.6365 |
| 2 | leadnut__LNHT8x2 | Medium | 0.6379 |
| 3 | sheet__Silicone3 | Simple | 0.6525 |
| 4 | sheet__DiBond | Simple | 0.6569 |
| 5 | sheet__MDF3 | Simple | 0.6660 |
| 6 | sheet__PMMA2 | Simple | 0.6708 |
| 7 | sheet__AL1_6 | Simple | 0.6711 |
| 8 | sheet__AL2 | Simple | 0.6884 |
| 9 | sheet__PMMA1p25 | Simple | 0.6925 |
| 10 | sheet__CF2 | Simple | 0.7279 |