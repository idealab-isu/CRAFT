# CLIP Score Evaluation Results

Generated: 2026-03-01 06:27:46
CLIP Model: ViT-L-14/openai

## Overall Comparison

Higher CLIP Score = better text-image alignment.

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score (mean) ↑ | 0.2223 | 0.2033 | 0.2145 | **0.2333** |
| CLIP Score (std) | 0.0280 | 0.0289 | 0.0276 | 0.0332 |
| CLIP Score (median) | 0.2225 | 0.2041 | 0.2155 | 0.2313 |
| CLIP Score (min) | 0.1283 | 0.1178 | 0.1217 | 0.1085 |
| CLIP Score (max) | 0.2981 | 0.2744 | 0.2973 | 0.3093 |
| Evaluated | 463.0000 | 467.0000 | 462.0000 | 468.0000 |
| Skipped | 5.0000 | 1.0000 | 6.0000 | 0.0000 |

## Per-Tier Comparison


### Simple

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2260 | 0.2098 | 0.2174 | **0.2279** |
| Count | 158 | 159 | 159 | 159 |

### Medium

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2159 | 0.2014 | 0.2144 | **0.2317** |
| Count | 158 | 160 | 158 | 160 |

### Complex

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2251 | 0.1983 | 0.2116 | **0.2409** |
| Count | 147 | 148 | 145 | 149 |

## Top 10 Highest CLIP Scores (craft)

| Rank | Prompt ID | Tier | CLIP Score | Prompt |
|------|-----------|------|------------|--------|
| 1 | screw__M6_cs_cap_screw | Complex | 0.2981 | A socket head cap screw with 6.0mm diameter and 12.0mm head ... |
| 2 | screw__M4_shoulder_screw | Complex | 0.2980 | A screw with 5.0mm diameter and 9.0mm head diameter, head he... |
| 3 | screw__M3_cs_cap_screw | Complex | 0.2928 | A socket head cap screw with 3.0mm diameter and 6.0mm head d... |
| 4 | screw__M4_cs_cap_screw | Complex | 0.2922 | A socket head cap screw with 4.0mm diameter and 8.0mm head d... |
| 5 | screw__No6_cs_screw | Complex | 0.2870 | A screw with 3.5mm diameter and 7.0mm head diameter, 10mm lo... |
| 6 | screw__M2p5_dome_screw | Complex | 0.2865 | A dome head screw with 2.5mm diameter and 5.35mm head diamet... |
| 7 | extrusion__E3060 | Simple | 0.2860 | An aluminium extrusion profile, 30.0mm x 60.0mm cross sectio... |
| 8 | washer__M3_rubber_washer | Simple | 0.2858 | A rubber washer with 3.0mm inner hole, 10.0mm outer diameter... |
| 9 | sheet__AL8 | Simple | 0.2819 | A sheet: Aluminium tooling plate |
| 10 | screw__No4_screw | Complex | 0.2805 | A pan head screw with 3.0mm diameter and 5.5mm head diameter... |

## Bottom 10 Lowest CLIP Scores (craft)

| Rank | Prompt ID | Tier | CLIP Score | Prompt |
|------|-----------|------|------------|--------|
| 1 | variac__RAVISTAT1F1 | Medium | 0.1609 | A variac: RAVISTAT 1F-1 |
| 2 | insert__CNCKM3 | Simple | 0.1594 | A threaded heat-set insert, 3.0mm outer diameter, 4.6mm long... |
| 3 | screw__M8_dome_screw | Complex | 0.1589 | A dome head screw with 8.0mm diameter and 14.0mm head diamet... |
| 4 | smd__SOIC14 | Medium | 0.1589 | A smd: [8.70, 3.90, 1.25] |
| 5 | iec__IEC_fused_inlet | Complex | 0.1568 | An IEC power inlet module (IEC fused inlet JR-101-1F), 36.0m... |
| 6 | box_section__AL12x8x1 | Simple | 0.1536 | A box section: Aluminium rectangular box section 12mm x 8mm ... |
| 7 | pulley__GT2x20um_pulley | Complex | 0.1517 | A timing pulley with 20 teeth and 12.22mm pitch diameter |
| 8 | display__HDMI5 | Medium | 0.1500 | A display: HDMI display 5\"", 121, 76, 2.85, , [0, 0, 1.9], ... |
| 9 | panel_meter__PZEM021 | Complex | 0.1490 | A panel meter: Peacefair PZEM-021 AC digital multi-function ... |
| 10 | photo_interrupter__PH1 | Simple | 0.1283 | A photo interrupter |