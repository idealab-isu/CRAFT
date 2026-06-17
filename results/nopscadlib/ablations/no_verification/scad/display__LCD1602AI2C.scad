$fn = 48;

// --- Key dimensions (LCD 1602A module) ---
module_width_mm  = 71.3;
module_height_mm = 24.3;
pcb_thickness_mm = 1.6;

// Display body + bezel
body_width_mm       = 66;
body_height_mm      = 16;
module_thickness_mm = 8;

// Viewing window (cut into bezel)
aperture_width_mm     = 56;
aperture_height_mm    = 12;
aperture_offset_x_mm  = 0;
aperture_offset_y_mm  = 0;
aperture_cut_depth_mm = 2;

// Mounting holes (typical 1602A)
mount_hole_diameter_mm = 3.2;
mount_hole_offset_x_mm = 31.5;
mount_hole_offset_y_mm = 10;

// 1x16 header (key recognizable feature)
header_pins   = 16;
pin_pitch_mm  = 2.54;
pin_d_mm      = 0.8;
pin_h_mm      = 6.0;

header_plastic_w_mm = (header_pins - 1) * pin_pitch_mm + 2.0; // slight end margins
header_plastic_d_mm = 3.0;
header_plastic_h_mm = 2.5;

// Place header along top edge of PCB (Y+), on back side (below PCB)
header_edge_margin_y_mm = 2.0;
header_center_y_mm = module_height_mm/2 - header_edge_margin_y_mm - header_plastic_d_mm/2;

// Small overlap to guarantee manifold connectivity
overlap_mm = 0.6;

// --- Main solid (ONE connected solid) ---
module lcd1602a_solid() {

    // Z references
    pcb_zc   = 0;
    pcb_top  = pcb_zc + pcb_thickness_mm/2;
    pcb_bot  = pcb_zc - pcb_thickness_mm/2;

    // Body sits on top of PCB with overlap
    body_zc  = pcb_top + module_thickness_mm/2 - overlap_mm;
    body_top = body_zc + module_thickness_mm/2;

    // Header plastic sits under PCB with overlap
    header_plastic_zc = pcb_bot - header_plastic_h_mm/2 + overlap_mm;

    // Pins start at bottom of header plastic and extend downward, overlapping into plastic
    pin_top_z = (header_plastic_zc - header_plastic_h_mm/2) + overlap_mm;
    pins_zc   = pin_top_z - pin_h_mm/2;

    // Hole height: just enough to pass through all solids (PCB + body + header + pins)
    z_min = min(pcb_bot, header_plastic_zc - header_plastic_h_mm/2, pins_zc - pin_h_mm/2);
    z_max = max(pcb_top, body_zc + module_thickness_mm/2);
    hole_h = (z_max - z_min) + 2*overlap_mm;

    difference() {
        union() {
            // PCB
            cube([module_width_mm, module_height_mm, pcb_thickness_mm], center=true);

            // Display body / bezel (connected to PCB via overlap)
            translate([0, 0, body_zc])
                cube([body_width_mm, body_height_mm, module_thickness_mm], center=true);

            // 1x16 header plastic (connected to PCB via overlap)
            translate([0, header_center_y_mm, header_plastic_zc])
                cube([header_plastic_w_mm, header_plastic_d_mm, header_plastic_h_mm], center=true);

            // 16 pins (connected to header plastic via overlap)
            for (i = [0:header_pins-1]) {
                x_i = -((header_pins-1) * pin_pitch_mm)/2 + i * pin_pitch_mm;
                translate([x_i, header_center_y_mm, pins_zc])
                    cylinder(d=pin_d_mm, h=pin_h_mm, center=true);
            }
        }

        // Viewing aperture cut into the front/top of the bezel (does not separate solids)
        translate([aperture_offset_x_mm, aperture_offset_y_mm,
                   body_top - aperture_cut_depth_mm/2 + overlap_mm])
            cube([aperture_width_mm, aperture_height_mm, aperture_cut_depth_mm + 2*overlap_mm], center=true);

        // Mounting holes through entire assembly (ensures visible holes in renders)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * mount_hole_offset_x_mm, sy * mount_hole_offset_y_mm, (z_min+z_max)/2])
                cylinder(d=mount_hole_diameter_mm, h=hole_h, center=true);
        }
    }
}

lcd1602a_solid();