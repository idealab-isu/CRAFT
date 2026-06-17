$fn = 120;

screw_d = 5.0;          // mm (clearance hole)
across_flats = 9.2;     // mm
thickness = 4.0;        // mm

// Convert across-flats to circumradius for a regular hexagon
hex_R = across_flats / sqrt(3);

difference() {
    // Hex body
    cylinder(h = thickness, r = hex_R, $fn = 6);

    // Through hole
    translate([0, 0, -0.2])
        cylinder(h = thickness + 0.4, d = screw_d, $fn = 80);
}