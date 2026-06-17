$fn = 120;

across_flats = 7.7;   // mm
thickness    = 7.9;   // mm
hole_d       = 6.0;   // mm (clearance as specified)

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem = sqrt(3) * R
    // where R is circumradius (center to vertex)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(h=thickness+0.4, d=hole_d, $fn=120);
}