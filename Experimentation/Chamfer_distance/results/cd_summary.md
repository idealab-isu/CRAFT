# Chamfer Distance (aligned) — lower is better

_Config: 10000 surface points, ICP=on, seed=42, normalized to unit bounding-sphere, PCA + 24 rotations alignment._

| example | craft | gpt52 | gpt4o | v4 |
|---|---|---|---|---|
| 7_segment__WT5011BSR | 0.06365 | 0.06149 | 0.06124 | **0.05880** |
| antenna__ESP201_antenna | **0.01573** | 0.02367 | 0.04350 | 0.02406 |
| axial__DO_35 | **0.23608** | 0.24123 | 0.23865 | 0.23926 |
| ball_bearing__BB608 | 0.04291 | missing_stl | 0.04818 | **0.04182** |
| batterie__A23CELL | 0.01564 | 0.01418 | **0.01410** | 0.01410 |
| bearing_block__SCS10LUU | 0.18704 | 0.14737 | **0.13459** | 0.15483 |
| bldc_motor__BLDC0603 | 0.09263 | 0.18355 | **0.06248** | 0.10436 |
| blower__BL30x10 | 0.03417 | 0.04072 | 0.05839 | **0.03410** |
| box_section__AL12x8x1 | **0.00864** | 0.09792 | missing_stl | 0.06581 |
| camera__ESP32_CAM | **0.07557** | 0.11677 | 0.11736 | 0.13201 |
| component__Epcos | 0.32682 | 0.20040 | 0.25923 | **0.12573** |
| d_connector__DCONN15 | 0.04828 | **0.04761** | 0.08192 | 0.05245 |
| display__BigTreeTech_TFT35v3_0 | **0.03196** | 0.03331 | missing_stl | 0.03731 |
| extrusion__E1515 | **0.01878** | 0.07829 | missing_stl | 0.01878 |
| extrusion_bracket__E20_corner_bracket | 0.07081 | **0.05172** | 0.08997 | 0.07079 |
| gear_motor__FIT0492_A | 0.05745 | **0.04709** | 0.04967 | 0.15884 |
| hot_end__E3D_clone | 0.09773 | 0.09678 | **0.09657** | 0.09769 |
| ht_pipe__HT_110_cap | 0.10370 | **0.09032** | 0.25068 | 0.22359 |
| iec__IEC_320_C14_switched_fused_inlet | 0.04812 | 0.05958 | 0.12039 | **0.03765** |
| insert__CNCKM2p5 | 0.05293 | **0.04359** | 0.08098 | 0.05689 |
| leadnut__LNHT8x2 | 0.07925 | 0.10633 | **0.06118** | 0.10673 |
| led__LED10mm | **0.04173** | 0.26722 | 0.25481 | 0.26540 |
| light_strip__RIGID5050 | 0.04672 | 0.04702 | 0.04682 | **0.04665** |
| linear_bearing__LM10LUU | 0.01353 | 0.01396 | **0.01319** | 0.01353 |
| magnet__MAG484 | 0.13045 | **0.01893** | 0.03086 | 0.01931 |
| mains_socket__Contactum | 0.03016 | **0.02687** | 0.07943 | 0.07943 |
| nut__M2_nut | 0.03565 | 0.04794 | **0.01788** | 0.02935 |
| panel_meter__DSN_VC288 | 0.05762 | 0.08646 | 0.07636 | **0.05610** |
| pcb__ArduinoLeonardo | **0.02995** | 0.03013 | 0.03111 | 0.03015 |
| photo_interrupter__PH1 | **0.09744** | 0.09839 | 0.12756 | 0.11776 |

## Mean Chamfer Distance
| method | mean CD |
|---|---|
| craft | 0.07304 |
| gpt52 | 0.08341 |
| gpt4o | 0.09434 |
| v4 | 0.08378 |
