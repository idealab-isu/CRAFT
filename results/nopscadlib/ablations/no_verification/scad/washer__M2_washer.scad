// Flat washer: 2.0mm ID, 5.0mm OD, 0.3mm thickness

inner_diameter_mm = 2.0;
outer_diameter_mm = 5.0;
thickness_mm      = 0.3;

$fn = 128; // smooth circular profile

module washer(id, od, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 0.2, center=true); // slight extra to guarantee through-hole
    }
}

washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);