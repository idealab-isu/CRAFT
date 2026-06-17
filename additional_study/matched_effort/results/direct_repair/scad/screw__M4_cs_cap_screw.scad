$fn=96;

// Socket Head Cap Screw (approx. ISO 4762)
// Parameters from prompt:
d_shank = 4.0;      // mm
d_head  = 8.0;      // mm
L       = 10.0;     // mm overall length under head
k       = 4.0;      // head height (typical for M4)
socket_d = 3.0;     // hex socket across flats (typical for M4)
socket_depth = 2.5; // socket depth (typical)
tip_chamfer = 0.4;  // small chamfer at end
head_edge_chamfer = 0.35;

module hex_prism_af(af, h){
    // Regular hex with given across-flats
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module chamfered_cylinder(h, d, chamfer=0.3){
    // Simple chamfer both ends by subtracting cones
    difference(){
        cylinder(h=h, d=d);
        // bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=chamfer+0.02, d1=d+2*chamfer, d2=d);
        // top chamfer
        translate([0,0,h-chamfer-0.01])
            cylinder(h=chamfer+0.02, d1=d, d2=d+2*chamfer);
    }
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shank
            translate([0,0,0])
                cylinder(h=L, d=d_shank);

            // Tip chamfer
            translate([0,0,0])
                difference(){
                    cylinder(h=tip_chamfer, d=d_shank);
                    translate([0,0,-0.01])
                        cylinder(h=tip_chamfer+0.02, d1=d_shank+2*tip_chamfer, d2=d_shank);
                }

            // Head
            translate([0,0,L])
                chamfered_cylinder(h=k, d=d_head, chamfer=head_edge_chamfer);
        }

        // Hex socket cut
        translate([0,0,L + k - socket_depth])
            hex_prism_af(socket_d, socket_depth + 0.2);
    }
}

socket_head_cap_screw();