# Normal Consistency Evaluation Results

Generated: 2026-03-01 16:27:09
Higher NC = predicted surface normals better match GT surface normals.

## Overall Comparison

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| NC (mean) ↑ | **0.5931** | 0.5679 | 0.5631 |
| NC (std) | 0.2612 | 0.2684 | 0.2382 |
| NC (median) | **0.5801** | 0.5435 | 0.5624 |
| NC (min) | 0.0059 | 0.0020 | 0.0028 |
| NC (max) | 0.9944 | 0.9929 | 0.9877 |
| Evaluated | 463.0000 | 466.0000 | 464.0000 |
| Skipped | 13.0000 | 10.0000 | 12.0000 |

## Per-Tier Comparison


### Simple

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| NC ↑ | 0.5088 | **0.6118** | 0.4761 |
| Count | 158 | 158 | 158 |

### Medium

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| NC ↑ | **0.6757** | 0.5413 | 0.6218 |
| Count | 158 | 160 | 159 |

### Complex

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| NC ↑ | **0.5949** | 0.5498 | 0.5931 |
| Count | 147 | 148 | 147 |

## Top 10 Best Surface Quality (cadence)

| Rank | Prompt ID | Tier | NC |
|------|-----------|------|----|
| 1 | ht_pipe__HT_125_pipe_1500 | Simple | 0.9944 |
| 2 | ht_pipe__HT_125_pipe_2000 | Simple | 0.9939 |
| 3 | ht_pipe__HT_50_pipe_1000 | Simple | 0.9907 |
| 4 | ht_pipe__HT_50_pipe_250 | Simple | 0.9901 |
| 5 | batterie__LI32700 | Medium | 0.9892 |
| 6 | ht_pipe__HT_50_pipe_1500 | Simple | 0.9892 |
| 7 | tubing__PTFE2_4 | Medium | 0.9891 |
| 8 | ht_pipe__HT_32_pipe_500 | Simple | 0.9881 |
| 9 | batterie__S25R18650 | Medium | 0.9875 |
| 10 | ht_pipe__HT_160_pipe_1000 | Simple | 0.9867 |

## Top 10 Worst Surface Quality (cadence)

| Rank | Prompt ID | Tier | NC |
|------|-----------|------|----|
| 1 | sheet__PMMA2 | Simple | 0.0169 |
| 2 | sheet__Silicone3 | Simple | 0.0149 |
| 3 | sheet__Sellotape | Simple | 0.0147 |
| 4 | sheet__MDF19 | Simple | 0.0146 |
| 5 | sheet__PMMA10 | Simple | 0.0143 |
| 6 | sheet__MDF12 | Simple | 0.0141 |
| 7 | sheet__PMMA3 | Simple | 0.0137 |
| 8 | sheet__MDF6 | Simple | 0.0131 |
| 9 | sheet__DiBond6 | Simple | 0.0065 |
| 10 | sheet__DiBond | Simple | 0.0059 |