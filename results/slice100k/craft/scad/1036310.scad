// Simple washer/spacer: solid cylindrical disk with a central through-hole
// Bounding box: 20 x 20 x 18 mm

$fn = 128;

// Parameters
outer_diameter = 20;      // mm
thickness      = 18;      // mm
hole_diameter  = 10;      // mm
overlap        = 0.5;     // mm (ensures clean through-cut)

module spacer() {
    difference() {
        cylinder(d=outer_diameter, h=thickness, center=true);
        cylinder(d=hole_diameter,  h=thickness + 2*overlap, center=true);
    }
}

spacer();