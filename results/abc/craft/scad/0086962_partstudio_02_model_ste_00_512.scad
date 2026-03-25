// Dimension-calibrated (target: 0.15 x 0.01 x 0.15 mm)
scale([1.500024, 0.166668, 16.668741])
{
// Thin elongated plate with 4 asymmetric rectangular bosses on ONE face only.
// Units: mm

// Plate (elongated along X)
plate_L = 0.10;     // length
plate_W = 0.06;     // width
plate_T = 0.006;    // thickness

// Bosses (4 discrete studs)
boss_L  = 0.014;
boss_W  = 0.010;
boss_H  = 0.004;

// Small overlap to guarantee a single connected solid
// (must be >0 and < plate_T so the opposite face stays perfectly flat)
overlap = 0.001;

// Asymmetric boss locations across the plate surface (kept within footprint)
boss_pos = [
    [-plate_L*0.33, -plate_W*0.20],
    [ plate_L*0.12, -plate_W*0.02],
    [-plate_L*0.06,  plate_W*0.24],
    [ plate_L*0.34,  plate_W*0.16]
];

module plate() {
    cube([plate_L, plate_W, plate_T], center=true);
}

module boss() {
    cube([boss_L, boss_W, boss_H], center=true);
}

// Place bosses so they protrude ONLY from +Z face.
// Plate top surface is at +plate_T/2.
// Boss bottom is set to (plate_T/2 - overlap) so it slightly intersects the plate.
// This guarantees a single solid and keeps the -Z face smooth/featureless.
boss_center_z = (plate_T/2 - overlap) + boss_H/2;

union() {
    plate();

    for (p = boss_pos)
        translate([p[0], p[1], boss_center_z])
            boss();
}
}
