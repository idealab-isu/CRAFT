$fn = 128;

// Socket head cap screw (M4-like)
// Shank diameter: 4.0 mm
// Head diameter: 8.0 mm
// Length under head: 10.0 mm

d_nom = 4.0;
L = 10.0;

head_d = 8.0;
head_h = 4.0;

// Typical M4 SHCS hex socket (approx)
socket_hex_af = 3.0;
socket_depth  = 2.5;

// Visible external thread (modeled as a helical cut)
thread_pitch = 0.7;
thread_depth = 0.25;   // radial depth of thread groove
thread_start = 0.6;    // unthreaded length under head
thread_end   = 0.8;    // unthreaded length at tip

// Small edge details
underhead_fillet_h = 0.6;   // conical transition height
tip_chamfer_h      = 0.8;   // chamfer height at tip
head_top_chamfer_h = 0.4;   // small top chamfer

eps = 0.03; // overlap to ensure watertight unions/differences

module hex2d(af){
    R = af / sqrt(3); // circumradius for across-flats = af
    polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module shank_with_thread(){
    // Base shank
    difference(){
        // Full shank cylinder (under head)
        translate([0,0,-L/2])
            cylinder(h=L + 2*eps, r=d_nom/2, center=true);

        // Helical groove to suggest external threads (keeps one connected solid)
        thread_len = max(0, L - thread_start - thread_end);
        turns = thread_len / thread_pitch;

        if (thread_len > 0){
            // Place groove within the threaded region
            translate([0,0,-thread_start - thread_len/2])
                rotate_extrude(angle=360*turns, convexity=10)
                    translate([d_nom/2 - thread_depth/2, 0, 0])
                        circle(r=thread_depth/2, $fn=24);
        }
    }
}

module screw_solid(){
    union(){
        // Head: z from 0 to head_h
        translate([0,0,head_h/2])
            cylinder(h=head_h, r=head_d/2, center=true);

        // Head top chamfer (slight taper at very top), overlaps into head
        translate([0,0,head_h - head_top_chamfer_h/2])
            cylinder(h=head_top_chamfer_h + 2*eps,
                     r1=head_d/2,
                     r2=head_d/2 - head_top_chamfer_h,
                     center=true);

        // Underhead transition (connect head to shank), overlaps both
        translate([0,0,-underhead_fillet_h/2])
            cylinder(h=underhead_fillet_h + 2*eps,
                     r1=head_d/2,
                     r2=d_nom/2,
                     center=true);

        // Shank with visible thread
        shank_with_thread();

        // Tip chamfer at bottom (z near -L), overlaps into shank
        translate([0,0,-L + tip_chamfer_h/2])
            cylinder(h=tip_chamfer_h + 2*eps,
                     r1=d_nom/2,
                     r2=max(0.01, d_nom/2 - tip_chamfer_h),
                     center=true);
    }
}

difference(){
    screw_solid();

    // Hex socket recess in head (from top down), overlaps to avoid artifacts
    translate([0,0,head_h - socket_depth/2 + eps])
        linear_extrude(height=socket_depth + 4*eps, center=true, convexity=10)
            hex2d(socket_hex_af);
}