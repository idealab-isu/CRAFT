// Long linear bearing (single connected component)
// Target: 4.0mm bore, 8.0mm outer diameter, 23.0mm length

$fn = 128;

// Parameters
bore_diameter_mm  = 4.0;   //[2:8:0.1]
outer_diameter_mm = 8.0;   //[4:16:0.1]
length_mm         = 23.0;  //[12:46:0.1]

// Small overlap to ensure clean boolean operations
overlap_mm = 0.2;          //[0.05:1:0.05]

module linear_bearing() {
    // Bearing axis along X so "top/bottom" orthographic views show the through-bore
    rotate([0, 90, 0])
    difference() {
        // Outer sleeve
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Through bore (slightly longer for robust subtraction)
        cylinder(d=bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);
    }
}

linear_bearing();