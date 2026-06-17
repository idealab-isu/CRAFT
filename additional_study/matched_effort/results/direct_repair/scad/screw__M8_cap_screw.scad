$fn=128;

// Socket Head Cap Screw (approximate)
// Shank diameter: 8.0 mm
// Head diameter: 13.0 mm
// Head height: 8.0 mm
// Length under head: 10.0 mm

d_shank = 8.0;
d_head  = 13.0;
h_head  = 8.0;
L       = 10.0;

// Hex socket (approximate for M8 SHCS: 6 mm across flats)
hex_af = 6.0;
hex_depth = 5.0;          // typical socket depth
hex_clear = 0.15;         // clearance for rendering/fit

// Small edge chamfers (visual)
chamfer = 0.6;

module hex_prism(af, h){
    // Regular hex with given across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module shank(){
    cylinder(h=L, d=d_shank);
}

module head(){
    // Head with slight top chamfer and under-head fillet-ish chamfer
    difference(){
        union(){
            // Main head body
            cylinder(h=h_head, d=d_head);

            // Under-head chamfer (adds a tiny flare to avoid sharp edge)
            translate([0,0,0])
                cylinder(h=chamfer, d1=d_head, d2=d_head-2*chamfer);

            // Top chamfer (reduces top edge)
            translate([0,0,h_head-chamfer])
                cylinder(h=chamfer, d1=d_head-2*chamfer, d2=d_head);
        }

        // Hex socket cut
        translate([0,0,h_head-hex_depth])
            hex_prism(hex_af + hex_clear, hex_depth + 0.2);
    }
}

union(){
    // Shank from z=0 to z=L
    shank();

    // Head sits on top of shank
    translate([0,0,L])
        head();
}