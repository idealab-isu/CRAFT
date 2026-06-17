// Rubber washer: 3.0mm inner hole, 10.0mm outer diameter, 1.5mm thickness

inner_diameter_mm = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm = 10.0;  //[5.0:20.0:0.1]
thickness_mm      = 1.5;   //[0.75:3.0:0.05]

eps_mm = 0.02;             // small overlap for clean boolean
$fn = 128;                 // smooth circular hole and OD

module rubber_washer() {
    color([0.2, 0.2, 0.2])  // rubber-like dark gray
    difference() {
        cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
        cylinder(d=inner_diameter_mm, h=thickness_mm + 2*eps_mm, center=true);
    }
}

rubber_washer();