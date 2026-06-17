$fn = 96;

across_flats = 5.5;   // mm
thickness    = 1.8;   // mm
hole_d       = 3.0;   // mm (clearance as specified)

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2) / cos(30°)
    R = (af/2) / cos(30);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(h=thickness+0.4, d=hole_d, $fn=96);
}