$fn = 64;

// Target: LCD1602A module overall 71.3 x 24.3 mm, with recognizable bezel/window, glass, controller blob, and 16-pin header.
// One connected solid (union), with mounting holes cut (difference). All placements derived from dimensions.

// -------------------- Parameters --------------------
module_width_mm  = 71.3;
module_height_mm = 24.3;

// PCB
pcb_thickness_mm = 1.6;

// Bezel/frame (front)
bezel_thickness_mm = 3.2;          // thickness above PCB
bezel_inset_x_mm   = 2.0;          // bezel smaller than PCB
bezel_inset_y_mm   = 1.2;

// Viewing window (cut into bezel)
window_width_mm  = 56.0;
window_height_mm = 14.0;
window_offset_x_mm = 0.0;
window_offset_y_mm = 2.0;          // slightly above center typical for 1602A
window_cut_depth_mm = 2.2;

// LCD glass (behind window, above PCB)
glass_thickness_mm = 1.1;
glass_margin_mm    = 1.2;          // glass larger than window opening

// Controller "blob"/IC area (back side)
controller_w_mm = 28.0;
controller_h_mm = 10.0;
controller_t_mm = 1.6;
controller_offset_x_mm = 0.0;
controller_offset_y_mm = -5.0;

// 16-pin header (bottom edge on back)
pin_header_pins = 16;
pin_pitch_mm = 2.54;
pin_body_w_mm = pin_header_pins * pin_pitch_mm + 2.0; // slight overhang
pin_body_h_mm = 5.0;
pin_body_t_mm = 3.5;
pin_offset_x_mm = 0.0;
pin_offset_y_mm = -module_height_mm/2 + pin_body_h_mm/2 + 1.2; // near bottom edge

// Pins (simple posts)
pin_d_mm = 0.7;
pin_len_mm = 3.0; // protrude below header body

// Mounting holes
mount_hole_d_mm = 3.2;
mount_hole_spacing_x_mm = 66.0;
mount_hole_spacing_y_mm = 18.0;

// Connectivity overlap
overlap_mm = 0.6;

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,2], r=1, center=true) {
  // Minkowski rounded rectangle prism
  minkowski() {
    cube([size[0]-2*r, size[1]-2*r, size[2]], center=center);
    cylinder(r=r, h=0.01, center=true);
  }
}

// -------------------- Model --------------------
module lcd1602a_solid() {
  // Z stack reference: PCB centered at z=0.
  pcb_z = 0;

  // Bezel sits on top of PCB
  bezel_z = pcb_z + pcb_thickness_mm/2 + bezel_thickness_mm/2 - overlap_mm;

  // Glass sits under bezel, above PCB, aligned with window
  glass_z = pcb_z + pcb_thickness_mm/2 + glass_thickness_mm/2 - overlap_mm;

  // Header body sits under PCB (back side)
  header_z = pcb_z - pcb_thickness_mm/2 - pin_body_t_mm/2 + overlap_mm;

  // Pins extend further down from header body
  pins_z = header_z - pin_body_t_mm/2 - pin_len_mm/2 + overlap_mm;

  // Controller blob on back side, under PCB
  controller_z = pcb_z - pcb_thickness_mm/2 - controller_t_mm/2 + overlap_mm;

  union() {
    // PCB
    color([0.0, 0.4, 0.2])
      cube([module_width_mm, module_height_mm, pcb_thickness_mm], center=true);

    // Bezel/frame with window cut (difference inside union keeps single solid)
    color([0.05, 0.05, 0.05])
    translate([0, 0, bezel_z])
    difference() {
      // Bezel outer
      rounded_box(
        size=[module_width_mm - 2*bezel_inset_x_mm,
              module_height_mm - 2*bezel_inset_y_mm,
              bezel_thickness_mm],
        r=1.2,
        center=true
      );

      // Window opening (cut through most of bezel thickness)
      translate([window_offset_x_mm, window_offset_y_mm, bezel_thickness_mm/2 - window_cut_depth_mm/2 + overlap_mm])
        cube([window_width_mm, window_height_mm, window_cut_depth_mm + 2*overlap_mm], center=true);
    }

    // LCD glass (slightly larger than window), connected by overlap into bezel/pcb
    color([0.2, 0.2, 0.25, 0.6])
    translate([window_offset_x_mm, window_offset_y_mm, glass_z])
      cube([window_width_mm + 2*glass_margin_mm,
            window_height_mm + 2*glass_margin_mm,
            glass_thickness_mm], center=true);

    // Back controller area (simple rounded block)
    color([0.1, 0.1, 0.1])
    translate([controller_offset_x_mm, controller_offset_y_mm, controller_z])
      rounded_box(size=[controller_w_mm, controller_h_mm, controller_t_mm], r=1.0, center=true);

    // Pin header body (connected to PCB by overlap)
    color([0.05, 0.05, 0.05])
    translate([pin_offset_x_mm, pin_offset_y_mm, header_z])
      cube([pin_body_w_mm, pin_body_h_mm, pin_body_t_mm], center=true);

    // Pins (16 posts), connected to header body by overlap
    color([0.8, 0.7, 0.2])
    for (i = [0:pin_header_pins-1]) {
      x0 = -((pin_header_pins-1) * pin_pitch_mm)/2;
      translate([pin_offset_x_mm + x0 + i*pin_pitch_mm,
                 pin_offset_y_mm,
                 pins_z])
        cylinder(d=pin_d_mm, h=pin_len_mm + 2*overlap_mm, center=true);
    }
  }
}

module mounting_holes_cut() {
  // Cut through entire stack (bezel + pcb + header + pins)
  total_h = bezel_thickness_mm + pcb_thickness_mm + pin_body_t_mm + pin_len_mm + controller_t_mm + 6;
  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx * mount_hole_spacing_x_mm/2,
                 sy * mount_hole_spacing_y_mm/2,
                 0])
        cylinder(d=mount_hole_d_mm, h=total_h, center=true);
}

// Final: one connected solid with holes removed
difference() {
  lcd1602a_solid();
  mounting_holes_cut();
}