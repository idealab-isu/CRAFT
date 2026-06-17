// Long Linear Bearing (standalone)
// Specs: 10.0mm bore, 19.0mm outer diameter, 55.0mm length

$fn = 128;

// Parameters
bore_diameter_mm  = 10.0;
outer_diameter_mm = 19.0;
length_mm         = 55.0;

overlap_mm = 0.2; // small overlap to ensure clean boolean operations

module long_linear_bearing() {
    difference() {
        // Outer continuous cylindrical surface
        cylinder(d = outer_diameter_mm, h = length_mm, center = true);

        // Through-bore
        cylinder(d = bore_diameter_mm, h = length_mm + 2*overlap_mm, center = true);
    }
}

long_linear_bearing();