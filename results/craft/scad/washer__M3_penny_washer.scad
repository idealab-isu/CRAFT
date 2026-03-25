// Penny washer parameters (mm)
inner_diameter_mm = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm = 12.0;  //[6.0:24.0:0.1]
thickness_mm      = 0.8;   //[0.4:1.6:0.05]

// Small extra height to guarantee a clean through-hole
eps_mm = 0.2; //[0.05:1.0:0.05]

$fn = 128;

module penny_washer() {
    difference() {
        cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
        cylinder(d=inner_diameter_mm, h=thickness_mm + 2*eps_mm, center=true);
    }
}

penny_washer();