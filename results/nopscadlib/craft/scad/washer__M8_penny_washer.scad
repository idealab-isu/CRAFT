// Penny washer parameters (mm)
inner_diameter_mm = 8.0;   //[4.0:16.0:0.1]
outer_diameter_mm = 30.0;  //[15.0:60.0:0.1]
thickness_mm      = 1.5;   //[0.75:3.0:0.05]

// Small epsilon to guarantee clean through-cut
eps_mm = 0.05; //[0.01:0.5:0.01]

$fn = 180;

// ONE connected solid: a simple penny washer (ring)
module penny_washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps_mm, center=true);
    }
}

penny_washer();