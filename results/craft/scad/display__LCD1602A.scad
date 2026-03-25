$fn = 64;

// LCD1602A-like module (approx) - ONE connected solid
overall_width_mm  = 71.3;
overall_height_mm = 24.3;

// PCB
pcb_thickness_mm   = 1.6;

// Front bezel / frame (plastic bezel sitting on PCB)
bezel_thickness_mm      = 3.2;
bezel_corner_radius_mm  = 1.0;
bezel_margin_x_mm       = 1.2;   // bezel smaller than PCB
bezel_margin_y_mm       = 1.2;

// LCD window / aperture (typical 1602 viewing window)
aperture_width_mm   = 64.0;
aperture_height_mm  = 14.0;
aperture_depth_mm   = 1.6;   // recess depth into bezel
aperture_inset_z_mm = 0.4;   // from bezel front face

// Inner "black mask" / inner bezel step around window (front-face feature)
mask_frame_w_mm     = 68.0;
mask_frame_h_mm     = 18.0;
mask_thickness_mm   = 0.8;   // raised above bezel front slightly

// Glass (behind window)
display_glass_thickness_mm      = 1.2;
display_glass_clearance_xy_mm   = 0.4;

// Back-side LCD controller "blob/IC" area (approx)
controller_w_mm = 28;
controller_h_mm = 12;
controller_t_mm = 2.2;

// Contrast pot (approx)
pot_w_mm  = 7;
pot_h_mm  = 7;
pot_t_mm  = 4.0;

// Header (1x16) on PCB back side (approx)
header_pins        = 16;
pin_pitch_mm       = 2.54;
pin_d_mm           = 0.8;
pin_h_mm           = 6.0;
header_body_h_mm   = 3.0;
header_body_w_mm   = 4.0;   // across Y
header_body_l_mm   = (header_pins-1)*pin_pitch_mm + 2.0; // slight end margin
header_offset_y_mm = 0;     // centered
header_offset_x_mm = 0;     // centered

// Mounting holes (typical 1602 footprint-ish, approximate)
hole_d_mm          = 3.2;
hole_edge_x_mm     = 2.5;   // from left/right edge
hole_edge_y_mm     = 2.0;   // from top/bottom edge

overlap_mm = 0.6; // ensures connectivity between parts

module rrect2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2-r2), sy*(h/2-r2)]) circle(r=r2);
    }
}

module pcb_plate(){
    // PCB is the full 71.3 x 24.3 outline
    translate([0,0, -pcb_thickness_mm/2])
        linear_extrude(height=pcb_thickness_mm, center=true)
            rrect2d(overall_width_mm, overall_height_mm, 0.8);
}

module bezel_front(){
    // Bezel sits on top of PCB (front side, +Z), with recessed window
    bezel_w = overall_width_mm  - 2*bezel_margin_x_mm;
    bezel_h = overall_height_mm - 2*bezel_margin_y_mm;

    z_bezel_center = pcb_thickness_mm/2 + bezel_thickness_mm/2 - overlap_mm;

    difference(){
        // Main bezel slab
        translate([0,0,z_bezel_center])
            linear_extrude(height=bezel_thickness_mm, center=true)
                rrect2d(bezel_w, bezel_h, bezel_corner_radius_mm);

        // Window recess cut from bezel front face
        z_bezel_front = pcb_thickness_mm/2 + bezel_thickness_mm - overlap_mm;
        z_recess_center =
            z_bezel_front
            - aperture_inset_z_mm
            - (aperture_depth_mm + overlap_mm)/2;

        translate([0,0,z_recess_center])
            cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm + overlap_mm], center=true);
    }
}

module mask_frame(){
    // Raised inner frame around the window (front-face feature)
    // Implemented as a thin raised plate with a cutout window.
    bezel_w = overall_width_mm  - 2*bezel_margin_x_mm;
    bezel_h = overall_height_mm - 2*bezel_margin_y_mm;

    // Keep mask within bezel
    mw = min(mask_frame_w_mm, bezel_w - 1.0);
    mh = min(mask_frame_h_mm, bezel_h - 1.0);

    z_bezel_front = pcb_thickness_mm/2 + bezel_thickness_mm - overlap_mm;
    z_mask_center = z_bezel_front + mask_thickness_mm/2 - overlap_mm; // overlap into bezel

    difference(){
        translate([0,0,z_mask_center])
            linear_extrude(height=mask_thickness_mm, center=true)
                rrect2d(mw, mh, 0.8);

        // Cutout matches (slightly larger than) aperture
        translate([0,0,z_mask_center])
            cube([aperture_width_mm + 0.6, aperture_height_mm + 0.6, mask_thickness_mm + 2*overlap_mm], center=true);
    }
}

module glass(){
    // Glass sits behind the recess, slightly inside bezel volume to ensure connectivity
    z_bezel_front = pcb_thickness_mm/2 + bezel_thickness_mm - overlap_mm;

    z_glass_center =
        z_bezel_front
        - aperture_inset_z_mm
        - aperture_depth_mm
        + display_glass_thickness_mm/2
        - overlap_mm/2;

    translate([0,0,z_glass_center])
        cube([aperture_width_mm + 2*display_glass_clearance_xy_mm,
              aperture_height_mm + 2*display_glass_clearance_xy_mm,
              display_glass_thickness_mm], center=true);
}

module mounting_holes(){
    // Through holes across entire assembly thickness
    total_t = pcb_thickness_mm + bezel_thickness_mm + mask_thickness_mm + 10;
    x = overall_width_mm/2  - hole_edge_x_mm;
    y = overall_height_mm/2 - hole_edge_y_mm;

    for (sx=[-1,1], sy=[-1,1])
        translate([sx*x, sy*y, 0])
            cylinder(d=hole_d_mm, h=total_t, center=true);
}

module header(){
    // Header body + pins on back side of PCB, connected to PCB by overlap
    z_pcb_back = -pcb_thickness_mm/2; // PCB back surface at -pcb_thickness/2
    z_body_center = z_pcb_back - header_body_h_mm/2 + overlap_mm/2;
    z_pin_center  = z_pcb_back - header_body_h_mm - pin_h_mm/2 + overlap_mm/2;

    // Body
    translate([header_offset_x_mm, header_offset_y_mm, z_body_center])
        cube([header_body_l_mm, header_body_w_mm, header_body_h_mm], center=true);

    // Pins
    for (i=[0:header_pins-1]){
        x = header_offset_x_mm - (header_pins-1)*pin_pitch_mm/2 + i*pin_pitch_mm;
        translate([x, header_offset_y_mm, z_pin_center])
            cylinder(d=pin_d_mm, h=pin_h_mm, center=true);
    }
}

module back_components(){
    // Distinct back-side components to differentiate back view
    z_pcb_back = -pcb_thickness_mm/2;

    // Controller area (approx) centered slightly to the right
    ctrl_x = overall_width_mm*0.18;
    ctrl_y = 0;
    z_ctrl_center = z_pcb_back - controller_t_mm/2 + overlap_mm/2;

    translate([ctrl_x, ctrl_y, z_ctrl_center])
        cube([controller_w_mm, controller_h_mm, controller_t_mm], center=true);

    // Contrast pot near top-left area
    pot_x = -overall_width_mm*0.32;
    pot_y =  overall_height_mm*0.22;
    z_pot_center = z_pcb_back - pot_t_mm/2 + overlap_mm/2;

    translate([pot_x, pot_y, z_pot_center])
        cube([pot_w_mm, pot_h_mm, pot_t_mm], center=true);

    // Small connector/driver bump near left-middle (extra back detail)
    bump_w = 10;
    bump_h = 6;
    bump_t = 1.6;
    bump_x = -overall_width_mm*0.18;
    bump_y = -overall_height_mm*0.18;
    z_bump_center = z_pcb_back - bump_t/2 + overlap_mm/2;

    translate([bump_x, bump_y, z_bump_center])
        cube([bump_w, bump_h, bump_t], center=true);
}

module lcd1602a_module(){
    // Single connected solid: union of parts, with holes cut out
    difference(){
        union(){
            pcb_plate();       // base
            bezel_front();     // front bezel with window recess
            mask_frame();      // raised inner frame around window
            glass();           // glass behind window (connected via overlap)
            header();          // back header + pins
            back_components(); // back-side components
        }
        mounting_holes();
    }
}

lcd1602a_module();