$fn = 64;

// BigTreeTech TFT35 v3.0 (approx envelope)
width_mm  = 84.5;
height_mm = 54.5;

// Thickness stack (front -> back)
bezel_thickness_mm = 2.2;
pcb_thickness_mm   = 1.6;
standoff_mm        = 2.2;   // gap between bezel and PCB (posts connect them)
total_thickness_mm = bezel_thickness_mm + standoff_mm + pcb_thickness_mm;

// Corners + holes
corner_radius_mm        = 3;
mount_hole_diameter_mm  = 3.2;
mount_edge_offset_mm    = 3.5; // distance from each outer edge to hole center

// Screen opening + recess
aperture_w_mm       = 70;
aperture_h_mm       = 45;
aperture_depth_mm   = 1.6;  // recess into bezel (not through)

// Screen glass (visible area)
glass_w_mm = 66;
glass_h_mm = 40;
glass_t_mm = 0.8;

// Backside connectors/components (more recognizable)
header_w_mm = 34;   // long header
header_h_mm = 7;
header_t_mm = 8;

sd_w_mm = 18;
sd_h_mm = 16;
sd_t_mm = 2.6;

usb_w_mm = 12;
usb_h_mm = 9;
usb_t_mm = 4.5;

chip_w_mm = 14;
chip_h_mm = 14;
chip_t_mm = 1.8;

reg_w_mm = 10;
reg_h_mm = 8;
reg_t_mm = 2.2;

cap_d_mm = 6;
cap_t_mm = 8;

// Connectivity / robustness
// Use 1-2mm overlap to guarantee watertight unions
overlap_mm = 1.2;
post_d_mm  = 6.0; // standoff post diameter (around holes)

// ---------- helpers ----------
module rounded_rect_prism(w,h,t,r){
    minkowski(){
        cube([w-2*r, h-2*r, t], center=true);
        cylinder(r=r, h=0.01, center=true);
    }
}

module hole_pattern(zc, h){
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*(width_mm/2 - mount_edge_offset_mm),
                   sy*(height_mm/2 - mount_edge_offset_mm),
                   zc])
            cylinder(d=mount_hole_diameter_mm, h=h, center=true);
}

// ---------- main model ----------
module display_module(){
    // Z references
    z_bezel_c   = 0;
    z_bezel_top = z_bezel_c + bezel_thickness_mm/2;
    z_bezel_bot = z_bezel_c - bezel_thickness_mm/2;

    // PCB sits behind bezel with standoff gap; overlap ensures union connectivity
    z_pcb_c   = z_bezel_bot - standoff_mm - pcb_thickness_mm/2 + overlap_mm;
    z_pcb_top = z_pcb_c + pcb_thickness_mm/2;
    z_pcb_bot = z_pcb_c - pcb_thickness_mm/2;

    // Posts span from bezel bottom to PCB top (with overlap both ends)
    post_h   = (z_bezel_bot - z_pcb_top) + 2*overlap_mm;
    z_post_c = (z_bezel_bot + z_pcb_top)/2;

    // Common edge offsets for backside parts (all formula-based)
    edge_clear_mm = 4.0;
    y_top_inner   =  height_mm/2 - edge_clear_mm;
    y_bot_inner   = -height_mm/2 + edge_clear_mm;
    x_right_inner =  width_mm/2  - edge_clear_mm;
    x_left_inner  = -width_mm/2  + edge_clear_mm;

    // --- Added missing/previously floating underside blocks ---
    // Rear connector/port block (underside) - must intersect PCB by overlap
    port_w_mm = 26;
    port_h_mm = 14;
    port_t_mm = 10;

    // Large rear backing/cover block (underside) - must intersect PCB by overlap
    back_w_mm = 62;
    back_h_mm = 38;
    back_t_mm = 6;

    // Place underside blocks so their TOP face penetrates the PCB bottom by overlap_mm
    // (i.e., z_top = z_pcb_bot + overlap_mm)
    z_port_c = (z_pcb_bot + overlap_mm) - port_t_mm/2;
    z_back_c = (z_pcb_bot + overlap_mm) - back_t_mm/2;

    union(){
        // --- Bezel/frame with recessed opening ---
        color([0.08,0.08,0.10])
        difference(){
            rounded_rect_prism(width_mm, height_mm, bezel_thickness_mm, corner_radius_mm);

            // Recessed aperture (does not cut through)
            translate([0,0, z_bezel_top - aperture_depth_mm/2 + overlap_mm/2])
                cube([aperture_w_mm, aperture_h_mm, aperture_depth_mm + overlap_mm], center=true);

            // Mount holes through bezel
            hole_pattern(z_bezel_c, bezel_thickness_mm + 2*overlap_mm);
        }

        // --- Screen glass sitting in recess (connected via overlap) ---
        color([0.02,0.02,0.02])
        translate([0,0, z_bezel_top - aperture_depth_mm + glass_t_mm/2 - overlap_mm/2])
            cube([glass_w_mm, glass_h_mm, glass_t_mm + overlap_mm], center=true);

        // --- Standoff posts around mounting holes (connect bezel to PCB) ---
        color([0.12,0.12,0.14])
        difference(){
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(width_mm/2 - mount_edge_offset_mm),
                           sy*(height_mm/2 - mount_edge_offset_mm),
                           z_post_c])
                    cylinder(d=post_d_mm, h=post_h, center=true);

            // Drill holes through posts
            hole_pattern(z_post_c, post_h + 2*overlap_mm);
        }

        // --- PCB (connected to posts by overlap) ---
        color([0.0,0.35,0.15])
        difference(){
            translate([0,0,z_pcb_c])
                rounded_rect_prism(width_mm-1.0, height_mm-1.0, pcb_thickness_mm, max(1.5, corner_radius_mm-1.0));

            // Mount holes through PCB
            hole_pattern(z_pcb_c, pcb_thickness_mm + 2*overlap_mm);
        }

        // =========================
        // Back-side (negative Z) components: connected to PCB by overlap
        // =========================

        // Long header connector near top edge (back side)
        color([0.85,0.85,0.80])
        translate([0,
                   y_top_inner - header_h_mm/2,
                   (z_pcb_bot + overlap_mm) - header_t_mm/2])
            cube([header_w_mm, header_h_mm, header_t_mm + overlap_mm], center=true);

        // SD card slot near right edge (back side)
        color([0.65,0.65,0.65])
        translate([x_right_inner - sd_w_mm/2,
                   0,
                   (z_pcb_bot + overlap_mm) - sd_t_mm/2])
            cube([sd_w_mm, sd_h_mm, sd_t_mm + overlap_mm], center=true);

        // USB connector near bottom edge (back side)
        color([0.70,0.70,0.70])
        translate([0,
                   y_bot_inner + usb_h_mm/2,
                   (z_pcb_bot + overlap_mm) - usb_t_mm/2])
            cube([usb_w_mm, usb_h_mm, usb_t_mm + overlap_mm], center=true);

        // --- FIX 1: Rear connector/port block (underside) - attached (overlaps PCB) ---
        // Positioned near bottom edge, centered in X; top face penetrates PCB by overlap_mm
        color([0.55,0.55,0.55])
        translate([0,
                   y_bot_inner + port_h_mm/2,
                   z_port_c])
            cube([port_w_mm, port_h_mm, port_t_mm], center=true);

        // --- FIX 2: Large rear backing/cover block (underside) - attached (overlaps PCB) ---
        // Centered; top face penetrates PCB by overlap_mm
        color([0.75,0.75,0.75])
        translate([0, 0, z_back_c])
            cube([back_w_mm, back_h_mm, back_t_mm], center=true);

        // =========================
        // Top-side (positive Z) components: connected to PCB by overlap
        // =========================

        // Main IC on top side (positive Z)
        color([0.10,0.10,0.10])
        translate([-width_mm*0.12,
                   -height_mm*0.10,
                   (z_pcb_top - overlap_mm) + chip_t_mm/2])
            cube([chip_w_mm, chip_h_mm, chip_t_mm + overlap_mm], center=true);

        // Regulator block on top side (positive Z)
        color([0.15,0.15,0.15])
        translate([width_mm*0.18,
                   -height_mm*0.18,
                   (z_pcb_top - overlap_mm) + reg_t_mm/2])
            cube([reg_w_mm, reg_h_mm, reg_t_mm + overlap_mm], center=true);

        // Two electrolytic caps on back side (negative Z), connected to PCB
        color([0.20,0.20,0.20])
        for (dx=[-1,1])
            translate([dx*(cap_d_mm*0.9),
                       height_mm*0.05,
                       (z_pcb_bot + overlap_mm) - cap_t_mm/2])
                cylinder(d=cap_d_mm, h=cap_t_mm + overlap_mm, center=true);

        // Small passive block on top side (positive Z)
        color([0.20,0.20,0.20])
        translate([x_left_inner + 10/2,
                   height_mm*0.18,
                   (z_pcb_top - overlap_mm) + 1.0/2])
            cube([10, 6, 1.0 + overlap_mm], center=true);
    }
}

display_module();