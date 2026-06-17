// Pan head screw (single connected solid)
// Requested: 5.0mm shank diameter, 10.0mm head diameter, 3.95mm head height, 10.0mm length under head

$fn = 96;

// Parameters (mm)
shaft_diameter_mm      = 5.0;
length_under_head_mm   = 10.0;
head_diameter_mm       = 10.0;
head_height_mm         = 3.95;

// Simple pan-head profile controls
head_top_flat_factor   = 0.55;   // fraction of head radius that is flat on top
head_crown_height_frac = 0.70;   // where the crown starts (as fraction of head height)

// Small overlap to ensure watertight union
overlap_mm = 0.05;

// Optional shallow drive recess (kept subtle; still one solid via difference)
drive_recess_diameter_factor = 0.55; // fraction of head diameter
drive_recess_depth_factor    = 0.35; // fraction of head height

module pan_head_screw() {
    shank_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Place underside of head at z=0, shank extends to negative z
    difference() {
        union() {
            // Shank (length under head)
            translate([0,0,-length_under_head_mm/2])
                cylinder(h=length_under_head_mm + overlap_mm, r=shank_r, center=true);

            // Pan head (underside at z=0, top at z=head_height_mm)
            // Built as a revolve of a 2D profile in the X-Z plane.
            rotate_extrude(convexity=10)
                polygon(points=[
                    // Start at axis on underside
                    [0, 0],
                    // Underside outer edge
                    [head_r, 0],
                    // Vertical-ish side up a bit
                    [head_r, head_height_mm*0.25],
                    // Crown transition
                    [head_r*0.92, head_height_mm*head_crown_height_frac],
                    // Top flat outer edge
                    [head_r*head_top_flat_factor, head_height_mm],
                    // Back to axis at top
                    [0, head_height_mm]
                ]);
        }

        // Shallow drive recess (subtracted), centered on head top
        recess_r = (head_diameter_mm * drive_recess_diameter_factor)/2;
        recess_h = head_height_mm * drive_recess_depth_factor;

        translate([0,0, head_height_mm - recess_h/2 + overlap_mm])
            cylinder(h=recess_h + 2*overlap_mm, r=recess_r, center=true);
    }
}

pan_head_screw();