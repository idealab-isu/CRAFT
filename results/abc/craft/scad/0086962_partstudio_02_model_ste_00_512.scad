// Dimension-calibrated (target: 0.15 x 0.01 x 0.15 mm)
scale([1.500000, 0.166667, 25.000000])
{
// Thin elongated plate with 4 asymmetric bosses on ONE face only
// Units: mm

// Plate (elongated along X)
plate_L = 0.10;
plate_W = 0.06;
plate_T = 0.004;

// Bosses
boss_L  = 0.012;
boss_W  = 0.008;
boss_H  = 0.003;

// Asymmetric boss locations (kept within plate extents)
boss1_x = -plate_L*0.30; boss1_y = -plate_W*0.25;
boss2_x =  plate_L*0.10; boss2_y = -plate_W*0.10;
boss3_x = -plate_L*0.05; boss3_y =  plate_W*0.28;
boss4_x =  plate_L*0.32; boss4_y =  plate_W*0.18;

overlap = 0.001; // positive overlap to guarantee manifold connection

module plate_body() {
    // Plate spans Z=[0..plate_T] so the bottom face is perfectly smooth at Z=0
    translate([0, 0, plate_T/2])
        cube([plate_L, plate_W, plate_T], center=true);
}

module boss_at(x, y) {
    // Bosses protrude only upward from the top face (Z=plate_T)
    translate([x, y, plate_T + boss_H/2 - overlap])
        cube([boss_L, boss_W, boss_H], center=true);
}

union() {
    plate_body();
    boss_at(boss1_x, boss1_y);
    boss_at(boss2_x, boss2_y);
    boss_at(boss3_x, boss3_y);
    boss_at(boss4_x, boss4_y);
}
}
