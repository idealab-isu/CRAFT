// Long Linear Bearing (simple sleeve)
// Target: 16.0mm bore, 28.0mm OD, 70.0mm length
// One connected solid (single part), hollow through-bore.

bore_diameter_mm  = 16.0;  // mm
outer_diameter_mm = 28.0;  // mm
length_mm         = 70.0;  // mm

$fn = 180;

module long_linear_bearing(bore_d, outer_d, len) {
    eps = 0.05; // tiny extension to guarantee a clean through-hole

    // Build along Z, centered at origin
    difference() {
        cylinder(d=outer_d, h=len, center=true);
        cylinder(d=bore_d,  h=len + 2*eps, center=true);
    }
}

long_linear_bearing(bore_diameter_mm, outer_diameter_mm, length_mm);