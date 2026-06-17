$fn = 128;

// Target dimensions (mm)
shaft_d   = 2.2;
head_d    = 4.2;
head_h    = 1.7;
total_len = 10;

// Simple drive feature (Phillips-like cross)
drive_depth = 0.45;
drive_w     = 0.55;

// Tip
tip_len = 0.6;

// Thread approximation (kept subtle so it doesn't distort proportions)
pitch    = 0.6;
thread_h = 0.18;   // radial height
thread_w = 0.28;   // ridge width along Z

// Robust overlap to guarantee connectivity (1–2mm as requested)
overlap = 1.2;

// Small epsilon for boolean robustness
eps = 0.02;

module pan_head(d, h) {
    // Pan head: cylindrical skirt + rounded dome (spherical cap)
    r = d/2;
    skirt_h = h * 0.55;
    dome_h  = h - skirt_h;

    union() {
        // Skirt
        cylinder(d=d, h=skirt_h, center=false);

        // Dome (spherical cap approximation) - MUST be attached to skirt
        // Ensure overlap into skirt by at least `overlap`
        translate([0, 0, skirt_h - overlap])
            intersection() {
                sphere(r = r);
                translate([0, 0, r - dome_h])
                    cylinder(r = r + 0.5, h = dome_h + overlap + eps, center=false);
            }
    }
}

module drive_cross(d_head, depth, w) {
    // Subtractive cross recess, centered on head axis, cut from top face downward
    slot_len = d_head * 0.78;
    union() {
        translate([0, 0, -depth/2])
            cube([slot_len, w, depth + eps], center=true);
        translate([0, 0, -depth/2])
            cube([w, slot_len, depth + eps], center=true);
    }
}

module threaded_shank(d, h, pitch, th, tw) {
    // Base cylinder + helical ridge (approx thread)
    union() {
        cylinder(d=d, h=h, center=false);

        turns = h / pitch;
        linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*50), 120), convexity=10)
            translate([d/2 - th/2, 0, 0])
                square([th, tw], center=true);
    }
}

module tip(d, h) {
    // Slightly pointed tip connected to shank
    cylinder(d1=d, d2=0.2, h=h, center=false);
}

module pan_head_screw() {
    shank_len = total_len - head_h;
    assert(shank_len > 0, "total_len must be greater than head_h");

    // Z layout (all parts overlap by `overlap` to avoid floating/gaps)
    z_tip0   = 0;
    z_tip1   = tip_len;

    z_shank0 = max(0, z_tip1 - overlap);
    z_shank1 = shank_len;

    z_head0  = max(0, z_shank1 - overlap);
    z_head1  = z_head0 + head_h; // should equal total_len (within overlap logic)

    difference() {
        union() {
            // Bottom tip (attached to shank via overlap)
            translate([0, 0, z_tip0])
                tip(shaft_d, tip_len);

            // Shank (attached to tip and head via overlap)
            translate([0, 0, z_shank0])
                threaded_shank(shaft_d, (z_shank1 - z_shank0), pitch, thread_h, thread_w);

            // Head (attached to shank via overlap)
            translate([0, 0, z_head0])
                pan_head(head_d, head_h);
        }

        // Drive recess: cut from the top of the head downward (no gap)
        translate([0, 0, z_head0 + head_h + eps])
            drive_cross(head_d, drive_depth, drive_w);
    }
}

pan_head_screw();