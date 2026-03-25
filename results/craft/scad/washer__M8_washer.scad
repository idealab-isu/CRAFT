// Flat washer: 8.0mm ID, 17.0mm OD, 1.6mm thickness

inner_diameter = 8.0;   //[4:16:0.1]
outer_diameter = 17.0;  //[8.5:34:0.1]
thickness      = 1.6;   //[0.8:3.2:0.1]
eps            = 0.2;   //[0.05:0.5:0.05]

$fn = 128;

module washer(id=inner_diameter, od=outer_diameter, h=thickness) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 2*eps, center=true);
    }
}

washer();