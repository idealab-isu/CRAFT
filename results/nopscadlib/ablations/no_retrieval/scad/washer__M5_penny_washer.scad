// Penny washer: 5.0mm inner hole, 20.0mm outer diameter, 1.4mm thickness

outer_diameter = 20.0;
inner_diameter = 5.0;
thickness      = 1.4;

overcut = 0.2; // small extra for clean boolean cut

$fn = 180; // high resolution so the hole is truly circular

module washer(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 2*overcut, center=true);
    }
}

washer(outer_diameter, inner_diameter, thickness);