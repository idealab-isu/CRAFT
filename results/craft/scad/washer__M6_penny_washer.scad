// Penny washer parameters (mm)
inner_diameter_mm = 6.0;   //[3:12:0.1]
outer_diameter_mm = 26.0;  //[13:52:0.1]
thickness_mm      = 1.5;   //[0.75:3:0.05]
eps_mm            = 0.2;   //[0.05:0.5:0.05]

$fn = 128;

module penny_washer(inner_d, outer_d, t, eps=0.2) {
    difference() {
        cylinder(d=outer_d, h=t, center=true);
        cylinder(d=inner_d, h=t + 2*eps, center=true);
    }
}

// Single connected solid: one washer only
penny_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm, eps_mm);