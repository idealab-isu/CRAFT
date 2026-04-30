// NEMA 17 Stepper Motor Mount
// NEMA 17: 42.3mm face, 31mm mounting holes, 22mm boss
nema_size = 42.3;
hole_spacing = 31;
center_bore = 22;
plate_thickness = 4;
flange = 8;

difference() {
    // Main plate
    cube([nema_size + flange*2, nema_size + flange*2, plate_thickness], center=true);

    // Center bore for shaft/boss clearance
    cylinder(d=center_bore, h=plate_thickness+1, center=true, $fn=64);

    // NEMA 17 mounting holes (M3)
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing/2, y * hole_spacing/2, 0])
                cylinder(d=3.2, h=plate_thickness+1, center=true, $fn=32);
        }
    }

    // Corner reliefs
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * nema_size/2, y * nema_size/2, 0])
                cylinder(d=6, h=plate_thickness+1, center=true, $fn=32);
        }
    }
}
