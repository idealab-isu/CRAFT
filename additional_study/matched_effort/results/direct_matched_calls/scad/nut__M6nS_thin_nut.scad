$fn = 120;

across_flats = 10.0;   // mm
thickness    = 3.2;    // mm
screw_d      = 6.0;    // mm (clearance hole)

clearance = 0.3;       // mm added to screw diameter for fit

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2) / cos(30°)
    R = (af/2) / cos(30);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(h=thickness+0.2, d=screw_d + clearance, $fn=120);
}