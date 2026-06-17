// HT 40 pipe 1500 mm with socket/bell end (one connected solid)
// Units: mm

$fn = 160;

// Nominal: HT DN40 (typical OD ~40 mm)
outer_diameter = 40;      // pipe OD
wall_thickness = 1.8;     // wall thickness
length = 1500;            // overall length including socket

// Socket/bell parameters (typical HT pipe feature)
socket_length = 55;       // axial length of socket
socket_od = 50;           // socket outer diameter (bell)
socket_wall = 2.2;        // socket wall thickness
insertion_depth = 35;     // depth where pipe OD fits inside socket
lead_in = 6;              // chamfer/lead-in length at socket mouth
overlap = 1;              // overlap to guarantee connectivity

eps = 0.02;

module tube(h, od, wt) {
    difference() {
        cylinder(h=h, d=od, center=false);
        translate([0, 0, -eps])
            cylinder(h=h + 2*eps, d=od - 2*wt, center=false);
    }
}

module socket_bell(sock_h, sock_od, sock_wt, ins_depth, lead, pipe_od, pipe_wt) {
    // Socket is a hollow bell with an internal step:
    // - Mouth region: larger ID (sock_od - 2*sock_wt)
    // - Inner region (toward pipe): ID matches pipe ID so the pipe wall continues
    sock_id = sock_od - 2*sock_wt;
    pipe_id = pipe_od - 2*pipe_wt;

    union() {
        // Outer bell shell
        difference() {
            cylinder(h=sock_h, d=sock_od, center=false);

            // Internal cavity: larger ID for most of socket length
            translate([0, 0, -eps])
                cylinder(h=sock_h - ins_depth + eps, d=sock_id, center=false);

            // Internal cavity: transition to pipe ID near the back of socket
            translate([0, 0, sock_h - ins_depth - eps])
                cylinder(h=ins_depth + 2*eps, d=pipe_id, center=false);

            // Lead-in chamfer at mouth (simple conical flare)
            translate([0, 0, -eps])
                cylinder(h=lead + 2*eps, d1=sock_id + 2.0, d2=sock_id, center=false);
        }

        // Small external collar ring at mouth for clearer HT look (connected)
        collar_h = 3;
        collar_od = sock_od + 2;
        translate([0, 0, 0])
            tube(collar_h, collar_od, sock_wt);
    }
}

module ht_pipe() {
    // Place pipe along X so front/back/left/right orthographic views show length
    rotate([0, 90, 0]) {
        union() {
            // Main pipe body (excluding socket length)
            tube(length - socket_length + overlap, outer_diameter, wall_thickness);

            // Socket at the end, overlapping into pipe for guaranteed connectivity
            translate([0, 0, (length - socket_length) - overlap])
                socket_bell(socket_length, socket_od, socket_wall,
                            insertion_depth, lead_in,
                            outer_diameter, wall_thickness);
        }
    }
}

ht_pipe();