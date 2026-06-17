$fn = 96;

// Socket Head Cap Screw (approx. ISO 4762)
// Given: shank diameter = 5.0mm, head diameter = 10.0mm, length under head = 10mm

d_shank = 5.0;
d_head  = 10.0;
L       = 10.0;

// Typical proportions for M5 socket head cap screw
k_head  = 5.0;   // head height (approx)
s_hex   = 4.0;   // hex socket across flats (approx)
t_hex   = 3.0;   // socket depth (approx)

module hex_prism(af, h){
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw(d_shank, d_head, L, k_head, s_hex, t_hex){
    difference(){
        union(){
            // Shank (unthreaded representation)
            cylinder(h=L, d=d_shank);

            // Head
            translate([0,0,L])
                cylinder(h=k_head, d=d_head);
        }

        // Hex socket cut
        translate([0,0,L + k_head - t_hex])
            hex_prism(s_hex, t_hex + 0.2);
    }
}

socket_head_cap_screw(d_shank, d_head, L, k_head, s_hex, t_hex);