// Penny washer parameters (mm)
inner_diameter = 6.0;   // ID
outer_diameter = 26.0;  // OD
thickness      = 1.5;   // thickness
eps            = 0.2;   // small extra for clean through-cut

$fn = 128;

module penny_washer(id=inner_diameter, od=outer_diameter, t=thickness) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 2*eps, center=true);
    }
}

penny_washer();