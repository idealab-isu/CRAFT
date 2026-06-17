$fn = 120;

screw_d = 8.0;          // nominal screw diameter (mm)
clearance = 0.6;        // typical clearance for M8 (mm)
hole_d = screw_d + clearance;

across_flats = 15.0;    // mm
thickness = 6.5;        // mm

// For a regular hexagon: across_flats = sqrt(3) * circumradius
hex_R = across_flats / sqrt(3);

difference() {
    cylinder(h = thickness, r = hex_R, $fn = 6);
    translate([0,0,-0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 120);
}