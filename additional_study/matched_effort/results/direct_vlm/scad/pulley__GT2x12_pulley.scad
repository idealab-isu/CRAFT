$fn = 180;

// --- Target: timing pulley, 12 teeth, pitch diameter 7.15mm ---
teeth = 12;
pitch_diameter = 7.15;                 // mm
pitch_radius   = pitch_diameter/2;

pulley_height  = 10;                   // mm
bore_diameter  = 5;                    // mm

// Tooth form (rounded timing-pulley-like lobe)
tooth_radial_height = 1.15;            // mm above root cylinder
tooth_tip_flat      = 0.55;            // mm tangential flat at tooth tip
tooth_root_flat     = 1.55;            // mm tangential width at tooth root
tooth_round_r       = 0.45;            // mm rounding radius for tooth corners

// Place pitch circle near the middle of the tooth height
pitch_at_fraction_of_tooth = 0.55;     // pitch radius = root_radius + fraction*tooth_height
root_radius  = max(0.2, pitch_radius - pitch_at_fraction_of_tooth*tooth_radial_height);
outer_radius = root_radius + tooth_radial_height;

// Ensure teeth don't overlap: keep tooth tangential width <= circular pitch
circular_pitch = PI * pitch_diameter / teeth;
max_root_flat  = 0.92 * circular_pitch;
tooth_root_flat_eff = min(tooth_root_flat, max_root_flat);
tooth_tip_flat_eff  = min(tooth_tip_flat, tooth_root_flat_eff * 0.75);

// Small overlap so teeth are guaranteed connected to the root cylinder
tooth_overlap = 0.25;                  // mm (tooth intrudes into root cylinder)

module tooth2d() {
    // Tooth centered on X, radial direction is +Y.
    y0 = -tooth_overlap;
    y1 = tooth_radial_height;

    pts = [
        [-tooth_root_flat_eff/2, y0],
        [ tooth_root_flat_eff/2, y0],
        [ tooth_tip_flat_eff/2,  y1],
        [-tooth_tip_flat_eff/2,  y1]
    ];

    offset(r=tooth_round_r)
        offset(delta=-tooth_round_r)
            polygon(points=pts);
}

module pulley() {
    difference() {
        union() {
            // Root cylinder (tooth valleys)
            cylinder(h=pulley_height, r=root_radius, center=false);

            // Teeth: translate in X so tooth's radial centerline sits at root_radius
            // (tooth2d uses +Y as radial; rotate 90deg so +Y aligns with +X)
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    rotate([0,0, 90])
                        translate([root_radius, 0, 0])
                            linear_extrude(height=pulley_height, center=false, convexity=10)
                                tooth2d();
            }
        }

        // Bore (through)
        translate([0,0,-0.5])
            cylinder(h=pulley_height+1, r=bore_diameter/2, center=false);
    }
}

pulley();