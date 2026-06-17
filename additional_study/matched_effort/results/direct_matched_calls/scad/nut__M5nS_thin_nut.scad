$fn = 96;

screw_d = 5.0;          // nominal screw diameter (mm)
clearance = 0.4;        // typical clearance for M5 (mm)
hole_d = screw_d + clearance;

across_flats = 8.0;     // mm
thickness = 2.7;        // mm

// For a regular hexagon: across_flats = 2 * apothem
apothem = across_flats / 2;
outer_r = apothem / cos(30);  // circumradius

difference() {
    cylinder(h = thickness, r = outer_r, $fn = 6);
    translate([0, 0, -0.1])
        cylinder(h = thickness + 0.2, d = hole_d, $fn = 96);
}