$fn = 96;

// Socket Head Cap Screw (approx. ISO 4762)
// Parameters from prompt:
d_shank = 4.0;      // mm (nominal thread/shank diameter)
L = 10.0;           // mm (under-head length)
d_head = 8.0;       // mm (head diameter)

// Reasonable defaults for an M4-ish SHCS:
k_head = 4.0;       // mm (head height)
hex_af = 3.0;       // mm (hex key across flats, typical for M4)
hex_depth = 2.2;    // mm (socket depth)
tip_chamfer = 0.35; // mm (small chamfer on shank end)
underhead_chamfer = 0.25; // mm

module hex_socket(af, depth) {
    // Hex prism sized by across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height = depth)
        polygon([ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module shank(d, len) {
    // Add a small chamfer at the tip
    union() {
        cylinder(d = d, h = len - tip_chamfer);
        translate([0,0,len - tip_chamfer])
            cylinder(d1 = d, d2 = max(d - 2*tip_chamfer, 0.01), h = tip_chamfer);
    }
}

module head(d, h) {
    // Slight underhead chamfer
    union() {
        cylinder(d = d, h = h);
        // underhead chamfer ring (subtract via hull-like frustum)
        // implemented as a small frustum at the bottom edge
        translate([0,0,0])
            cylinder(d1 = d - 2*underhead_chamfer, d2 = d, h = underhead_chamfer);
    }
}

difference() {
    union() {
        // Shank from z=0..L
        shank(d_shank, L);

        // Head on top from z=L..L+k_head
        translate([0,0,L])
            head(d_head, k_head);
    }

    // Hex socket cut into head from top
    translate([0,0,L + k_head - hex_depth])
        hex_socket(hex_af, hex_depth + 0.2);
}