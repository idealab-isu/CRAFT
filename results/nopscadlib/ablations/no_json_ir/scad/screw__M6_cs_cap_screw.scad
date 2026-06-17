// Socket head cap screw (M6-like) with visible threads + hex socket
// Requested: shank Ø6.0, head Ø12.0, overall length 10.0

$fn = 140;

// Dimensions (mm)
shank_diameter   = 6.0;
head_diameter    = 12.0;
overall_length   = 10.0;

// Head proportions (kept typical, but constrained by overall length)
head_height      = 6.0;
shank_length     = max(0.01, overall_length - head_height);

// Hex socket (typical for M6)
hex_socket_af    = 5.0;     // across flats
hex_socket_depth = 4.0;     // recess depth
hex_entry_chamfer_h = 0.6;  // lead-in

// Thread visualization (clear, not ISO-accurate)
thread_pitch     = 1.0;
thread_depth     = 0.45;    // radial depth
threaded_length  = shank_length;

// Small overlaps to ensure watertight unions/differences
eps = 0.03;

module hex_prism_af(af, h) {
    // Regular hex with given across-flats dimension
    // across flats = sqrt(3) * R(circumradius)  => R = af/sqrt(3)
    cylinder(r = af / sqrt(3), h = h, $fn = 6);
}

module threaded_shank(d, h, pitch, depth) {
    // Base cylinder + helical ridge (approximate external thread)
    // Ridge is a thin rectangular "wire" twisted around the shank.
    union() {
        cylinder(d = d, h = h);

        // Helical ridge: place a small rectangle at the outer radius and twist it
        linear_extrude(height = h, twist = -360 * (h / pitch),
                       slices = max(60, ceil(h * 40)))
            translate([d/2 - depth/2, 0, 0])
                square([depth, pitch * 0.55], center = true);
    }
}

module socket_head(d, h) {
    // Slight top edge break to look more like a real cap screw head
    // (kept subtle; still one connected solid)
    union() {
        cylinder(d = d, h = h - 0.4);
        translate([0,0,h - 0.4 - eps])
            cylinder(d1 = d, d2 = d - 0.6, h = 0.4 + eps);
    }
}

module screw() {
    difference() {
        union() {
            // Shank from z=0 to z=shank_length
            threaded_shank(shank_diameter, shank_length, thread_pitch, thread_depth);

            // Head sits on top of shank, connected by formula (no arbitrary translate)
            translate([0, 0, shank_length - eps])
                socket_head(head_diameter, head_height + eps);
        }

        // Hex socket recess: start at top face and go down
        translate([0, 0, overall_length - hex_socket_depth])
            hex_prism_af(hex_socket_af, hex_socket_depth + eps);

        // Entry chamfer for the socket (subtracted), aligned to top
        // Use hex-based chamfer so it reads as a socket entry
        translate([0, 0, overall_length - hex_socket_depth - hex_entry_chamfer_h])
            cylinder(
                r1 = (hex_socket_af / sqrt(3)) * 1.15,
                r2 = (hex_socket_af / sqrt(3)),
                h  = hex_entry_chamfer_h + eps,
                $fn = 6
            );
    }
}

screw();