// Pan head screw (single connected solid)
// Dimensions: shank Ø4.2mm, head Ø8.2mm, head height 3.05mm, length 10mm

shank_diameter_mm = 4.2;   // mm
head_diameter_mm  = 8.2;   // mm
head_height_mm    = 3.05;  // mm
length_mm         = 10;    // mm

// Visual/thread parameters (simple representation, still one solid)
thread_ridge_count     = 12;
thread_ridge_height    = 0.20;
thread_ridge_thickness = 0.55;

// Smoothness
$fn = 96;

eps = 0.02;

// Pan head profile controls (kept within head height)
head_top_flat_h = 0.35;                 // small flat at top
head_fillet_r   = min(1.2, head_height_mm - head_top_flat_h - 0.05);

module pan_head_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Place underside of head at z=0, shank extends to z=-length_mm
    union() {
        // Shank core
        translate([0,0,-length_mm/2])
            cylinder(r=shank_r, h=length_mm, center=true);

        // Simple thread ridges (unioned, no floating)
        for (i = [0:thread_ridge_count-1]) {
            z0 = -length_mm + (i + 0.5) * (length_mm/thread_ridge_count);
            translate([0,0,z0])
                cylinder(r=shank_r + thread_ridge_height,
                         h=thread_ridge_thickness,
                         center=true);
        }

        // Pan head (smooth revolve)
        // Profile points in XZ plane, revolved around Z.
        rotate_extrude()
            polygon(points=[
                [0, 0],                                  // axis at underside
                [head_r, 0],                              // outer edge underside
                [head_r, head_height_mm - head_fillet_r - head_top_flat_h],
                [head_r - head_fillet_r, head_height_mm - head_top_flat_h],
                [head_r - head_fillet_r, head_height_mm], // start of top flat
                [0, head_height_mm]                       // axis at top
            ]);
    }
}

pan_head_screw();