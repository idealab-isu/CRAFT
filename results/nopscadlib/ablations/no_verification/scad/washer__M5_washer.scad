// Flat washer: 5.0mm ID, 10.0mm OD, 1.0mm thickness

inner_diameter_mm = 5.0;   //[2.5:10.0:0.1]
outer_diameter_mm = 10.0;  //[5.0:20.0:0.1]
thickness_mm      = 1.0;   //[0.5:2.0:0.1]
eps_mm            = 0.2;   //[0.01:1.0:0.01]

$fn = 128;

module washer(id_mm, od_mm, t_mm, eps=0.2) {
    difference() {
        cylinder(d=od_mm, h=t_mm, center=true);
        cylinder(d=id_mm, h=t_mm + 2*eps, center=true);
    }
}

washer(inner_diameter_mm, outer_diameter_mm, thickness_mm, eps_mm);