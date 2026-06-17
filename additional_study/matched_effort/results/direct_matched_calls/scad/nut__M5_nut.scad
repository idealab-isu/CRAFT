$fn = 120;

screw_d = 5.0;          // nominal screw diameter (mm)
clearance = 0.4;        // typical clearance for M5 (mm)
hole_d = screw_d + clearance;

across_flats = 9.2;     // mm
thickness = 4.0;        // mm

// For a regular hexagon: across_flats = sqrt(3) * circumradius
R = across_flats / sqrt(3);

difference() {
    cylinder(h = thickness, r = R, $fn = 6);
    translate([0,0,-0.1]) cylinder(h = thickness + 0.2, d = hole_d, $fn = 90);
}