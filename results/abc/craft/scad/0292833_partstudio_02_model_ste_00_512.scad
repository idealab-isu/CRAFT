// Dimension-calibrated (target: 0.36 x 0.03 x 0.54 mm)
scale([1.000000, 1.000000, 0.789474])
{
// Thin rectangular plate with a centered raised boss (one face only)

// Parameters (mm)
plate_L = 0.54;   // overall length
plate_W = 0.36;   // overall width
plate_T = 0.03;   // plate thickness (>0)

boss_L  = 0.20;   // boss length
boss_W  = 0.14;   // boss width
boss_H  = 0.01;   // boss height (raised pad)

overlap = 0.002;  // small overlap to guarantee manifold union

module plate_with_boss_one_face() {
    union() {
        // Plate sits on Z=0 plane (bottom at 0, top at plate_T)
        translate([0, 0, plate_T/2])
            cube([plate_L, plate_W, plate_T], center=true);

        // Boss protrudes only from the +Z face of the plate
        translate([0, 0, plate_T + boss_H/2 - overlap])
            cube([boss_L, boss_W, boss_H], center=true);
    }
}

plate_with_boss_one_face();
}
