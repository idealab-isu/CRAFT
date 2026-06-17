$fn = 128;

// Parameters (mm)
shaft_d   = 6.0;
head_d    = 12.0;
head_h    = 4.75;
shaft_len = 10.0;

shaft_r = shaft_d/2;
head_r  = head_d/2;

// Thread (visual approximation; keeps major diameter = shaft_d)
thread_pitch = 1.0;                 // mm per turn (visual)
thread_depth = 0.35;                // radial depth (visual)
thread_len   = shaft_len;           // threaded length
minor_r      = shaft_r - thread_depth;

// Drive feature (Phillips-like cross recess)
drive_depth  = head_h * 0.55;        // recess depth
drive_w      = head_d * 0.18;        // slot width
drive_l      = head_d * 0.70;        // slot length
drive_taper  = 0.85;                // top width factor (tapered recess)

// Small overlaps to guarantee connectivity / clean booleans
eps = 0.05;

module pan_head_profile_2d() {
    // 2D profile in X (radius) vs Y (height), revolved around Z
    // Head spans z = 0 .. head_h, max radius = head_r
    top_flat_r = head_r * 0.78;

    polygon(points=[
        [0, 0],
        [head_r, 0],
        [head_r, head_h*0.30],
        [head_r*0.94, head_h*0.65],
        [top_flat_r, head_h],
        [0, head_h]
    ]);
}

module helical_thread(major_r, minor_r, pitch, len) {
    // Creates a helical ridge by twisting a small triangular profile
    // around the shaft. Unioned with a minor-radius core to keep it solid.
    turns = len / pitch;

    union() {
        // Core (minor diameter)
        cylinder(h=len, r=minor_r);

        // Helical ridge (approx)
        linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
            translate([minor_r, 0, 0])
                polygon(points=[
                    [0, -pitch*0.18],
                    [major_r - minor_r, 0],
                    [0,  pitch*0.18]
                ]);
    }
}

module phillips_recess() {
    // Tapered cross recess cut from the head top
    // Positioned so top of recess starts at z=head_h and cuts downward.
    translate([0, 0, head_h - drive_depth])
    union() {
        // Slot along X
        linear_extrude(height=drive_depth + eps, scale=drive_taper, convexity=10)
            square([drive_l, drive_w], center=true);

        // Slot along Y
        linear_extrude(height=drive_depth + eps, scale=drive_taper, convexity=10)
            square([drive_w, drive_l], center=true);
    }
}

module pan_head_screw() {
    difference() {
        union() {
            // Threaded shaft: from z = -shaft_len .. 0 (meets head at z=0)
            translate([0, 0, -shaft_len])
                helical_thread(major_r=shaft_r, minor_r=minor_r, pitch=thread_pitch, len=thread_len);

            // Head: from z = 0 .. head_h
            rotate_extrude(convexity=10)
                pan_head_profile_2d();

            // Small blend ring to ensure robust connection at z=0
            translate([0, 0, -eps])
                cylinder(h=2*eps, r=shaft_r*1.02);
        }

        // Drive recess cut into head from the top
        phillips_recess();
    }
}

pan_head_screw();