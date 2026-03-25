// Permanent magnet: 8.0mm diameter, 4.2mm tall

outer_diameter_mm = 8.0;   //[4:16:0.1]
height_mm         = 4.2;   //[2.1:8.4:0.1]
inner_diameter_mm = 0.0;   //[0:6:0.1]
eps_mm            = 0.2;   //[0.05:1:0.05]

$fn = 128;

module magnet(od=outer_diameter_mm, h=height_mm, id=inner_diameter_mm, eps=eps_mm) {
    // Single connected solid by default (no bore)
    color([0.72, 0.45, 0.2])
    if (id <= 0) {
        cylinder(d=od, h=h, center=false);
    } else {
        difference() {
            cylinder(d=od, h=h, center=false);
            translate([0, 0, -eps])
                cylinder(d=id, h=h + 2*eps, center=false);
        }
    }
}

magnet();