// Ground truth: BLDC 2205 Brushless DC Motor
// Source: NopSCADlib (https://github.com/nophead/NopSCADlib)
// Type: BLDC2205 (28mm stator diameter, 17.25mm height)

include <nopscadlib/lib.scad>

// NopSCADlib renders BLDC motors with `BLDC(<type>)`.
BLDC(BLDC2205);
