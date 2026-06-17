// Socket head cap screw (M3 x 10) - one connected solid
// Dimensions requested: 3.0mm shank diameter, 6.0mm head diameter, 10mm length (under head)

$fn = 120;

// Parameters
d_nom = 3.0;          // shank major diameter
L = 10.0;             // length under head
head_d = 6.0;         // head diameter
head_h = 3.0;         // head height

// Hex socket (approx for M3)
socket_af = 2.5;      // across flats
socket_depth = 1.6;   // depth

// Simple visual thread approximation (helical ridge)
thread_pitch = 0.5;
thread_depth = 0.18;  // radial height of ridge (visual)
thread_len = L;       // threaded length (full length)
tip_chamfer_h = 0.6;  // end chamfer

// Small overlaps to guarantee manifold unions/differences
eps = 0.02;
ov  = 0.15;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with given across-flats

module hex_socket_cut(af, depth) {
    // Cut from top face downward
    translate([0,0, head_h - depth/2 + ov])
        linear_extrude(height=depth + 2*ov, center=true)
            polygon(points=[
                [ hex_R_from_AF(af)*cos(  0), hex_R_from_AF(af)*sin(  0)],
                [ hex_R_from_AF(af)*cos( 60), hex_R_from_AF(af)*sin( 60)],
                [ hex_R_from_AF(af)*cos(120), hex_R_from_AF(af)*sin(120)],
                [ hex_R_from_AF(af)*cos(180), hex_R_from_AF(af)*sin(180)],
                [ hex_R_from_AF(af)*cos(240), hex_R_from_AF(af)*sin(240)],
                [ hex_R_from_AF(af)*cos(300), hex_R_from_AF(af)*sin(300)]
            ]);
}

module head() {
    // Cylindrical socket head with slight top chamfer
    difference() {
        union() {
            // main head
            cylinder(d=head_d, h=head_h);

            // small underhead fillet-ish ring (kept simple, connected)
            translate([0,0, -ov])
                cylinder(d1=head_d*0.98, d2=d_nom*1.05, h=0.6 + ov);
        }

        // top chamfer (remove a frustum)
        translate([0,0, head_h - 0.35])
            cylinder(d1=head_d + 0.2, d2=head_d - 0.6, h=0.45 + ov);

        // hex socket recess
        hex_socket_cut(socket_af, socket_depth);
    }
}

module shank_core() {
    // Shank starts at z=0 (under head) and goes down to -L
    translate([0,0, -L])
        cylinder(d=d_nom, h=L + ov);
}

module tip_chamfer() {
    // Chamfer at the tip (bottom end)
    translate([0,0, -L - eps])
        cylinder(d1=d_nom, d2=d_nom - 2*0.6, h=tip_chamfer_h + eps);
}

module helical_thread_ridge() {
    // Visual thread ridge: a thin rectangular rib swept helically around the shank
    // Ensures it is connected by overlapping into the shank radius.
    turns = thread_len / thread_pitch;
    rib_w = thread_pitch * 0.45; // along Z per turn (approx)
    rib_t = thread_depth;        // radial thickness

    // Place ridge around radius slightly inside the shank to guarantee union
    r_mid = d_nom/2 - rib_t*0.35;

    translate([0,0, -thread_len])
        linear_extrude(height=thread_len + ov, twist=turns*360, slices=max(40, ceil(turns*40)))
            translate([r_mid, 0, 0])
                square([rib_t*1.2, rib_w], center=true);
}

module screw() {
    union() {
        // Head sits from z=0..head_h
        head();

        // Shank sits from z=0 down to z=-L, with overlap into head
        translate([0,0, -ov])
            shank_core();

        // Thread ridge (visual) on shank
        helical_thread_ridge();

        // Tip chamfer (connected)
        tip_chamfer();
    }
}

screw();