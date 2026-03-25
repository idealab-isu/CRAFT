$fn = 200;

// --- Required targets ---
tooth_count = 16;
pitch_diameter_mm = 12.16;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Pulley sizing (printable timing pulley approximation) ---
pulley_width_mm = 10;

// Tooth geometry (approx. GT2-like rounded tooth, not rectangular slots)
tooth_height_mm = 0.75;          // radial height from root to tip
tooth_tip_width_mm = 0.55;       // tangential width at tooth tip
tooth_root_width_mm = 1.25;      // tangential width at tooth root
tooth_round_mm = 0.25;           // rounding radius for tooth corners

bore_diameter_mm = 5;

// Optional features (connected and dimension-driven)
hub_diameter_mm = 14;
hub_length_mm = 6;

flange_diameter_mm = 16;
flange_thickness_mm = 1.5;

connection_overlap_mm = 0.8;

// --- Derived radii ---
// Define pitch circle at pitch_radius_mm.
// Place tooth root slightly inside pitch circle and tooth tip outside.
root_radius_mm = pitch_radius_mm - tooth_height_mm/2;
tip_radius_mm  = pitch_radius_mm + tooth_height_mm/2;

// Ensure the base cylinder reaches at least the tooth root radius
base_radius_mm = max(0.1, root_radius_mm);

// --- Helpers ---
module rounded_trapezoid_2d(w_top, w_bot, h, r) {
    // 2D trapezoid centered at origin, height along +X (radial), width along Y (tangential)
    // Then rounded via offset.
    r2 = min(r, min(w_top, w_bot)/2 - 0.001, h/2 - 0.001);
    offset(r=r2)
        offset(delta=-r2)
            polygon(points=[
                [-h/2, -w_bot/2],
                [-h/2,  w_bot/2],
                [ h/2,  w_top/2],
                [ h/2, -w_top/2]
            ]);
}

module pulley_body() {
    union() {
        // Main body up to tooth root radius
        cylinder(r=base_radius_mm, h=pulley_width_mm, center=true);

        // Hub (below main body), connected with overlap
        if (hub_length_mm > 0)
            translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - connection_overlap_mm)])
                cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (top and bottom), connected with overlap
        if (flange_thickness_mm > 0) {
            translate([0, 0, +(pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm)])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

            translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm)])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        }
    }
}

module teeth() {
    // Teeth protrude outward from root_radius_mm to tip_radius_mm
    tooth_len = tip_radius_mm - root_radius_mm;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([root_radius_mm + tooth_len/2 - connection_overlap_mm, 0, 0])
                linear_extrude(height=pulley_width_mm, center=true)
                    rounded_trapezoid_2d(
                        w_top = tooth_tip_width_mm,
                        w_bot = tooth_root_width_mm,
                        h     = tooth_len + 2*connection_overlap_mm,
                        r     = tooth_round_mm
                    );
    }
}

module bore_hole() {
    total_h = pulley_width_mm
            + (hub_length_mm > 0 ? hub_length_mm : 0)
            + 2*flange_thickness_mm
            + 6*connection_overlap_mm;

    cylinder(r=bore_diameter_mm/2, h=total_h, center=true);
}

// --- Assembly: one connected solid ---
difference() {
    union() {
        pulley_body();
        teeth();
    }
    bore_hole();
}