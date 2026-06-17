$fn = 128;

// HT 50 pipe (nominal): outer diameter 50 mm, length 1500 mm
pipe_od  = 50;     // mm
wall_t   = 2;      // mm
pipe_len = 1500;   // mm

// Simple socket-like end fittings (fully connected)
socket_len = 20;           // mm (axial length of each socket)
socket_od  = pipe_od + 10; // mm (outer diameter at socket)
overlap    = 0.5;          // mm (ensures watertight union/difference)

module tube_z(od, id, h, center=true) {
    difference() {
        cylinder(h=h, d=od, center=center);
        cylinder(h=h + 2*overlap, d=id, center=center);
    }
}

module ht_pipe() {
    id = pipe_od - 2*wall_t;

    // Build as one connected solid: outer union, then subtract one continuous inner bore
    difference() {
        union() {
            // Outer main pipe
            cylinder(h=pipe_len, d=pipe_od, center=true);

            // Outer socket sleeves, overlapped into main pipe
            for (s = [-1, 1]) {
                translate([0, 0, s*(pipe_len/2 - socket_len/2 + overlap)])
                    cylinder(h=socket_len + 2*overlap, d=socket_od, center=true);
            }
        }

        // Inner bore (continuous through entire length, including sockets)
        cylinder(h=pipe_len + 2*socket_len + 4*overlap, d=id, center=true);
    }
}

// Orient along X so FRONT/BACK/LEFT/RIGHT orthographic views show the 1500 mm length
rotate([0, 90, 0]) ht_pipe();