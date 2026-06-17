$fn = 140;

// Threaded heat-set insert (M3), 8.0mm OD, 6.0mm long
// Includes: internal helical thread approximation, external knurling, and lead-in chamfers.
// One connected solid (single difference of a single union).

od = 8.0;
len = 6.0;

// Internal thread (approx M3x0.5)
thread_major_d = 3.0;     // nominal major diameter
thread_pitch   = 0.5;
thread_depth   = 0.30;    // radial depth of thread cut (visual/printable approximation)
thread_turns   = len / thread_pitch;

// Minor diameter for core hole before thread cut
thread_minor_d = thread_major_d - 2*thread_depth;

// Lead-in chamfers
chamfer_h = 0.6;          // axial height of chamfer at each end
chamfer_inset = 0.45;     // radial inset from OD at chamfer end

// External knurling (axial ribs)
knurl_count = 24;
knurl_depth = 0.45;                 // radial protrusion beyond base cylinder
knurl_base_r = od/2 - knurl_depth;  // base cylinder radius so knurls bring it back to OD
knurl_w = 0.9;                      // tangential width of each ridge
knurl_overlap = 0.20;               // overlap into base to ensure connectivity

eps = 0.02;

module internal_thread_cut(h, pitch, major_d, depth) {
    // Subtractive helical "V" ridge to approximate internal threading.
    // Built as a twisted linear_extrude of a small triangular profile located at the major radius.
    r_major = major_d/2;
    tri = [
        [r_major - depth, -pitch*0.22],
        [r_major,          0],
        [r_major - depth,  pitch*0.22]
    ];

    // Extend slightly beyond ends for clean boolean
    translate([0, 0, -h/2 - eps])
        linear_extrude(height = h + 2*eps,
                       twist  = 360 * (h / pitch),
                       slices = max(ceil((h/pitch) * 40), 80),
                       convexity = 10)
            polygon(points = tri);
}

module insert_body() {
    union() {
        // Main cylindrical body
        cylinder(r = knurl_base_r, h = len, center = true);

        // External knurls (axial ribs), connected with overlap into base
        for (i = [0 : knurl_count - 1]) {
            rotate([0, 0, i * 360 / knurl_count])
                translate([knurl_base_r + knurl_depth/2 - knurl_overlap, 0, 0])
                    cube([knurl_depth + 2*knurl_overlap, knurl_w, len], center = true);
        }

        // End chamfers (added as frustums) to represent lead-in
        // Top chamfer
        translate([0, 0, len/2 - chamfer_h/2])
            cylinder(h = chamfer_h,
                     r1 = od/2 - chamfer_inset,
                     r2 = od/2,
                     center = true);

        // Bottom chamfer
        translate([0, 0, -len/2 + chamfer_h/2])
            cylinder(h = chamfer_h,
                     r1 = od/2,
                     r2 = od/2 - chamfer_inset,
                     center = true);
    }
}

module threaded_heatset_insert() {
    difference() {
        // ONE connected solid
        insert_body();

        // Core hole (minor diameter) through
        cylinder(d = thread_minor_d, h = len + 0.4, center = true);

        // Helical thread cut (approx)
        internal_thread_cut(len, thread_pitch, thread_major_d, thread_depth);

        // Small entry relief at both ends to suggest lead-in for screw
        translate([0, 0, len/2 - chamfer_h/2])
            cylinder(h = chamfer_h + 0.2, d1 = thread_major_d + 0.6, d2 = thread_minor_d, center = true);

        translate([0, 0, -len/2 + chamfer_h/2])
            cylinder(h = chamfer_h + 0.2, d1 = thread_minor_d, d2 = thread_major_d + 0.6, center = true);
    }
}

threaded_heatset_insert();