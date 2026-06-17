// Pan head screw (single connected solid)
// Spec: 3.0mm shank dia, 5.5mm head dia, head height 2.0mm, 10mm long (under-head length)

$fn = 128;

// Dimensions (mm)
shaft_diameter = 3.0;
shaft_length   = 10.0;   // under-head length
head_diameter  = 5.5;
head_height    = 2.0;

// Thread (visual, simplified)
thread_pitch   = 0.6;    // mm
thread_depth   = 0.18;   // radial depth (mm)
thread_start   = 0.6;    // unthreaded length under head (mm)
tip_length     = 0.8;    // conical tip length (mm)

// Drive recess (Phillips-like cross, simplified)
recess_depth   = 0.9;    // mm
recess_w       = 0.9;    // slot width (mm)
recess_len     = 3.2;    // slot length (mm)

// Small overlaps for manifold unions/differences
eps = 0.02;

module pan_head_profile(r_head, hh) {
    // Rounded pan head via rotate_extrude of a 2D profile (no frustum)
    // z=0 at bearing surface, z=hh at top
    fillet = min(0.55, hh*0.45);          // top rounding amount
    top_r  = max(r_head - 0.35, r_head*0.85);

    rotate_extrude(convexity=10)
        polygon(points=[
            [0,      0],
            [r_head, 0],
            [r_head, hh - fillet],
            [top_r,  hh],
            [0,      hh]
        ]);
}

module phillips_recess(depth, w, len) {
    // Simple cross recess: two perpendicular rounded slots
    // Positioned with top at z=0, cuts downward (negative z)
    union() {
        translate([0,0,-depth/2])
            cube([len, w, depth + eps], center=true);
        translate([0,0,-depth/2])
            cube([w, len, depth + eps], center=true);
    }
}

module threaded_shank(d, L, pitch, depth, tipL, start_unthread) {
    r = d/2;
    r_root = r - depth;

    union() {
        // Root cylinder (minor diameter) for full length
        cylinder(h=L, r=r_root);

        // Helical thread ridge (triangular-ish via circle swept along helix)
        // Starts after a short unthreaded section under the head
        thread_len = max(L - start_unthread - tipL, 0);
        if (thread_len > 0) {
            translate([0,0,start_unthread])
                linear_extrude(height=thread_len, twist=360*thread_len/pitch, slices=max(ceil(thread_len*24), 60))
                    translate([r_root, 0, 0])
                        circle(r=depth, $fn=24);
        }

        // Unthreaded section under head at major diameter (for clean transition)
        if (start_unthread > 0)
            cylinder(h=start_unthread + eps, r=r);

        // Conical tip at end (major to point)
        translate([0,0,L - tipL])
            cylinder(h=tipL, r1=r, r2=0.15);
    }
}

module pan_head_screw(d=3.0, shank_L=10.0, hd=5.5, hh=2.0) {
    r_shaft = d/2;
    r_head  = hd/2;

    union() {
        // Shank with threads (under-head length = shank_L)
        threaded_shank(d, shank_L, thread_pitch, thread_depth, tip_length, thread_start);

        // Head with drive recess (head sits on top of shank)
        translate([0,0,shank_L - eps])
            difference() {
                pan_head_profile(r_head, hh);

                // Recess cut from top surface downward
                translate([0,0,hh + eps])
                    phillips_recess(recess_depth, recess_w, recess_len);
            }
    }
}

pan_head_screw(shaft_diameter, shaft_length, head_diameter, head_height);