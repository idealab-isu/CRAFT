$fn = 128;

// Socket Head Cap Screw
// Shank major diameter: 6.0 mm
// Head diameter: 12.0 mm
// Length under head: 10.0 mm

d_shank = 6.0;
l_under_head = 10.0;

d_head  = 12.0;
h_head  = 6.0;

// Socket (approx for M6 SHCS)
hex_af     = 5.0;
hex_depth  = 3.5;

edge_chamfer = 0.6;
tip_chamfer  = 0.5;

// Thread (visual approximation)
pitch = 1.0;          // M6 coarse
thread_depth = 0.35;  // radial depth (visual)
thread_len = l_under_head;

eps = 0.02;

module hex_prism_af(af, h){
    R = af / sqrt(3); // circumradius for across-flats af
    cylinder(h=h, r=R, $fn=6);
}

module external_thread(d_major, pitch, depth, len){
    // Simple helical ridge (visual thread), fused to shank
    // Root diameter:
    d_root = d_major - 2*depth;

    union(){
        // Root cylinder
        cylinder(h=len, d=d_root);

        // Helical ridge
        linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*12), 60), convexity=10)
            translate([d_root/2, 0, 0])
                circle(r=depth, $fn=24);
    }
}

module shcs(){
    difference(){
        union(){
            // Threaded shank (under head)
            external_thread(d_shank, pitch, thread_depth, thread_len);

            // Tip chamfer (slight)
            translate([0,0,0])
                cylinder(h=tip_chamfer, d1=d_shank - 2*tip_chamfer, d2=d_shank);

            // Head (connected at z = l_under_head)
            translate([0,0,l_under_head - eps])
            union(){
                cylinder(h=h_head - edge_chamfer + eps, d=d_head);
                translate([0,0,h_head - edge_chamfer])
                    cylinder(h=edge_chamfer, d1=d_head, d2=d_head - 2*edge_chamfer);
            }
        }

        // Hex socket cut (from top)
        translate([0,0,l_under_head + h_head - hex_depth])
            hex_prism_af(hex_af, hex_depth + 0.2);

        // Lead-in at socket opening
        translate([0,0,l_under_head + h_head - 0.8])
            cylinder(h=0.9, d1=hex_af*1.25, d2=hex_af*1.05, $fn=48);
    }
}

shcs();