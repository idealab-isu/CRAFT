// Penny washer: 5.0mm ID, 20.0mm OD, 1.4mm thickness

inner_diameter_mm = 5.0;
outer_diameter_mm = 20.0;
thickness_mm      = 1.4;

eps_mm = 0.02;                 // small cut-through margin
$fn = 180;                     // high resolution for truly round holes

module penny_washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps_mm, center=true);
    }
}

penny_washer();