$fn = 120;

screw_d = 8.0;          // mm (clearance hole)
across_flats = 13.0;    // mm
thickness = 4.0;        // mm

// Hex geometry: across_flats = 2 * apothem
apothem = across_flats / 2;
outer_R = apothem / cos(30); // circumradius for hex

difference() {
    // Outer hex prism
    cylinder(h = thickness, r = outer_R, $fn = 6);

    // Through hole for screw
    translate([0, 0, -0.2])
        cylinder(h = thickness + 0.4, d = screw_d, $fn = 120);
}