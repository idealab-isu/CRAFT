// Linear bearing: 4.0mm bore, 8.0mm outer diameter, 12.0mm length
// One connected solid (single sleeve with through-bore)

// Parameters
bore_diameter_mm  = 4;   //[2:8:0.1]
outer_diameter_mm = 8;   //[4:16:0.1]
length_mm         = 12;  //[6:24:0.1]

eps_mm = 0.2;            //[0.05:0.5:0.05]

bore_radius_mm  = bore_diameter_mm/2;
outer_radius_mm = outer_diameter_mm/2;

$fn = 96;

module linear_bearing() {
    difference() {
        // Outer sleeve
        cylinder(h=length_mm, r=outer_radius_mm, center=true);

        // Through-bore (slightly longer to guarantee clean cut)
        cylinder(h=length_mm + 2*eps_mm, r=bore_radius_mm, center=true);
    }
}

linear_bearing();