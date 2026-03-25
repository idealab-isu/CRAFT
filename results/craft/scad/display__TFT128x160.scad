$fn = 64;

// =====================
// Parameters (mm)
// =====================
overall_width_mm  = 46.0;   // X
overall_height_mm = 34.0;   // Y
overall_thickness_mm = 6.0; // Z total envelope

pcb_thickness_mm = 1.6;
front_bezel_thickness_mm = 2.0;
bezel_border_mm = 3.0;

screen_aperture_width_mm  = 34.0;
screen_aperture_height_mm = 26.0;
screen_aperture_offset_x_mm = 0.0;
screen_aperture_offset_y_mm = 0.0;

screen_window_thickness_mm = 0.8;
display_layer_thickness_mm = 1.2;

mounting_hole_diameter_mm = 2.5;
mounting_hole_edge_margin_mm = 3.0;

overlap_mm = 0.6;

// Simple connector/FPC feature (approx)
fpc_w_mm = 16.0;
fpc_h_mm = 6.0;
fpc_t_mm = 1.2;
fpc_edge_margin_mm = 2.0;

// =====================
// Derived / sanity
// =====================
module_thickness_mm = pcb_thickness_mm + front_bezel_thickness_mm; // physical stack we model
z0 = -module_thickness_mm/2; // bottom of PCB
pcb_zc   = z0 + pcb_thickness_mm/2;
bezel_zc = z0 + pcb_thickness_mm + front_bezel_thickness_mm/2;

screen_window_zc = z0 + pcb_thickness_mm + front_bezel_thickness_mm - screen_window_thickness_mm/2;
display_layer_zc = z0 + pcb_thickness_mm + front_bezel_thickness_mm - screen_window_thickness_mm - display_layer_thickness_mm/2;

// Keep within requested overall thickness envelope (6mm) by centering the modeled stack
z_shift = 0; // already centered by z0 definition

// =====================
// Geometry helpers
// =====================
module rounded_rect_prism(size=[10,10,1], r=1, center=true) {
    // Minkowski rounded rectangle prism
    // size is outer size; r is corner radius
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx,sy)/2 - 0.01);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        minkowski() {
            cube([sx-2*rr, sy-2*rr, sz], center=true);
            cylinder(r=rr, h=0.01, center=true);
        }
}

// =====================
// TFT Module (single connected solid)
// =====================
module tft_module() {
    union() {
        // --- PCB with mounting holes (holes are subtracted but solid remains connected)
        difference() {
            color([0.0, 0.45, 0.2])
                translate([0,0,pcb_zc + z_shift])
                    cube([overall_width_mm, overall_height_mm, pcb_thickness_mm], center=true);

            for (x = [-1, 1], y = [-1, 1]) {
                translate([
                    x*(overall_width_mm/2 - mounting_hole_edge_margin_mm),
                    y*(overall_height_mm/2 - mounting_hole_edge_margin_mm),
                    pcb_zc + z_shift
                ])
                    cylinder(r=mounting_hole_diameter_mm/2, h=pcb_thickness_mm + 2*overlap_mm, center=true);
            }
        }

        // --- Bezel frame (with screen aperture cutout)
        difference() {
            color([0.05, 0.05, 0.05])
                translate([0,0,bezel_zc + z_shift])
                    rounded_rect_prism([overall_width_mm, overall_height_mm, front_bezel_thickness_mm], r=1.2, center=true);

            // Screen aperture cut
            translate([screen_aperture_offset_x_mm, screen_aperture_offset_y_mm, bezel_zc + z_shift])
                cube([screen_aperture_width_mm, screen_aperture_height_mm, front_bezel_thickness_mm + 2*overlap_mm], center=true);
        }

        // --- Screen window (glass) - slightly recessed into bezel, overlaps for watertight union
        color([0.15, 0.15, 0.18, 0.9])
            translate([screen_aperture_offset_x_mm, screen_aperture_offset_y_mm, screen_window_zc + z_shift - overlap_mm/2])
                cube([screen_aperture_width_mm, screen_aperture_height_mm, screen_window_thickness_mm + overlap_mm], center=true);

        // --- Display layer behind glass (dark)
        color([0.02, 0.02, 0.02])
            translate([screen_aperture_offset_x_mm, screen_aperture_offset_y_mm, display_layer_zc + z_shift - overlap_mm/2])
                cube([screen_aperture_width_mm - 1.0, screen_aperture_height_mm - 1.0, display_layer_thickness_mm + overlap_mm], center=true);

        // --- Simple FPC/connector feature on back side (connected to PCB)
        // Place at bottom edge (negative Y) on PCB top surface, protruding slightly upward.
        fpc_zc = (z0 + pcb_thickness_mm) + fpc_t_mm/2 - overlap_mm; // overlaps into PCB
        fpc_yc = -overall_height_mm/2 + fpc_h_mm/2 + fpc_edge_margin_mm;
        color([0.85, 0.75, 0.2])
            translate([0, fpc_yc, fpc_zc + z_shift])
                cube([fpc_w_mm, fpc_h_mm, fpc_t_mm], center=true);

        // --- Small stiffener/IC bump on back (connected)
        ic_w = 10; ic_h = 10; ic_t = 1.0;
        ic_zc = z0 + ic_t/2 - overlap_mm; // overlaps into PCB bottom
        color([0.1, 0.1, 0.1])
            translate([overall_width_mm/2 - ic_w/2 - 6, 0, ic_zc + z_shift])
                cube([ic_w, ic_h, ic_t], center=true);
    }
}

// Render
tft_module();