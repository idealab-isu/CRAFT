// Long linear bearing sleeve
// 3.0mm bore, 7.0mm outer diameter, 19.0mm length

bearing_length = 19.0;
outer_diameter = 7.0;
bore_diameter  = 3.0;

outer_radius = outer_diameter / 2;
bore_radius  = bore_diameter  / 2;

cut_extra = 0.5;   // extend bore beyond ends to guarantee a clean through-hole
$fn = 128;

module linear_bearing_sleeve(len, ro, ri) {
    difference() {
        cylinder(h=len, r=ro, center=true);
        cylinder(h=len + 2*cut_extra, r=ri, center=true);
    }
}

linear_bearing_sleeve(bearing_length, outer_radius, bore_radius);