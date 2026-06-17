// Socket Head Cap Screw - M8 x 10 (requested dims)
// Shank Ø8.0, length under head 10.0
// Head Ø13.0, head height 8.0
// One connected solid with a true helical external thread (modeled as a helical ridge)
// and an internal hex socket.

$fn = 160;

// ---- Parameters (mm) ----
shank_d = 8.0;          // major diameter
shank_L = 10.0;         // length under head
head_d  = 13.0;         // head diameter
head_H  = 8.0;          // head height

socket_hex_af = 6.0;    // across flats (approx for M8)
socket_depth  = 5.0;    // socket depth

// Thread (visual but helical and external)
thread_pitch = 1.25;    // M8 coarse
thread_depth = 0.55;    // radial protrusion beyond shank major cylinder (visual)
thread_starts = 1;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;
overlap = 0.25;

// Chamfers
head_top_chamfer_h = 0.8;
tip_chamfer_h      = 0.8;

// ---- Derived Z positions (head on top, shank below) ----
z_head_bot  = 0;
z_head_top  = head_H;
z_shank_top = 0;
z_shank_bot = -shank_L;

// ---- Helpers ----
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex with given across-flats

module hex_prism(af, h, center=false) {
    R = hex_R_from_AF(af);
    linear_extrude(height=h, center=center)
        polygon(points=[ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Helical external thread ridge using rotate_extrude of a small rectangle,
// then linearly extruded with twist to create a true helix.
module helical_thread_ridge(major_d, pitch, length, depth, starts=1) {
    turns = length / pitch;

    // Cross-section of the ridge (in X-Z plane for rotate_extrude):
    // radial thickness = depth, axial thickness = pitch*0.45
    rib_ax = pitch * 0.45;
    rib_rad = max(0.25, depth);

    // Place ridge so its inner face sits at the shank major radius
    r_in = major_d/2 - eps;

    // Build each start as a twisted extrusion of a ring segment
    for (s = [0:starts-1]) {
        rotate([0,0, s*360/starts])
            translate([0,0, z_shank_bot])
                linear_extrude(
                    height = length + overlap,
                    twist  = turns*360,
                    slices = max(ceil(turns*80), 120),
                    convexity = 10
                )
                    rotate_extrude(angle=360, convexity=10)
                        translate([r_in, 0, 0])
                            square([rib_rad, rib_ax], center=false);
    }
}

// ---- Main geometry ----
module screw_body() {
    union() {
        // Shank (major diameter) - centered on shank span
        translate([0,0,(z_shank_bot+z_shank_top)/2])
            cylinder(h=shank_L + overlap, r=shank_d/2, center=true);

        // Head - centered on head span
        translate([0,0,(z_head_bot+z_head_top)/2])
            cylinder(h=head_H + overlap, r=head_d/2, center=true);

        // Head top chamfer
        translate([0,0, z_head_top - head_top_chamfer_h/2])
            cylinder(
                h=head_top_chamfer_h + overlap,
                r1=head_d/2,
                r2=max(head_d/2 - head_top_chamfer_h, shank_d/2),
                center=true
            );

        // Tip chamfer
        translate([0,0, z_shank_bot + tip_chamfer_h/2])
            cylinder(
                h=tip_chamfer_h + overlap,
                r1=shank_d/2,
                r2=max(shank_d/2 - tip_chamfer_h, 0.1),
                center=true
            );

        // External helical thread ridge (true helix)
        helical_thread_ridge(shank_d, thread_pitch, shank_L, thread_depth, thread_starts);
    }
}

module screw_with_socket() {
    difference() {
        screw_body();

        // Hex socket recess from top
        translate([0,0, z_head_top - socket_depth/2 + eps])
            hex_prism(socket_hex_af, socket_depth + overlap, center=true);

        // Small lead-in at socket mouth
        translate([0,0, z_head_top - 0.6/2 + eps])
            cylinder(
                h=0.6 + overlap,
                r1=hex_R_from_AF(socket_hex_af) * 1.10,
                r2=hex_R_from_AF(socket_hex_af),
                center=true
            );
    }
}

// ---- Output ----
screw_with_socket();