$fn = 200;

// --- Required specs ---
tooth_count = 20;
pitch_diameter_mm = 12.22;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Pulley proportions ---
pulley_width_mm = 10;
bore_diameter_mm = 5;

// Tooth profile (GT2-like rounded tooth approximation)
// (Not a perfect GT2 standard profile, but rounded/curved instead of rectangular blocks)
tooth_radial_height_mm = 1.25;     // addendum above pitch radius
tooth_root_clearance_mm = 0.70;    // dedendum below pitch radius
tooth_tip_flat_mm = 0.55;          // small flat at tooth tip (tangential)
tooth_root_flat_mm = 1.05;         // wider at root (tangential)
tooth_round_r_mm = 0.35;           // rounding radius for tooth corners

// Connectivity / robustness
tooth_overlap_mm = 0.35;           // tooth overlaps into body to guarantee union
connect_overlap_mm = 0.25;         // bore cut slightly longer than width

// Derived radii
root_radius_mm  = pitch_radius_mm - tooth_root_clearance_mm;
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Tooth pitch (arc length at pitch radius)
pitch_circumference_mm = PI * pitch_diameter_mm;
tooth_pitch_mm = pitch_circumference_mm / tooth_count;

// Clamp widths so they remain physically plausible vs pitch
tooth_tip_w_mm  = min(tooth_tip_flat_mm,  0.85 * tooth_pitch_mm);
tooth_root_w_mm = min(tooth_root_flat_mm, 0.95 * tooth_pitch_mm);

// 2D rounded trapezoid used as tooth cross-section (in XY), then extruded in Z
module rounded_trapezoid_2d(h, w_bottom, w_top, r) {
    // Ensure rounding radius fits
    r2 = min(r, min(w_bottom, w_top)/2 - 0.001, h/2 - 0.001);

    // Trapezoid points (centered on X, base at y=0, top at y=h)
    pts = [
        [-w_bottom/2, 0],
        [ w_bottom/2, 0],
        [ w_top/2,    h],
        [-w_top/2,    h]
    ];

    // Offset out then in to create rounded corners while keeping overall size
    offset(r = r2) offset(delta = -r2) polygon(points = pts);
}

module pulley_teeth() {
    // Tooth radial thickness (from root to tip)
    tooth_h = (outer_radius_mm - root_radius_mm) + tooth_overlap_mm;

    // Place tooth so its inner edge penetrates the root cylinder by tooth_overlap_mm
    // Inner face radius = root_radius_mm - tooth_overlap_mm
    // Tooth 2D is built with y from 0..tooth_h, so translate by inner_face_radius in +X
    inner_face_r = root_radius_mm - tooth_overlap_mm;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360/tooth_count])
            translate([inner_face_r, 0, 0])
                rotate([0, 0, 90])  // make trapezoid height point radially outward
                    linear_extrude(height = pulley_width_mm, center = true, convexity = 10)
                        rounded_trapezoid_2d(
                            h = tooth_h,
                            w_bottom = tooth_root_w_mm,
                            w_top = tooth_tip_w_mm,
                            r = tooth_round_r_mm
                        );
    }
}

module timing_pulley_20T_PD12_22() {
    difference() {
        union() {
            // Root body cylinder (defines dedendum/root diameter)
            cylinder(r = root_radius_mm, h = pulley_width_mm, center = true);

            // Rounded teeth (connected via overlap into root body)
            pulley_teeth();
        }

        // Bore
        cylinder(r = bore_diameter_mm/2, h = pulley_width_mm + 2*connect_overlap_mm, center = true);
    }
}

timing_pulley_20T_PD12_22();