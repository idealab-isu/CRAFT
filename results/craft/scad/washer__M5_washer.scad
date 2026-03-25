// Flat washer: 5.0mm inner hole, 10.0mm outer diameter, 1.0mm thickness

inner_diameter_mm = 5.0;   // ID
outer_diameter_mm = 10.0;  // OD
thickness_mm      = 1.0;   // thickness

$fn = 128;

module washer(id, od, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 0.2, center=true); // slight extra to ensure clean cut
    }
}

washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);