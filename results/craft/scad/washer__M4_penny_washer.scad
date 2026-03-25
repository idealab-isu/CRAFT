// Penny washer: 4.0mm ID, 14.0mm OD, 0.8mm thickness

inner_diameter_mm = 4.0;   // ID
outer_diameter_mm = 14.0;  // OD
thickness_mm      = 0.8;   // thickness
eps_mm            = 0.2;   // cut-through margin

$fn = 128;

module penny_washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm, eps=eps_mm) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps, center=true);
    }
}

penny_washer();