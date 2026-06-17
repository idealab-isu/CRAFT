$fn = 120;

screw_d = 4.0;          // clearance for 4.0mm screw
across_flats = 5.3;     // mm
thickness = 6.3;        // mm

hole_d = screw_d + 0.4; // typical clearance
eps = 0.02;

module hex_prism(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // circumradius R = apothem / cos(30°) = (af/2)/cos(30°)
    R = (af/2) / cos(30);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism(across_flats, thickness);
    translate([0,0,-eps])
        cylinder(h=thickness + 2*eps, d=hole_d, $fn=120);
}