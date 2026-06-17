// Linear bearing (LM8UU-style simple body)
// Target dimensions: 8.0mm bore, 15.0mm outer diameter, 24.0mm length
// One connected solid (single part), no side features.

bore_diameter_mm  = 8.0;
outer_diameter_mm = 15.0;
length_mm         = 24.0;

overlap_mm = 0.2;
$fn = 96;

module linear_bearing_simple(bore_d, outer_d, len) {
    difference() {
        // Outer body
        cylinder(d=outer_d, h=len, center=true);

        // Through bore
        cylinder(d=bore_d, h=len + 2*overlap_mm, center=true);
    }
}

linear_bearing_simple(bore_diameter_mm, outer_diameter_mm, length_mm);