// Flat washer: 4.0mm ID, 9.0mm OD, 0.8mm thickness

id = 4.0;        // inner diameter (mm)
od = 9.0;        // outer diameter (mm)
thickness = 0.8; // thickness (mm)

$fn = 180;       // smooth circular edges

module washer(id, od, thickness) {
    difference() {
        cylinder(h=thickness, r=od/2, center=true);
        cylinder(h=thickness + 0.2, r=id/2, center=true); // slight extra to guarantee clean cut
    }
}

washer(id, od, thickness);