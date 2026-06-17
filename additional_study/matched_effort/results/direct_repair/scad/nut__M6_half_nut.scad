$fn = 120;

af = 11.5;          // across flats (mm)
thickness = 3.0;    // nut thickness (mm)
screw_d = 6.0;      // nominal screw diameter (mm)

// Clearance for M6 (typical): ~6.4 mm
hole_d = 6.4;

// Hex geometry: across flats = 2 * apothem => circumradius = af / sqrt(3)
hex_r = af / sqrt(3);

difference() {
    cylinder(h = thickness, r = hex_r, $fn = 6);
    translate([0, 0, -0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 90);
}