// Toggle switch (stylized) — 6.86mm body diameter, 12.7mm tall
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm   = 12.7; //[6.35:25.4:0.01]

include_lever = 1; //[0:1:1]
include_terminals = 1; //[0:1:1]

overlap_mm = 0.4; //[0.1:1.5:0.05]

// Body detailing
top_bezel_h_mm = 1.2; //[0.5:3:0.05]
top_bezel_d_scale = 1.10; //[1.0:1.3:0.01]
bottom_base_h_mm = 1.0; //[0.5:3:0.05]
bottom_base_d_scale = 1.06; //[1.0:1.3:0.01]

// Lever
toggle_lever_diameter_mm = 2.2; //[1.2:5:0.1]
toggle_lever_height_mm   = 6.0; //[3:12:0.1]
lever_tip_d_scale = 0.85; //[0.6:1.0:0.01]
lever_tilt_deg = 18; //[0:35:1]

// Terminals (simple 3-pin)
terminal_count = 3; //[2:6:1]
terminal_w_mm = 1.0; //[0.6:2.0:0.05]
terminal_t_mm = 0.6; //[0.4:1.5:0.05]
terminal_h_mm = 3.2; //[1.5:8:0.1]
terminal_spacing_mm = 2.0; //[1.2:3.5:0.05]
terminal_inset_mm = 0.6; //[0.2:2.0:0.05]

$fn = 96;

module toggle_switch() {
    body_r = body_diameter_mm/2;

    // Keep overall height exactly body_height_mm:
    // core + bezel + base = body_height_mm
    core_h = max(0.01, body_height_mm - top_bezel_h_mm - bottom_base_h_mm);

    // Z references (centered model)
    z_core_center   = 0;
    z_core_top      = z_core_center + core_h/2;
    z_core_bottom   = z_core_center - core_h/2;

    // Bezel/base centers (ensure overlap into core so it's one connected solid)
    z_top_bezel_center    = z_core_top + top_bezel_h_mm/2 - overlap_mm;
    z_bottom_base_center  = z_core_bottom - bottom_base_h_mm/2 + overlap_mm;

    // True outer surfaces (used for attachments)
    z_top_surface    = z_core_top + top_bezel_h_mm;        // top of bezel (no overlap)
    z_bottom_surface = z_core_bottom - bottom_base_h_mm;   // bottom of base (no overlap)

    // Lever placement: base of lever intersects bezel by overlap_mm
    z_lever_center = (z_top_surface - overlap_mm) + toggle_lever_height_mm/2;

    // Terminals placement: top of terminals intersects base by overlap_mm
    z_term_center = (z_bottom_surface + overlap_mm) - terminal_h_mm/2;

    union() {
        // Core body
        cylinder(r=body_r, h=core_h, center=true);

        // Top bezel
        translate([0,0,z_top_bezel_center])
            cylinder(r=body_r*top_bezel_d_scale, h=top_bezel_h_mm, center=true);

        // Bottom base
        translate([0,0,z_bottom_base_center])
            cylinder(r=body_r*bottom_base_d_scale, h=bottom_base_h_mm, center=true);

        // Lever (tilted about X, but positioned so it still intersects the bezel)
        if (include_lever) {
            translate([0,0,z_lever_center])
                rotate([lever_tilt_deg, 0, 0])
                    union() {
                        // Main shaft
                        cylinder(r=toggle_lever_diameter_mm/2, h=toggle_lever_height_mm, center=true, $fn=64);

                        // Tip
                        tip_h = toggle_lever_height_mm*0.22;
                        translate([0,0, toggle_lever_height_mm/2 - tip_h/2 + overlap_mm])
                            cylinder(r=(toggle_lever_diameter_mm*lever_tip_d_scale)/2,
                                     h=tip_h, center=true, $fn=64);

                        // Collar at base (also helps guarantee connection)
                        collar_h = 0.6;
                        translate([0,0, -toggle_lever_height_mm/2 + collar_h/2 - overlap_mm])
                            cylinder(r=(toggle_lever_diameter_mm*1.25)/2, h=collar_h, center=true, $fn=64);
                    }
        }

        // Terminals (rectangular pins) — connected to bottom base
        if (include_terminals) {
            for (i = [0:terminal_count-1]) {
                x = (i - (terminal_count-1)/2) * terminal_spacing_mm;

                // Clamp within body envelope (derived from dimensions)
                x_limit = max(0, body_r - terminal_w_mm/2 - terminal_inset_mm);
                x_clamped = (abs(x) > x_limit) ? sign(x) * x_limit : x;

                translate([x_clamped, 0, z_term_center])
                    cube([terminal_w_mm, terminal_t_mm, terminal_h_mm], center=true);
            }
        }
    }
}

toggle_switch();