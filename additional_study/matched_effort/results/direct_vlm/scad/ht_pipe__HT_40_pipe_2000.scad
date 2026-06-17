$fn = 128;

// HT 40 pipe (approx.): OD 40 mm, wall ~1.8 mm, total length 2000 mm
od   = 40;
wall = 1.8;
len  = 2000;

id = od - 2*wall;
eps = 0.2;

// Simple HT socket/bell end (approx. proportions)
socket_len  = 55;          // axial length of socket
socket_od   = 46;          // outer diameter at socket
socket_wall = 2.2;         // socket wall thickness
socket_id   = socket_od - 2*socket_wall;

// Small external stop ring near socket end (typical visual feature)
ring_w  = 6;
ring_od = 48;

// Orient along X so orthographic views show length clearly
rotate([0, 90, 0])
difference() {
    union() {
        // Main pipe outer
        cylinder(h = len, d = od, center = true);

        // Socket/bell outer at +X end, connected with slight overlap
        translate([len/2 - socket_len/2 + eps, 0, 0])
            cylinder(h = socket_len + 2*eps, d = socket_od, center = true);

        // External stop ring at the very end of the socket
        translate([len/2 - ring_w/2 + eps, 0, 0])
            cylinder(h = ring_w + 2*eps, d = ring_od, center = true);
    }

    union() {
        // Main pipe inner void (through)
        cylinder(h = len + 2*eps, d = id, center = true);

        // Socket inner void (larger ID), open at end
        translate([len/2 - socket_len/2 + eps, 0, 0])
            cylinder(h = socket_len + 4*eps, d = socket_id, center = true);
    }
}