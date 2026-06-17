$fn = 128;

// Linear bearing (LM8UU-like) nominal dimensions
bore_d  = 8.0;
outer_d = 15.0;
len     = 24.0;

eps = 0.02;

// Feature proportions (kept within OD/length; all derived from dimensions)
ring_w      = len * 0.12;                 // end ring width
ring_d      = outer_d * 0.985;            // slight step on OD at ends
groove_w    = len * 0.06;                 // retaining groove width
groove_d    = outer_d * 0.93;             // groove OD (smaller than body)
seal_recess = (outer_d - ring_d) * 0.6;   // small chamfer-like recess depth

// Ball track windows (visual feature only; does not change bore/OD/length)
num_tracks  = 6;
track_w     = outer_d * 0.18;             // circumferential width of each window
track_h     = len * 0.62;                 // axial length of window
track_depth = (outer_d - bore_d) * 0.18;  // radial depth into wall

module bearing_shell() {
    // Outer body with end steps and grooves (all connected)
    union() {
        // Main body
        cylinder(d = outer_d, h = len, center = true);

        // End rings (slight OD step)
        for (s = [-1, 1]) {
            translate([0, 0, s * (len/2 - ring_w/2)])
                cylinder(d = ring_d, h = ring_w, center = true);
        }
    }
}

module retaining_grooves() {
    // Two shallow grooves near ends (subtractive)
    for (s = [-1, 1]) {
        translate([0, 0, s * (len/2 - ring_w - groove_w/2)])
            cylinder(d = groove_d, h = groove_w + 2*eps, center = true);
    }
}

module ball_track_windows() {
    // Shallow windows on OD to suggest ball tracks (subtractive)
    // Positioned so they cut into the outer wall but do not break through to the bore.
    for (i = [0 : num_tracks-1]) {
        rotate([0, 0, i * 360/num_tracks])
            translate([outer_d/2 - track_depth/2, 0, 0])
                cube([track_depth + 2*eps, track_w, track_h], center = true);
    }
}

difference() {
    // Outer form
    bearing_shell();

    // Through bore (guaranteed visible from both ends)
    cylinder(d = bore_d, h = len + 2*eps, center = true);

    // Retaining grooves (cut into OD)
    retaining_grooves();

    // Ball track windows (cut into OD)
    ball_track_windows();

    // Small seal recesses at both ends (subtractive, shallow)
    for (s = [-1, 1]) {
        translate([0, 0, s * (len/2 - ring_w/2)])
            cylinder(d1 = ring_d, d2 = ring_d - 2*seal_recess, h = ring_w + 2*eps, center = true);
    }
}