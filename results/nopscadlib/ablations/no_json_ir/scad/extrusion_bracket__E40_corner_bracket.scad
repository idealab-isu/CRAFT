$fn = 64;

// Target overall size: [40, 40, 35]
footprint = 40;
height    = 35;

// Bracket wall thickness (typical for 40-series corner brackets)
t = 5;

// Holes (simple through-holes on each leg)
hole_d = 5;
hole_offset = 10;   // from outer edges along the leg
overlap = 0.2;      // small overlap to ensure boolean robustness

module extrusion_bracket_40x40x35() {
    difference() {
        // ONE connected solid: L-bracket made from two plates that overlap at the corner
        union() {
            // Leg A: along X, thickness in Y
            cube([footprint, t, height], center=false);

            // Leg B: along Y, thickness in X
            cube([t, footprint, height], center=false);
        }

        // Through-holes on Leg A (drilled along Y)
        for (x = [hole_offset, footprint - hole_offset]) {
            translate([x, t/2, height/2])
                rotate([90, 0, 0])
                    cylinder(h = t + 2*overlap, d = hole_d, center=true);
        }

        // Through-holes on Leg B (drilled along X)
        for (y = [hole_offset, footprint - hole_offset]) {
            translate([t/2, y, height/2])
                rotate([0, 90, 0])
                    cylinder(h = t + 2*overlap, d = hole_d, center=true);
        }
    }
}

extrusion_bracket_40x40x35();