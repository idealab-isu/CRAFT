// Dimension-calibrated (target: 0.01 x 0.01 x 0.02 mm)
scale([0.842105, 0.800000, 1.300000])
{
// T-shaped bracket with circular through-hole (connected solid)

// Increase smoothness so the hole is truly circular
$fn = 96;

// Parameters (meters as given; keep consistent)
plate_L = 0.012;
plate_W = 0.010;
plate_H = 0.010;

stem_L  = 0.008;
stem_W  = 0.004;
stem_H  = 0.010;

hole_d = 0.003;
hole_x = 0.0;   // hole position within plate (X)
hole_y = 0.0;   // hole position within plate (Y)

overlap    = 0.001;  // ensures stem and plate overlap (connect)
hole_extra = 0.002;  // ensures clean through-cut

module plate_block() {
    cube([plate_L, plate_W, plate_H], center=true);
}

module stem_block() {
    // Stem projects from +X face of plate, centered in Y and Z
    translate([plate_L/2 + stem_L/2 - overlap, 0, 0])
        cube([stem_L, stem_W, stem_H], center=true);
}

module through_hole() {
    // Through-hole along Z, located in the larger plate portion
    translate([hole_x, hole_y, 0])
        cylinder(h=plate_H + hole_extra, d=hole_d, center=true);
}

module t_bracket_with_hole() {
    difference() {
        union() {
            plate_block();
            stem_block();
        }
        through_hole();
    }
}

color("Silver") t_bracket_with_hole();
}
