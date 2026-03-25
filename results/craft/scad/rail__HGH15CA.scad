// Miniature linear guide rail (15mm wide, 15mm tall, 100mm long)
// One connected solid with top raceway grooves + mounting holes

$fn = 96;

// Parameters
width_mm  = 15.0;
height_mm = 15.0;
length_mm = 100.0;

module linear_guide_rail(w=width_mm, h=height_mm, L=length_mm) {

    // Small overlap to avoid coincident faces
    eps = 0.05;

    // Feature proportions (kept parametric and clamped to remain valid)
    top_flat_h   = max(1.2, h*0.18);                 // top land thickness
    side_wall    = max(1.2, w*0.12);                 // side wall thickness
    groove_depth = min(h*0.28, h - top_flat_h - 1.0);
    groove_w     = min(w*0.22, (w - 2*side_wall) * 0.45);

    // Mounting holes (through from top)
    hole_d       = min(4.2, w*0.28);
    cbore_d      = min(7.5, w*0.50);
    cbore_h      = min(3.0, h*0.22);

    // Hole pattern along length
    end_margin   = max(10, L*0.10);
    pitch_nom    = 25;
    usable       = max(0, L - 2*end_margin);
    n_holes      = max(2, floor(usable/pitch_nom) + 1);
    actual_pitch = (n_holes > 1) ? (usable/(n_holes-1)) : 0;

    // Ensure grooves don't fully remove the top (avoid accidental "empty" results)
    groove_depth_safe = min(groove_depth, h - top_flat_h - 0.6);

    // Ensure counterbore doesn't exceed top thickness
    cbore_h_safe = min(cbore_h, top_flat_h - 0.3);

    // If top_flat_h is too small, disable counterbore safely
    do_cbore = (cbore_h_safe > 0.2);

    difference() {
        // Main rail body (X=width, Y=length, Z=height)
        cube([w, L, h], center=true);

        // Top raceway grooves (two longitudinal undercuts)
        for (sx = [-1, 1]) {
            translate([
                sx*(w/2 - side_wall - groove_w/2),
                0,
                h/2 - top_flat_h - groove_depth_safe/2 + eps
            ])
                cube([groove_w, L + 2*eps, groove_depth_safe + 2*eps], center=true);
        }

        // Mounting holes: counterbore + through hole
        for (i = [0 : n_holes-1]) {
            y = -L/2 + end_margin + i*actual_pitch;

            if (do_cbore) {
                // Counterbore from top
                translate([0, y, h/2 - cbore_h_safe/2 + eps])
                    cylinder(d=cbore_d, h=cbore_h_safe + 2*eps, center=true);
            }

            // Through hole
            translate([0, y, 0])
                cylinder(d=hole_d, h=h + 2*eps, center=true);
        }
    }
}

// Render
linear_guide_rail();