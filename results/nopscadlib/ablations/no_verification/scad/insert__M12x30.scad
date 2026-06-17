// Threaded heat-set insert (single connected solid)
// Target: 30.0mm OD, 22.0mm long, internal thread for 12.0mm screw

$fn = 160;

// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 22; //[11:44:0.5]

screw_diameter_mm = 12; //[6:24:0.25]          // nominal major diameter
internal_thread_pitch_mm = 1.75; //[0.8:3.5:0.05]

bore_clearance_mm = 0.25; //[0.0:1:0.05]       // small clearance on major diameter
thread_depth_mm = 0.75; //[0.3:1.5:0.05]       // radial depth of thread form (visual + functional)

top_chamfer_mm = 1; //[0.5:2:0.1]
bottom_chamfer_mm = 1; //[0.5:2:0.1]
lead_in_taper_angle_deg = 30; //[15:60:1]      // (kept for UI; not used directly)

knurl_depth_mm = 0.6; //[0.3:1.2:0.05]
knurl_pitch_mm = 1.2; //[0.6:2.4:0.05]
knurl_length_mm = 18; //[9:36:0.5]
knurl_ring_count = 12; //[6:30:1]

top_face_recess_depth_mm = 0.8; //[0.3:2:0.1]
top_face_recess_diameter_mm = 18; //[10:28:0.5]

overlap_mm = 0.8; //[0.5:2:0.1]

// ---------- Helpers ----------
function clamp(x, a, b) = min(max(x, a), b);

module chamfered_cylinder(h, r, chamfer_top, chamfer_bottom) {
    // Robust even if chamfers exceed height
    ct = clamp(chamfer_top, 0, h/2 - 0.01);
    cb = clamp(chamfer_bottom, 0, h/2 - 0.01);
    mid_h = max(0.02, h - ct - cb);

    union() {
        cylinder(h = mid_h, r = r, center = true);

        translate([0, 0, (h/2) - ct/2])
            cylinder(h = max(0.02, ct), r1 = r, r2 = max(0.01, r - ct), center = true);

        translate([0, 0, -(h/2) + cb/2])
            cylinder(h = max(0.02, cb), r1 = max(0.01, r - cb), r2 = r, center = true);
    }
}

// Internal thread "cutter": helical triangular ridge subtracted from the bore.
// FIX: Use rotate_extrude() profile then linear_extrude(twist=...) to ensure valid 3D geometry.
module internal_thread_cutter(thread_len, major_d, pitch, depth) {
    major_r = major_d/2;
    minor_r = max(0.2, major_r - depth);

    turns = thread_len / pitch;
    slices_n = max(ceil(abs(turns) * 60), 120);

    // Thread profile around Z (in r-z plane), then twisted along Z.
    // Keep profile safely away from axis to avoid degeneracy.
    tangential_w = 0.55 * pitch;
    eps = 0.02;

    // Lead-in: fade depth over ~1 pitch
    lead_len = clamp(pitch, 0.6*pitch, 1.5*pitch);

    module one_section(z0, z1, d0, d1) {
        // d0/d1 are depths at start/end of this section
        hull() {
            translate([0, 0, z0])
                linear_extrude(height = eps, twist = 0, slices = 1, convexity = 10)
                    rotate_extrude(angle = 360, convexity = 10)
                        polygon(points=[
                            [minor_r + (depth - d0), -tangential_w/2],
                            [minor_r + (depth - d0) + d0, 0],
                            [minor_r + (depth - d0),  tangential_w/2]
                        ]);

            translate([0, 0, z1])
                linear_extrude(height = eps, twist = 0, slices = 1, convexity = 10)
                    rotate_extrude(angle = 360, convexity = 10)
                        polygon(points=[
                            [minor_r + (depth - d1), -tangential_w/2],
                            [minor_r + (depth - d1) + d1, 0],
                            [minor_r + (depth - d1),  tangential_w/2]
                        ]);
        }
    }

    union() {
        // Main helical cutter (full depth)
        translate([0, 0, -thread_len/2])
            linear_extrude(height = thread_len, twist = -360*turns, slices = slices_n, convexity = 10)
                rotate_extrude(angle = 360, convexity = 10)
                    polygon(points=[
                        [minor_r, -tangential_w/2],
                        [minor_r + depth, 0],
                        [minor_r,  tangential_w/2]
                    ]);

        // Lead-in taper at entry (bottom end): blend from shallow to full depth
        // Positioned using formulas (no arbitrary offsets)
        z_entry0 = -thread_len/2;
        z_entry1 = -thread_len/2 + lead_len;

        one_section(z_entry0, z_entry1, 0.08, depth);
    }
}

// External heat-set ribs/knurl rings (connected, protruding)
module knurl_rings(od, ring_depth, ring_pitch, ring_count, ring_span_len) {
    r_base = od/2;
    ring_h = max(0.2, ring_pitch * 0.55);

    // Center the knurl span within the insert length
    z0 = -ring_span_len/2;
    dz = ring_span_len / max(1, ring_count);

    for (i = [0:ring_count-1]) {
        translate([0, 0, z0 + (i + 0.5)*dz])
            cylinder(h = ring_h, r = r_base + ring_depth, center = true);
    }
}

// ---------- Main part ----------
module threaded_insert() {
    od = outer_diameter_mm;
    len = length_mm;

    // Ensure knurl length doesn't exceed part length minus chamfers
    usable_len = max(0.1, len - top_chamfer_mm - bottom_chamfer_mm);
    knurl_len = min(knurl_length_mm, usable_len);

    // Internal thread sizing
    major_d = screw_diameter_mm + bore_clearance_mm; // internal major diameter (approx)
    pitch = internal_thread_pitch_mm;
    depth = thread_depth_mm;

    // Bore base radius slightly under major so thread cutter creates the groove
    bore_r = max(0.2, (major_d/2) - depth*0.15);

    difference() {
        union() {
            // Main body with chamfers (single connected solid)
            chamfered_cylinder(len, od/2, top_chamfer_mm, bottom_chamfer_mm);

            // Heat-set ribs/knurl rings (connected by union overlap)
            knurl_rings(od, knurl_depth_mm, knurl_pitch_mm, knurl_ring_count, knurl_len);
        }

        // Base bore through
        cylinder(h = len + 2*overlap_mm, r = bore_r, center = true);

        // Internal thread detail (subtract helical cutter)
        internal_thread_cutter(
            thread_len = len + 2*overlap_mm,
            major_d = major_d,
            pitch = pitch,
            depth = depth
        );

        // Top face recess (counterbore-like)
        translate([0, 0, len/2 - top_face_recess_depth_mm/2])
            cylinder(h = top_face_recess_depth_mm + overlap_mm, r = top_face_recess_diameter_mm/2, center = true);
    }
}

threaded_insert();