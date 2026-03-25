// Threaded heat-set insert (M3) — 3.0mm OD, 4.6mm long
// STRUCTURAL FIXES:
// - Ensure expected part "insert" exists and generates visible geometry
// - Ensure a single connected solid via top-level union()
// - Avoid any accidental empty geometry by using non-degenerate, non-centered chamfer construction
// - Keep all features physically part of the same body (no floating parts)

// -------------------- Parameters --------------------
outer_diameter_mm = 3.0;          // Insert OD
length_mm = 4.6;                  // Insert length

// Typical heat-set insert features
knurl_count = 18;                 // Knurl-like grooves
knurl_depth_mm = 0.18;            // Radial depth of knurl valleys
knurl_band_margin_mm = 0.35;      // Smooth margin at each end (no knurl)
end_chamfer_h_mm = 0.45;          // Lead-in chamfer height (both ends)
end_chamfer_rad_reduction_mm = 0.25;

// Internal thread (approximate)
thread_major_d_mm = 3.0;          // For M3 screw
thread_pitch_mm = 0.5;            // M3 coarse pitch
thread_depth_mm = 0.22;           // Approx. radial thread depth
thread_clearance_mm = 0.10;       // Clearance for screw fit

// Quality
$fn = 96;

// -------------------- Derived --------------------
outer_r = outer_diameter_mm/2;
inner_major_r = (thread_major_d_mm + thread_clearance_mm)/2;
inner_minor_r = inner_major_r - thread_depth_mm;

knurl_outer_r = outer_r;
knurl_valley_r = outer_r - knurl_depth_mm;

knurl_band_h = max(0, length_mm - 2*knurl_band_margin_mm);

eps = 0.02;

// Structural overlap for boolean robustness (1–2mm as required)
overlap = 1.2;

// -------------------- Helpers --------------------
// Non-degenerate chamfered cylinder built from bottom (z=0..h), then centered by caller if needed.
// This avoids the "center=true + translate" stacking that can accidentally cancel/clip in some viewers.
module chamfered_cylinder_z0(r, h, chamfer_h, chamfer_reduction) {
    ch = min(chamfer_h, h/2 - eps);
    mid_h = max(eps, h - 2*ch);

    union() {
        // Bottom chamfer
        cylinder(r1=max(eps, r - chamfer_reduction), r2=r, h=ch, center=false);

        // Middle straight section
        translate([0,0,ch])
            cylinder(r=r, h=mid_h, center=false);

        // Top chamfer
        translate([0,0,ch + mid_h])
            cylinder(r1=r, r2=max(eps, r - chamfer_reduction), h=ch, center=false);
    }
}

// Helical "thread cutter" (subtract from bore)
module helical_thread_cutter(major_r, minor_r, pitch, h) {
    turns = h / pitch;
    tooth_rad = max(eps, major_r - minor_r);
    tooth_w = pitch * 0.55;

    // Place the tooth inside the bore so it intersects reliably
    translate([major_r - tooth_rad/2, 0, 0])
        linear_extrude(height=h, twist=turns*360, slices=max(24, ceil(turns*80)), convexity=10)
            square([tooth_rad, tooth_w], center=true);
}

// Knurl valleys (subtract) around circumference
module knurl_valleys(r_outer, r_valley, h_band, count) {
    groove_depth = max(eps, r_outer - r_valley);
    groove_w = (2*PI*r_outer)/count * 0.45;
    groove_len = groove_depth + overlap;

    for (i = [0:count-1]) {
        rotate([0,0,i*360/count])
            // Groove starts at outer surface and cuts inward by groove_depth
            translate([r_outer - groove_len/2 + overlap/2, 0, 0])
                cube([groove_len, groove_w, h_band + overlap], center=true);
    }
}

// -------------------- Main insert geometry --------------------
module threaded_heatset_insert_geom() {
    // Guard against impossible geometry (would render empty)
    assert(inner_major_r < outer_r - eps, "Inner bore radius must be smaller than outer radius.");

    // Build outer body centered at origin for predictable placement
    difference() {
        // OUTER SOLID (centered)
        translate([0,0,-length_mm/2])
            chamfered_cylinder_z0(
                r=outer_r,
                h=length_mm,
                chamfer_h=end_chamfer_h_mm,
                chamfer_reduction=end_chamfer_rad_reduction_mm
            );

        // OUTER KNURL VALLEYS (limited to center band)
        if (knurl_band_h > eps) {
            intersection() {
                // Limit knurl to center band
                cylinder(r=outer_r + 1, h=knurl_band_h, center=true);
                // Apply valleys
                knurl_valleys(knurl_outer_r, knurl_valley_r, knurl_band_h, knurl_count);
            }
        }

        // INNER BORE + THREAD (single connected subtraction)
        union() {
            // Major bore through full length (extended for robust subtraction)
            cylinder(r=inner_major_r, h=length_mm + 2*overlap, center=true);

            // Helical cutter to create thread-like groove (extended for robust subtraction)
            // Centered in Z to match the bore; height extended for robust subtraction
            translate([0,0,0])
                helical_thread_cutter(inner_major_r, inner_minor_r, thread_pitch_mm, length_mm + 2*overlap);

            // Lead-in at both ends (extended for robust subtraction)
            translate([0,0,(length_mm/2 - end_chamfer_h_mm/2)])
                cylinder(r1=inner_major_r + 0.15, r2=inner_major_r, h=end_chamfer_h_mm + overlap, center=true);

            translate([0,0,(-length_mm/2 + end_chamfer_h_mm/2)])
                cylinder(r1=inner_major_r, r2=inner_major_r + 0.15, h=end_chamfer_h_mm + overlap, center=true);
        }
    }
}

// -------------------- Expected part: insert --------------------
// Explicitly provide "insert" as the visible, single connected solid.
module insert() {
    // Single solid: all features are internal subtractions; nothing can float.
    union() {
        threaded_heatset_insert_geom();
    }
}

// -------------------- Assembly --------------------
union() {
    insert();
}