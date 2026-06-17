$fn = 96;

across_flats = 8.0;     // mm
thickness    = 2.7;     // mm
hole_d       = 5.0;     // mm (clearance as specified)

module hex_prism_af(af, h){
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2]) cylinder(h=thickness+0.4, d=hole_d, $fn=96);
}