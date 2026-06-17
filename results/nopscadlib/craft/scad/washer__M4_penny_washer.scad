// Penny washer parameters (mm)
inner_diameter_mm = 4.0;   //[2.0:8.0:0.1]
outer_diameter_mm = 14.0;  //[7.0:28.0:0.1]
thickness_mm      = 0.8;   //[0.4:1.6:0.05]
eps_mm            = 0.2;   //[0.05:0.5:0.05]

$fn = 128;

module penny_washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm, eps=eps_mm) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps, center=true);
    }
}

// Single connected solid: just the washer
penny_washer();