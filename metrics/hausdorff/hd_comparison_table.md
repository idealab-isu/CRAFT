# Hausdorff Distance Evaluation Results

Generated: 2026-03-01 16:45:17
Lower Hausdorff = no catastrophic geometric errors.

## Overall Comparison

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| HD (mean) ↓ | **0.3111** | 0.3694 | 0.3410 |
| HD (median) | **0.2985** | 0.3534 | 0.3455 |
| HD (std) | 0.2333 | 0.2289 | 0.1981 |
| HD95 (mean) ↓ | **0.2475** | 0.3030 | 0.2813 |
| HD95 (median) | **0.2191** | 0.3097 | 0.2911 |
| HD90 (mean) ↓ | **0.2110** | 0.2643 | 0.2437 |
| HD90 (median) | **0.1849** | 0.2783 | 0.2592 |
| Evaluated | 463.0000 | 466.0000 | 464.0000 |
| Skipped | 13.0000 | 10.0000 | 12.0000 |

## Per-Tier Comparison


### Simple

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| HD ↓ | 0.3685 | **0.3331** | 0.4015 |
| HD95 ↓ | 0.3116 | **0.2704** | 0.3389 |
| Count | 158 | 158 | 158 |

### Medium

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| HD ↓ | **0.2394** | 0.3817 | 0.2679 |
| HD95 ↓ | **0.1825** | 0.3192 | 0.2151 |
| Count | 158 | 160 | 159 |

### Complex

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| HD ↓ | **0.3264** | 0.3949 | 0.3551 |
| HD95 ↓ | **0.2485** | 0.3205 | 0.2908 |
| Count | 147 | 148 | 147 |

## Top 10 Best (Lowest HD) — cadence

| Rank | Prompt ID | Tier | HD | HD95 |
|------|-----------|------|----|------|
| 1 | ht_pipe__HT_32_pipe_1000 | Simple | 0.0064 | 0.0033 |
| 2 | ht_pipe__HT_50_pipe_1500 | Simple | 0.0086 | 0.0032 |
| 3 | ht_pipe__HT_125_pipe_2000 | Simple | 0.0102 | 0.0044 |
| 4 | box_section__AL12x8x1 | Simple | 0.0127 | 0.0082 |
| 5 | ht_pipe__HT_160_pipe_1000 | Simple | 0.0129 | 0.0075 |
| 6 | ht_pipe__HT_50_pipe_1000 | Simple | 0.0133 | 0.0040 |
| 7 | batterie__S25R18650 | Medium | 0.0172 | 0.0098 |
| 8 | ht_pipe__HT_160_pipe_500 | Simple | 0.0173 | 0.0111 |
| 9 | batterie__AACELL | Medium | 0.0186 | 0.0125 |
| 10 | batterie__AAACELL | Medium | 0.0196 | 0.0123 |

## Top 10 Worst (Highest HD) — cadence

| Rank | Prompt ID | Tier | HD | HD95 | Pred→GT | GT→Pred |
|------|-----------|------|----|------|---------|---------|
| 1 | ht_pipe__HT_40_pipe_2000 | Simple | 0.9806 | 0.8800 | 0.4856 | 0.9806 |
| 2 | ht_pipe__HT_32_pipe_1500 | Simple | 0.9785 | 0.8840 | 0.4928 | 0.9785 |
| 3 | ht_pipe__HT_40_pipe_1500 | Simple | 0.9728 | 0.8810 | 0.4758 | 0.9728 |
| 4 | washer__M3_washer | Simple | 0.9717 | 0.8770 | 0.9717 | 0.0451 |
| 5 | ht_pipe__HT_75_pipe_2000 | Simple | 0.9617 | 0.8656 | 0.4690 | 0.9617 |
| 6 | ht_pipe__HT_40_pipe_1000 | Simple | 0.9583 | 0.8951 | 0.9138 | 0.9583 |
| 7 | component__Epcos | Simple | 0.9463 | 0.8265 | 0.0328 | 0.9463 |
| 8 | toggle__MS332F_pin | Complex | 0.9450 | 0.8438 | 0.0097 | 0.9450 |
| 9 | toggle__CK7000_tag | Complex | 0.9449 | 0.8477 | 0.0096 | 0.9449 |
| 10 | toggle__AP5236_pin | Complex | 0.9445 | 0.8478 | 0.0097 | 0.9445 |

Pred→GT = extra geometry (prediction has parts GT doesn't)
GT→Pred = missing geometry (prediction is missing parts GT has)