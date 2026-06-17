$fn = 96;

// Socket head cap screw (approximate ISO 4762 M4x10 proportions)
thread_diameter = 4.0;      // mm (major diameter)
overall_length  = 10.0;     // mm (under head to tip)
head_diameter   = 8.0;      // mm
head_height     = 4.0;      // mm

// Hex socket (approx for M4)
hex_flat        = 3.0;      // mm across flats
hex_socket_depth= 2.5;      // mm

// Thread approximation (visual)
pitch           = 0.7;      // mm (M4 coarse)
thread_depth    = 0.35;     // mm (radial)
thread_length   = overall_length; // fully threaded for this model

// Small overlaps to ensure one connected solid / robust boolean
eps = 0.02;
overlap = 0.2;

module hex_prism(af, h) {
    // Regular hex with given across-flats (af)
    // For a regular hex: across-flats = 2 * apothem = sqrt(3) * R
    // => R (circumradius) = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module external_thread(d_major, length, pitch, depth) {
    // Simple helical ridge (not a true ISO profile, but clearly threaded)
    r_major = d_major/2;
    r_root  = r_major - depth;

    union() {
        // Root cylinder
        cylinder(h=length, r=r_root);

        // Helical ridge (rectangular section) around root
        linear_extrude(height=length, twist=360*length/pitch, slices=max(ceil(length*12), 60))
            translate([r_root, -pitch*0.18, 0])
                square([depth, pitch*0.36], center=false);
    }
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank + threads (from z=0 to z=overall_length)
            external_thread(thread_diameter, thread_length, pitch, thread_depth);

            // Head (from z=overall_length to z=overall_length+head_height), overlapped into shank
            translate([0, 0, overall_length - overlap])
                cylinder(h=head_height + overlap, d=head_diameter);

            // Small under-head fillet/chamfer (connected via overlap)
            translate([0, 0, overall_length - overlap])
                cylinder(h=0.6 + overlap, d1=thread_diameter, d2=head_diameter);
        }

        // Hex socket recess in head (subtracted)
        translate([0, 0, overall_length + head_height - hex_socket_depth - eps])
            hex_prism(hex_flat, hex_socket_depth + 2*eps);

        // Slight top chamfer inside socket (optional, subtle)
        translate([0, 0, overall_length + head_height - 0.6 - eps])
            cylinder(h=0.6 + 2*eps, d1=(hex_flat*1.05), d2=(hex_flat*0.95), $fn=6);
    }
}

socket_head_cap_screw();