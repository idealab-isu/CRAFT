// Long linear bearing (simple hollow cylinder)
// Target: 12.0mm bore, 21.0mm outer diameter, 57.0mm length

bore_diameter_mm  = 12.0;
outer_diameter_mm = 21.0;
length_mm         = 57.0;

overlap_mm = 0.5; // ensures clean through-bore cut

$fn = 128;

module linear_bearing_simple() {
    difference() {
        // Outer body
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        // Through-bore
        cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }
}

linear_bearing_simple();