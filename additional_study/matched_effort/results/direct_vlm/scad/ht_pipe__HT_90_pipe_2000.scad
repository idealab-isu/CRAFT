$fn = 128;

// HT 90 (DN90) 90° elbow with socket, overall centerline length 2000 mm
// Model is oriented in the XY plane: one leg along +X, the other along +Y.
// This avoids "tiny ring" orthographic views caused by a long Z-oriented pipe.

pipe_length = 2000;      // mm overall centerline length (end-to-end along centerline)
outer_diameter = 90;     // mm
wall_thickness = 3.2;    // mm

outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

// Socket/bell parameters
socket_len = 70;                 // axial length of socket
socket_outer_d = 110;            // outer diameter at socket body
socket_outer_r = socket_outer_d/2;

socket_wall = 4.0;               // socket wall thickness
socket_inner_r = socket_outer_r - socket_wall;

// External stop ring near socket mouth
ring_len = 8;
ring_radial = 2.5;

// Bend geometry (centerline radius)
bend_centerline_r = 120;         // mm (typical-ish for DN90; adjust if needed)

// Small overlap to ensure watertight unions/differences
eps = 0.2;

module tube_z(h, ro, ri) {
    difference() {
        cylinder(h=h, r=ro, center=false);
        translate([0,0,-eps]) cylinder(h=h+2*eps, r=ri, center=false);
    }
}

module elbow_shell_90(ro, ri, Rcl) {
    // 90° elbow as a hollow torus segment (centerline radius Rcl)
    // Built by rotate_extrude of an annulus cross-section.
    difference() {
        rotate_extrude(angle=90, convexity=10)
            translate([Rcl, 0, 0]) circle(r=ro);
        rotate_extrude(angle=90, convexity=10)
            translate([Rcl, 0, 0]) circle(r=ri);
    }
}

module ht90_elbow_pipe_2000() {
    // Total centerline length = (leg1 + leg2) + arc_len
    arc_len = PI/2 * bend_centerline_r;
    straight_total = pipe_length - arc_len;
    leg_len = straight_total/2;

    // Ensure non-negative legs
    leg_len_ok = (leg_len > 0) ? leg_len : 0;

    union() {
        // 90° elbow at origin, spanning from +X to +Y
        elbow_shell_90(outer_r, inner_r, bend_centerline_r);

        // Straight leg along +X, tangent to elbow at angle 0°
        // Tangency point is at (Rcl, 0). Extend in +X.
        translate([bend_centerline_r - eps, 0, 0])
            rotate([0, 90, 0])
                tube_z(leg_len_ok + eps, outer_r, inner_r);

        // Straight leg along +Y, tangent to elbow at angle 90°
        // Tangency point is at (0, Rcl). Extend in +Y.
        translate([0, bend_centerline_r - eps, 0])
            rotate([-90, 0, 0])
                tube_z(leg_len_ok + eps, outer_r, inner_r);

        // Socket on the +X leg end (bell end)
        // Socket starts at the end of the +X leg and extends further in +X.
        translate([bend_centerline_r + leg_len_ok - eps, 0, 0])
            rotate([0, 90, 0])
                tube_z(socket_len + eps, socket_outer_r, socket_inner_r);

        // External stop ring at socket mouth (at the very end of socket)
        // Ring is a short sleeve that overlaps the socket OD.
        translate([bend_centerline_r + leg_len_ok + socket_len - ring_len - eps, 0, 0])
            rotate([0, 90, 0])
                difference() {
                    cylinder(h=ring_len + eps, r=socket_outer_r + ring_radial, center=false);
                    translate([0,0,-eps]) cylinder(h=ring_len + 3*eps, r=socket_outer_r - eps, center=false);
                }
    }
}

ht90_elbow_pipe_2000();