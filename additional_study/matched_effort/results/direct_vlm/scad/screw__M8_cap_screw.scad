$fn = 128;

// Socket Head Cap Screw (mm)
d_shaft = 8.0;     // shank major diameter
L       = 10.0;    // shank length (under head)

d_head  = 13.0;    // head diameter
h_head  = 8.0;     // head height

// Internal hex socket (approx for M8 SHCS)
socket_af      = 6.0;   // across flats
socket_depth   = 5.0;   // recess depth
socket_chamfer = 0.6;   // entry chamfer height

// Thread approximation (cosmetic helical ridge)
thread_pitch   = 1.25;  // M8 coarse pitch
thread_depth   = 0.45;  // radial height of thread ridge (visual)

// Small overlaps to ensure watertight unions/differences
eps = 0.03;

module hex_prism_af(af, h){
    // Regular hex with given across-flats (af)
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module thread_ridge(d_major, pitch, depth, z0, z1){
    // Single-start helical ridge around a cylinder (cosmetic)
    turns = (z1 - z0) / pitch;
    translate([0,0,z0])
        linear_extrude(height=(z1 - z0),
                       twist=turns*360,
                       slices=max(ceil(turns*60), 120),
                       convexity=10)
            translate([d_major/2 - depth/2, 0, 0])
                circle(d=depth, $fn=24);
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shank core
            cylinder(h=L, d=d_shaft);

            // Cosmetic thread ridge (unioned so threads are visible)
            thread_ridge(d_shaft, thread_pitch, thread_depth, 0, L);

            // Head (connected at z=L with slight overlap)
            translate([0,0,L - eps])
                cylinder(h=h_head + eps, d=d_head);
        }

        // Hex socket recess from top of head downward
        translate([0,0,L + h_head - socket_depth])
            hex_prism_af(socket_af, socket_depth + eps);

        // Entry chamfer at top face of head
        translate([0,0,L + h_head - socket_chamfer])
            cylinder(h=socket_chamfer + eps,
                     r1=(socket_af/sqrt(3)) + 0.8,
                     r2=(socket_af/sqrt(3)),
                     $fn=64);
    }
}

socket_head_cap_screw();