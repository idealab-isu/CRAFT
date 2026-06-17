$fn = 80;

// T-slot nut parameters (mm)
across_flats = 6.0;     // hex width across flats
thickness    = 2.75;    // nut thickness
screw_d      = 3.0;     // clearance for 3.0mm screw

// Typical M3 clearance; adjust if you want tighter/looser fit
clearance = 0.3;
hole_d = screw_d + clearance;

// Simple T-slot nut body: hex prism with through-hole
module hex_prism_across_flats(af, h) {
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

difference() {
    hex_prism_across_flats(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 80);
}