// Ground truth: NEMA 17 Stepper Motor (40mm body)
// Source: NopSCADlib (https://github.com/nophead/NopSCADlib)
// Type: NEMA17_40 (42.3mm face, 40mm body length)

include <nopscadlib/lib.scad>

// NopSCADlib renders NEMA steppers with `NEMA(<type>)`.
NEMA(NEMA17_40);
