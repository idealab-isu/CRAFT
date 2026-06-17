$fn = 128;

// HT 90 elbow pipe 500 mm (simplified)
// 500 mm interpreted as centerline length from one socket mouth to the other.
pipe_length = 500;                 //[250:1000:1]  // centerline length mouth-to-mouth
outer_diameter = 90;               //[45:180:1]
wall_thickness = 3;                //[1.5:6:0.5]
socket_length = 60;                //[30:120:1]
socket_outer_diameter = 98;        //[92:120:1]
chamfer_length = 6;                //[2:15:1]
overlap = 1;                       //[0.5:2:0.5]

// Bend geometry (simplified)
bend_centerline_radius = 120;      //[60:250:1]    // centerline radius of 90° bend

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

socket_outer_r = socket_outer_diameter/2;
socket_inner_r = socket_outer_r - wall_thickness;

// Centerline lengths
arc_len = bend_centerline_radius * (PI/2);
leg_len = max(0.01, (pipe_length - arc_len) / 2);  // each leg centerline length mouth->tangent

// ---------- Helpers ----------
module tube_z(len, ro, ri) {
    difference() {
        cylinder(h=len, r=ro, center=true);
        cylinder(h=len + 2*overlap, r=ri, center=true);
    }
}

module tube_x(len, ro, ri) {
    rotate([0,90,0]) tube_z(len, ro, ri);
}

module tube_y(len, ro, ri) {
    rotate([90,0,0]) tube_z(len, ro, ri);
}

module socket_z(len, sock_ro, sock_ri) {
    difference() {
        cylinder(h=len, r=sock_ro, center=true);
        cylinder(h=len + 2*overlap, r=sock_ri, center=true);
    }
}

module socket_x(len, sock_ro, sock_ri) {
    rotate([0,90,0]) socket_z(len, sock_ro, sock_ri);
}

module socket_y(len, sock_ro, sock_ri) {
    rotate([90,0,0]) socket_z(len, sock_ro, sock_ri);
}

module chamfer_ring_z(chamfer_len, sock_ro, sock_ri) {
    difference() {
        cylinder(
            h = chamfer_len + 2*overlap,
            r1 = sock_ro,
            r2 = max(sock_ro - chamfer_len, 0.01),
            center = true
        );
        cylinder(
            h = chamfer_len + 2*overlap,
            r1 = sock_ri,
            r2 = max(sock_ri - chamfer_len, 0.01),
            center = true
        );
    }
}

module chamfer_ring_x(chamfer_len, sock_ro, sock_ri) {
    rotate([0,90,0]) chamfer_ring_z(chamfer_len, sock_ro, sock_ri);
}

module chamfer_ring_y(chamfer_len, sock_ro, sock_ri) {
    rotate([90,0,0]) chamfer_ring_z(chamfer_len, sock_ro, sock_ri);
}

// Quarter-torus (90° elbow) around Z axis, lying in XY plane, from +X toward +Y
module quarter_torus(ro, ri, R) {
    intersection() {
        rotate_extrude(angle=90, convexity=10)
            translate([R, 0, 0])
                difference() {
                    circle(r=ro);
                    circle(r=ri);
                }

        // Keep x>=0 and y>=0 half-spaces to ensure a clean 90° quadrant
        union() {
            translate([0, -10000, -10000]) cube([10000, 20000, 20000], center=false); // x >= 0
            translate([-10000, 0, -10000]) cube([20000, 10000, 20000], center=false); // y >= 0
        }
    }
}

// ---------- Main model ----------
module ht90_pipe_500() {
    // Bend center at origin.
    // Tangency points (centerline) at (R,0,0) and (0,R,0).
    union() {
        // 90° bend (hollow)
        quarter_torus(outer_r, inner_r, bend_centerline_radius);

        // Straight leg along +X, connected to bend with overlap
        translate([bend_centerline_radius + leg_len/2 - overlap, 0, 0])
            tube_x(leg_len + 2*overlap, outer_r, inner_r);

        // Straight leg along +Y, connected to bend with overlap
        translate([0, bend_centerline_radius + leg_len/2 - overlap, 0])
            tube_y(leg_len + 2*overlap, outer_r, inner_r);

        // Sockets at both mouths, connected to legs with overlap
        // +X mouth plane at x = R + leg_len + socket_length
        translate([bend_centerline_radius + leg_len + socket_length/2 - overlap, 0, 0])
            socket_x(socket_length + 2*overlap, socket_outer_r, socket_inner_r);

        // +Y mouth plane at y = R + leg_len + socket_length
        translate([0, bend_centerline_radius + leg_len + socket_length/2 - overlap, 0])
            socket_y(socket_length + 2*overlap, socket_outer_r, socket_inner_r);
    }
}

module final_model() {
    difference() {
        ht90_pipe_500();

        // Chamfers at socket mouths (subtractive), aligned to the actual mouth planes
        // +X socket mouth plane at x = R + leg_len + socket_length
        translate([bend_centerline_radius + leg_len + socket_length - chamfer_length/2, 0, 0])
            chamfer_ring_x(chamfer_length, socket_outer_r, socket_inner_r);

        // +Y socket mouth plane at y = R + leg_len + socket_length
        translate([0, bend_centerline_radius + leg_len + socket_length - chamfer_length/2, 0])
            chamfer_ring_y(chamfer_length, socket_outer_r, socket_inner_r);
    }
}

color([0.85, 0.85, 0.8])
final_model();