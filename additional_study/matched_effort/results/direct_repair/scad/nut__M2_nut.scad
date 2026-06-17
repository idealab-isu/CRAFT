$fn = 120;

across_flats = 4.9;   // mm
thickness    = 1.6;   // mm
screw_d      = 2.0;   // mm (nominal)

clearance    = 0.25;  // mm added to screw diameter for through-hole
hole_d       = screw_d + clearance;

module hex_prism(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2)/cos(30°)
    R = (af/2) / cos(30);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(h=thickness+0.2, d=hole_d, $fn=80);
}