$fn = 96;

// Socket Head Cap Screw (approximate, renderable)
// Given: shank diameter = 5.0mm, head diameter = 10.0mm, length under head = 10mm

d_shank = 5.0;
d_head  = 10.0;
L       = 10.0;

// Typical proportions for an M5 socket head cap screw (approx.)
head_h      = 5.0;   // head height
hex_flat    = 4.0;   // hex key size across flats (M5 typically 4mm)
hex_depth   = 3.0;   // socket depth
tip_chamfer = 0.6;   // small chamfer at end of shank
head_edge_r = 0.4;   // slight rounding approximation via chamfer

module hex_prism(af, h){
    // Regular hex with given across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module screw(){
    difference(){
        union(){
            // Shank
            cylinder(h=L, d=d_shank);

            // Tip chamfer (simple frustum)
            translate([0,0,0])
                cylinder(h=tip_chamfer, d1=d_shank*0.85, d2=d_shank);

            // Head with slight edge chamfer approximation
            translate([0,0,L])
                cylinder(h=head_h, d=d_head);

            // Head top chamfer (subtract later would be nicer; approximate by adding a small frustum)
            translate([0,0,L+head_h-head_edge_r])
                cylinder(h=head_edge_r, d1=d_head, d2=d_head*0.96);
        }

        // Hex socket
        translate([0,0,L+head_h-hex_depth])
            hex_prism(hex_flat, hex_depth + 0.2);

        // Slight lead-in at socket opening
        translate([0,0,L+head_h-0.8])
            cylinder(h=0.8, d1=hex_flat*1.15, d2=hex_flat*0.98, $fn=48);
    }
}

screw();