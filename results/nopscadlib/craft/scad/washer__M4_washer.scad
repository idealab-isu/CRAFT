// Flat washer parameters (mm)
inner_diameter_mm = 4.0;   //[2.0:8.0:0.1]
outer_diameter_mm = 9.0;   //[4.5:18.0:0.1]
thickness_mm      = 0.8;   //[0.4:1.6:0.05]
eps_mm            = 0.2;   //[0.05:0.5:0.05]

// Smoothness for circular profiles
$fn = 128;

module flat_washer(id, od, t, eps=0.1) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps, center=true);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm, eps_mm);