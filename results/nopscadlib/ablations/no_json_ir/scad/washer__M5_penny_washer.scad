// Penny washer: 5.0mm ID, 20.0mm OD, 1.4mm thickness

inner_diameter = 5.0;
outer_diameter = 20.0;
thickness      = 1.4;

$fa = 2;   // finer angular resolution for smooth circles
$fs = 0.2; // finer segment length for smooth circles

module penny_washer(id=inner_diameter, od=outer_diameter, h=thickness) {
    difference() {
        cylinder(d=od, h=h, center=true);
        // Through-hole: extend beyond thickness to guarantee a clean cut
        cylinder(d=id, h=h + 2, center=true);
    }
}

penny_washer();