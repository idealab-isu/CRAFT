// Toggle switch (tiny) - 0.76mm body diameter, 4.7mm overall height
// One connected solid, all placements derived from dimensions.

$fn = 72;

// Requested key dimensions
body_diameter_mm   = 0.76;   //[0.38:1.52:0.01]
overall_height_mm  = 4.7;    //[2.35:9.4:0.05]

// Proportions (toggle-like: short body + lever)
body_height_mm     = 3.10;   //[1.75:7:0.05]
lever_height_mm    = overall_height_mm - body_height_mm; // exact overall height

// Body shaping (still within body diameter envelope)
top_cap_h_mm       = 0.35;
top_cap_d_mm       = body_diameter_mm * 0.92;

base_flange_h_mm   = 0.30;
base_flange_d_mm   = body_diameter_mm * 0.98;

// Lever
lever_d_mm         = 0.22;   //[0.10:0.40:0.01]
lever_tilt_deg     = 18;     //[0:30:1]
lever_tip_r_mm     = lever_d_mm * 0.85;

// Pins (kept inside body diameter footprint)
pin_count          = 3;
pin_d_mm           = 0.12;
pin_len_mm         = 0.55;
pin_spread_mm      = min(0.22, body_diameter_mm * 0.55);

// Connectivity overlap
ov_mm              = 0.06;   //[0.02:0.2:0.01]

// Derived Z references (bottom of body at z=0, top at z=body_height_mm)
z_body_bot = 0;
z_body_top = body_height_mm;

module toggle_switch() {
    union() {
        // Main body (short cylinder)
        translate([0, 0, (z_body_bot + z_body_top)/2])
            cylinder(d=body_diameter_mm, h=body_height_mm, center=true);

        // Base flange (slightly larger ring at bottom)
        translate([0, 0, z_body_bot + base_flange_h_mm/2 - ov_mm])
            cylinder(d=base_flange_d_mm, h=base_flange_h_mm, center=true);

        // Top cap/bushing
        translate([0, 0, z_body_top - top_cap_h_mm/2 + ov_mm])
            cylinder(d=top_cap_d_mm, h=top_cap_h_mm, center=true);

        // Shoulder/neck to make it look less like a plain rod (still within diameter)
        neck_h = min(0.35, body_height_mm*0.18);
        neck_d = body_diameter_mm * 0.78;
        translate([0, 0, z_body_top - top_cap_h_mm - neck_h/2 + ov_mm])
            cylinder(d=neck_d, h=neck_h, center=true);

        // Toggle lever (tilted), anchored at top cap
        // Place lever so its bottom overlaps into the top cap.
        translate([0, 0, z_body_top + lever_height_mm/2 - ov_mm])
            rotate([lever_tilt_deg, 0, 0])
                cylinder(d=lever_d_mm, h=lever_height_mm, center=true);

        // Lever tip knob, connected to lever end (account for tilt by applying same rotation)
        translate([0, 0, z_body_top + lever_height_mm - lever_tip_r_mm - ov_mm])
            rotate([lever_tilt_deg, 0, 0])
                sphere(r=lever_tip_r_mm);

        // Pins (bottom), connected into body with overlap
        for (i = [0:pin_count-1]) {
            x = (i - (pin_count-1)/2) * pin_spread_mm;
            translate([x, 0, z_body_bot - pin_len_mm/2 + ov_mm])
                cylinder(d=pin_d_mm, h=pin_len_mm, center=true);
        }
    }
}

toggle_switch();