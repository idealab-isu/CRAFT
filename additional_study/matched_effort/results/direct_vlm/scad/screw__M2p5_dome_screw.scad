$fn = 128;

// =====================
// Target dimensions (mm)
// =====================
shaft_d      = 2.5;
shaft_r      = shaft_d/2;

length_shank = 10;          // under-head length (shank length)

head_d       = 5.35;
head_r       = head_d/2;
head_h       = 1.6;

// =====================
// Thread approximation (visual; not ISO-accurate)
// =====================
pitch        = 0.45;        // ~M2.5 coarse pitch
thread_depth = 0.18;        // radial height of thread above minor radius
minor_r      = shaft_r - thread_depth;
minor_r_safe = max(0.05, minor_r);

overlap      = 0.08;        // overlap to guarantee watertight unions

// Helical thread as a twisted extrusion of a small triangular profile
module external_thread(len, r_minor, depth, p) {
    turns = len / p;

    linear_extrude(
        height = len,
        twist = -360 * turns,
        slices = max(ceil(turns * 50), 120),
        convexity = 10
    )
        translate([r_minor, 0])
            polygon(points=[
                [0,      -p*0.22],
                [depth,   0     ],
                [0,       p*0.22]
            ]);
}

// Dome head as a spherical cap with base radius r_base and cap height h
module dome_head(h, r_base) {
    a = r_base;
    R = (a*a + h*h) / (2*h); // sphere radius for cap

    // Cap spans z=0..h
    intersection() {
        translate([0,0,h - R]) sphere(r = R);
        cylinder(h = h, r = r_base);
    }
}

module dome_head_screw() {
    union() {
        // Shank core (minor diameter) for thread to sit on
        cylinder(h = length_shank + overlap, r = minor_r_safe);

        // External thread (adds to reach ~2.5mm major diameter)
        external_thread(length_shank, minor_r_safe, shaft_r - minor_r_safe, pitch);

        // Head: dome directly on top of shank (connected with overlap)
        translate([0,0,length_shank - overlap])
            dome_head(head_h + overlap, head_r);
    }
}

// Ensure consistent orientation in all orthographic views:
// screw axis along Z, head on top, shank below.
dome_head_screw();