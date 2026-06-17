// Penny washer parameters (mm)
inner_diameter_mm = 5.0;   // ID
outer_diameter_mm = 20.0;  // OD
thickness_mm      = 1.4;   // thickness
eps_mm            = 0.02;  // small overlap for clean boolean

$fn = 128;

module penny_washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm) {
    difference() {
        cylinder(h=t, r=od/2, center=true);
        cylinder(h=t + 2*eps_mm, r=id/2, center=true);
    }
}

penny_washer();