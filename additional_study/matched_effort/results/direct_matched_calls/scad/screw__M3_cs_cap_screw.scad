$fn=96;

// Socket Head Cap Screw (approx. ISO 4762 style)
// Parameters (mm)
d_shank = 3.0;
L = 10.0;

d_head = 6.0;
h_head = 3.0;          // typical for M3 SHCS
fillet_r = 0.25;       // small edge rounding approximation

hex_flat = 2.5;        // typical M3 hex socket across flats
hex_depth = 1.6;       // typical socket depth

module hex_prism_across_flats(af, h){
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module shank(){
    cylinder(h=L, d=d_shank);
}

module head(){
    // Slightly rounded top edge via minkowski (kept small for performance)
    // If minkowski is too heavy, set fillet_r=0.
    if (fillet_r > 0){
        minkowski(){
            cylinder(h=h_head - fillet_r, d=d_head - 2*fillet_r);
            sphere(r=fillet_r);
        }
    } else {
        cylinder(h=h_head, d=d_head);
    }
}

difference(){
    union(){
        shank();
        translate([0,0,L]) head();
    }
    // Hex socket cut
    translate([0,0,L + h_head - hex_depth])
        hex_prism_across_flats(hex_flat, hex_depth + 0.2);
}