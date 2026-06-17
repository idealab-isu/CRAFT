// Linear bearing: 4.0mm bore, 8.0mm OD, 12.0mm length
// One connected solid (a single sleeve with central bore)

// Parameters
bore_diameter_mm  = 4.0;  //[2.0:8.0:0.1]
outer_diameter_mm = 8.0;  //[4.0:16.0:0.1]
length_mm         = 12.0; //[6.0:24.0:0.1]
centered          = 1;    //[0:1:1]
eps_mm            = 0.2;  //[0.05:0.5:0.05]

$fn = 96;

module linear_bearing(bore_d, od_d, len, centered=true, eps=0.2) {
    difference() {
        cylinder(h=len, r=od_d/2, center=centered);
        // Inner bore: extend slightly to guarantee clean subtraction
        translate([0, 0, centered ? 0 : -eps])
            cylinder(h=len + 2*eps, r=bore_d/2, center=centered);
    }
}

linear_bearing(bore_diameter_mm, outer_diameter_mm, length_mm, centered=centered, eps=eps_mm);