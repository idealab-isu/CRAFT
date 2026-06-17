$fn = 128;

// HT 90° pipe (DN ~90) with total centerline length = 1000 mm
// One connected solid: hollow elbow + two straight legs + socket collars at both ends.

module tube_z(len, ro, ri) {
    difference() {
        cylinder(h=len, r=ro, center=false);
        translate([0,0,-0.5]) cylinder(h=len+1, r=ri, center=false);
    }
}

module socket_collar_z(ro, ri, collar_len, collar_thick) {
    difference() {
        cylinder(h=collar_len, r=ro + collar_thick, center=false);
        translate([0,0,-0.5]) cylinder(h=collar_len+1, r=ri, center=false);
    }
}

module elbow_90(ro, ri, bend_r) {
    // Elbow centerline radius = bend_r, ends tangent to +Z and +X.
    // Built in XY plane then rotated so the elbow lies in XZ plane.
    rotate([90,0,0])
    difference() {
        rotate_extrude(angle=90, convexity=10)
            translate([bend_r, 0, 0]) circle(r=ro);
        rotate_extrude(angle=90, convexity=10)
            translate([bend_r, 0, 0]) circle(r=ri);
    }
}

module ht_90_pipe_1000() {
    // Dimensions (mm)
    od = 90;
    wall = 3.2;
    ro = od/2;
    ri = ro - wall;

    bend_r = 120;            // centerline bend radius
    collar_len = 35;
    collar_thick = 4;

    total_centerline = 1000;
    arc_len = PI/2 * bend_r;
    leg_len = (total_centerline - arc_len) / 2;

    leg1 = max(0, leg_len);  // +Z leg
    leg2 = max(0, leg_len);  // +X leg

    overlap = 1.0;           // guaranteed overlap for watertight union

    union() {
        // Elbow: Z-end at (0,0,0), X-end at (bend_r,0,bend_r)
        elbow_90(ro, ri, bend_r);

        // +Z straight leg, starting exactly at elbow Z-end plane (z=0)
        translate([0,0,-overlap])
            tube_z(leg1 + overlap, ro, ri);

        // +X straight leg, starting exactly at elbow X-end plane (x=bend_r, z=bend_r)
        translate([bend_r - overlap, 0, bend_r])
            rotate([0,90,0])
                tube_z(leg2 + overlap, ro, ri);

        // Socket collar at +Z open end (at z=leg1)
        translate([0,0,leg1 - overlap])
            socket_collar_z(ro, ri, collar_len + overlap, collar_thick);

        // Socket collar at +X open end (at x=bend_r+leg2, z=bend_r)
        translate([bend_r + leg2 - overlap, 0, bend_r])
            rotate([0,90,0])
                socket_collar_z(ro, ri, collar_len + overlap, collar_thick);
    }
}

ht_90_pipe_1000();