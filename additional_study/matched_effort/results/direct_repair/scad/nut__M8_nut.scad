$fn = 120;

screw_d = 8.0;          // mm (clearance hole)
across_flats = 15.0;    // mm
thickness = 6.5;        // mm

// Convert across-flats to circumradius for a regular hexagon
R = across_flats / sqrt(3);

difference() {
    // Hex body
    cylinder(h = thickness, r = R, $fn = 6);

    // Through hole
    translate([0, 0, -0.5])
        cylinder(h = thickness + 1.0, d = screw_d, $fn = 120);
}