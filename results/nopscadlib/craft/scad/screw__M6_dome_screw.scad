// Dome head screw (single connected solid)
// Target: shank Ø6.0mm, head Ø10.5mm, head height 3.3mm, length under head 10mm

thread_diameter_mm = 6.0;   // shank major diameter
length_mm          = 10.0;  // under-head length
head_diameter_mm   = 10.5;
head_height_mm     = 3.3;

// Cosmetic thread parameters
thread_pitch_mm    = 1.0;
thread_depth_mm    = 0.35;  // radial depth of thread profile
thread_fn          = 96;

overlap_mm         = 0.25;  // small overlap to guarantee watertight union

$fn = 128;

// --- Helpers ---
module dome_head(head_d, head_h) {
    // Spherical cap trimmed to exact head diameter and height.
    r_base = head_d/2;
    R = (r_base*r_base + head_h*head_h) / (2*head_h); // sphere radius for given cap
    zc = head_h - R;                                  // sphere center Z (base plane at z=0)

    intersection() {
        translate([0,0,zc]) sphere(r=R, $fn=192);
        // keep only 0..head_h
        translate([0,0,head_h/2]) cylinder(h=head_h, r=r_base, center=true, $fn=192);
    }
}

module threaded_shank(d, L, pitch, depth) {
    // Core at minor diameter + continuous helical ridge (no center=true to avoid split artifacts)
    r_major = d/2;
    r_minor = r_major - depth;

    union() {
        // Core cylinder: z from -L to 0
        translate([0,0,-L]) cylinder(h=L, r=r_minor, center=false, $fn=thread_fn);

        // Helical ridge: z from -L to 0
        turns = L / pitch;
        translate([0,0,-L])
            linear_extrude(height=L, twist=turns*360, center=false,
                           slices=max(ceil(L*40), 200), convexity=10)
                translate([r_minor + depth*0.60, 0, 0])
                    circle(r=depth*0.60, $fn=36);
    }
}

// --- Main screw (one connected solid) ---
module dome_head_screw() {
    union() {
        // Shank: under-head from z=0 down to z=-length_mm
        threaded_shank(thread_diameter_mm, length_mm, thread_pitch_mm, thread_depth_mm);

        // Head: base at z=0, top at z=head_height_mm
        dome_head(head_diameter_mm, head_height_mm);

        // Under-head transition to ensure robust connection (overlaps both)
        // z from -overlap_mm to +overlap_mm
        translate([0,0,-overlap_mm])
            cylinder(h=2*overlap_mm,
                     r1=head_diameter_mm/2,
                     r2=thread_diameter_mm/2,
                     center=false, $fn=192);
    }
}

dome_head_screw();