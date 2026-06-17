// Flat washer parameters (mm)
inner_diameter_mm = 6.0;   //[3:12:0.1]
outer_diameter_mm = 12.5;  //[6.25:25:0.1]
thickness_mm      = 1.5;   //[0.75:3:0.05]

// Small extra height to guarantee a clean through-hole in CSG
eps_mm = 0.2; //[0.01:1:0.01]

$fn = 128;

module flat_washer(id, od, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps_mm, center=true);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);