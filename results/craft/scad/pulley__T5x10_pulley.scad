$fn = 160;

// --- Required target ---
tooth_count = 10;
pitch_diameter_mm = 15.0;

// --- Basic pulley dimensions (simple, no hub/flanges) ---
pulley_width_mm = 10;
bore_diameter_mm = 5;
tolerances_mm = 0.2;

// --- Tooth form (approx. GT2-like rounded tooth; not a rectangular lug) ---
tooth_radial_height_mm = 1.2;     // radial add above pitch circle
tooth_root_relief_mm = 0.6;       // radial cut below pitch circle
tooth_tip_flat_mm = 0.55;         // tangential width at tooth tip
tooth_root_flat_mm = 1.25;        // tangential width at tooth root
tooth_round_r_mm = 0.25;          // rounding radius for tooth corners

overlap_mm = 0.2;

module rounded_polygon(points, r=0.2) {
    // Minkowski rounding of a 2D polygon
    minkowski() {
        polygon(points);
        circle(r=r, $fn=32);
    }
}

module tooth_2d() {
    // Tooth centered on +X axis; X is radial, Y is tangential
    // Root starts at x=0, tip at x=tooth_radial_height_mm
    // Rounded trapezoid approximates timing pulley tooth
    rounded_polygon(
        [
            [0, -tooth_root_flat_mm/2],
            [0,  tooth_root_flat_mm/2],
            [tooth_radial_height_mm,  tooth_tip_flat_mm/2],
            [tooth_radial_height_mm, -tooth_tip_flat_mm/2]
        ],
        r=tooth_round_r_mm
    );
}

module pulley() {
    pitch_r = pitch_diameter_mm/2;
    outer_r = pitch_r + tooth_radial_height_mm;
    root_r  = max(0.1, pitch_r - tooth_root_relief_mm);

    // One connected solid: base cylinder + teeth, then bore removed
    difference() {
        union() {
            // Base body at root diameter (so tooth valleys exist)
            cylinder(r=root_r, h=pulley_width_mm, center=true);

            // Teeth added outward from pitch circle (connected by overlap into base)
            for (i = [0:tooth_count-1]) {
                rotate([0, 0, i*360/tooth_count])
                    translate([pitch_r - overlap_mm, 0, 0])
                        linear_extrude(height=pulley_width_mm, center=true, convexity=10)
                            tooth_2d();
            }
        }

        // Central bore
        cylinder(r=(bore_diameter_mm + tolerances_mm)/2,
                 h=pulley_width_mm + 2*overlap_mm,
                 center=true);
    }
}

pulley();