// Long linear bearing (simple sleeve)
// Target dimensions: 8.0mm bore, 15.0mm outer diameter, 45.0mm length

bore_diameter_mm  = 8.0;
outer_diameter_mm = 15.0;
length_mm         = 45.0;

eps_mm = 0.05;

$fn = 128;

module linear_bearing_sleeve(bore_d, outer_d, len) {
    difference() {
        cylinder(d=outer_d, h=len, center=true);
        cylinder(d=bore_d,  h=len + 2*eps_mm, center=true);
    }
}

linear_bearing_sleeve(bore_diameter_mm, outer_diameter_mm, length_mm);