// Penny washer parameters (mm)
inner_diameter_mm = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm = 12.0;  //[6.0:24.0:0.1]
thickness_mm      = 0.8;   //[0.4:1.6:0.05]
eps_mm            = 0.2;   //[0.05:0.5:0.05]

$fn = 128;

// Single connected solid: one washer with a through-hole
module penny_washer(inner_d=inner_diameter_mm, outer_d=outer_diameter_mm, t=thickness_mm, eps=eps_mm) {
    difference() {
        cylinder(d=outer_d, h=t, center=true);
        cylinder(d=inner_d, h=t + 2*eps, center=true);
    }
}

penny_washer();