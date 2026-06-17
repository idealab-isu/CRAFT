# CLIP Score Evaluation Results

Generated: 2026-06-04 01:26:44
CLIP Model: ViT-L-14/openai

## Overall Comparison

Higher CLIP Score = better text-image alignment.

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score (mean) ↑ | 0.2226 | 0.2033 | 0.2145 | **0.2342** |
| CLIP Score (std) | 0.0291 | 0.0289 | 0.0276 | 0.0337 |
| CLIP Score (median) | 0.2220 | 0.2041 | 0.2155 | 0.2319 |
| CLIP Score (min) | 0.1310 | 0.1178 | 0.1217 | 0.1085 |
| CLIP Score (max) | 0.2949 | 0.2744 | 0.2973 | 0.3095 |
| Evaluated | 467.0000 | 467.0000 | 462.0000 | 468.0000 |
| Skipped | 1.0000 | 1.0000 | 6.0000 | 0.0000 |

## Per-Tier Comparison


### Simple

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2272 | 0.2098 | 0.2174 | **0.2279** |
| Count | 158 | 159 | 159 | 159 |

### Medium

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2132 | 0.2014 | 0.2144 | **0.2342** |
| Count | 160 | 160 | 158 | 160 |

### Complex

| Metric | craft | gpt4o | gpt52 | gt |
|--------|------|------|------|------|
| CLIP Score ↑ | 0.2279 | 0.1983 | 0.2116 | **0.2409** |
| Count | 149 | 148 | 145 | 149 |

## Top 10 Highest CLIP Scores (craft)

| Rank | Prompt ID | Tier | CLIP Score | Prompt |
|------|-----------|------|------------|--------|
| 1 | screw__M5_cs_cap_screw | Complex | 0.2949 | A socket head cap screw with 5.0mm diameter and 10.0mm head ... |
| 2 | screw__M2_cs_cap_screw | Complex | 0.2942 | A socket head cap screw with 2.0mm diameter and 3.8mm head d... |
| 3 | screw__M4_cs_cap_screw | Complex | 0.2927 | A socket head cap screw with 4.0mm diameter and 8.0mm head d... |
| 4 | screw__M3_shoulder_screw | Complex | 0.2921 | A screw with 4.0mm diameter and 7.0mm head diameter, head he... |
| 5 | sheet__AL3 | Simple | 0.2894 | A sheet: Aluminium tooling plate |
| 6 | screw__M2p5_pan_screw | Complex | 0.2877 | A pan head screw with 2.5mm diameter and 4.7mm head diameter... |
| 7 | extrusion__E2080 | Simple | 0.2874 | An aluminium extrusion profile, 20.0mm x 80.0mm cross sectio... |
| 8 | rail__SSR15 | Simple | 0.2866 | A miniature linear guide rail, 15.0mm wide, 12.5mm tall, 100... |
| 9 | screw__M2p5_cap_screw | Complex | 0.2857 | A socket head cap screw with 2.5mm diameter and 4.5mm head d... |
| 10 | washer__M3_rubber_washer | Simple | 0.2853 | A rubber washer with 3.0mm inner hole, 10.0mm outer diameter... |

## Bottom 10 Lowest CLIP Scores (craft)

| Rank | Prompt ID | Tier | CLIP Score | Prompt |
|------|-----------|------|------------|--------|
| 1 | display__LCD1602AI2C | Medium | 0.1583 | A display module (LCD display 1602A), 71.3mm x 24.3mm |
| 2 | panel_meter__DSN_VC288 | Complex | 0.1583 | A panel meter: DSN- DC 100V 10A Voltmeter ammeter |
| 3 | sheet__Foam20 | Simple | 0.1573 | A sheet: Foam sponge |
| 4 | display__SSD1963_4p3 | Medium | 0.1567 | A display: LCD display 4.3\"", 105.5, 67.2, 3.4, , [0, 0, 0]... |
| 5 | smd__SOIC14 | Medium | 0.1562 | A smd: [8.70, 3.90, 1.25] |
| 6 | panel_meter__PZEM001 | Complex | 0.1557 | A panel meter: Peacefair PZEM-001 AC digital multi-function ... |
| 7 | mains_socket__PMS9143A | Medium | 0.1529 | A mains socket: Screwfix Essential unswitched. |
| 8 | photo_interrupter__PH1 | Simple | 0.1374 | A photo interrupter |
| 9 | display__HDMI5 | Medium | 0.1360 | A display: HDMI display 5\"", 121, 76, 2.85, , [0, 0, 1.9], ... |
| 10 | pcb__Ethernet | Complex | 0.1310 | A 3D printer control board, 33.8mm x 37.5mm, 1.6mm thick |