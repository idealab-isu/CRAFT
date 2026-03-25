// Long linear bearing: 3.0mm bore, 7.0mm outer diameter, 19.0mm length

bore_diameter_mm  = 3.0;  //[1.5:6.0:0.1]
outer_diameter_mm = 7.0;  //[3.5:14.0:0.1]
length_mm         = 19.0; //[9.5:38.0:0.5]

connect_overlap_mm = 1.0; //[0.5:2.0:0.1]
$fn = 96;

module long_linear_bearing() {
    bore_r  = bore_diameter_mm / 2;
    outer_r = outer_diameter_mm / 2;

    difference() {
        // Outer casing
        cylinder(h = length_mm, r = outer_r, center = true);

        // Through bore (extended to guarantee a clean through-hole)
        cylinder(h = length_mm + 2*connect_overlap_mm, r = bore_r, center = true);
    }
}

long_linear_bearing();