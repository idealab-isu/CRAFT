$fn = 96;

// T-slot nut parameters (mm)
screw_d = 3.0;          // for M3 clearance
across_flats = 6.0;     // hex across flats
thickness = 3.0;        // nut thickness

// Practical clearances
hole_d = 3.4;           // M3 clearance
hex_af = across_flats + 0.2; // slight oversize for print tolerance

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem = sqrt(3) * R
    // where R is circumradius (center to vertex)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

difference() {
    hex_prism_af(hex_af, thickness);
    translate([0,0,-0.2]) cylinder(h=thickness+0.4, d=hole_d);
}