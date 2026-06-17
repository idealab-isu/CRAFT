$fn = 64;

// Parameters (1602A overall: 71.3 x 24.3)
module_width_mm  = 71.3;   //[35.65:142.6:0.1]
module_height_mm = 24.3;   //[12.15:48.6:0.1]
pcb_thickness_mm = 1.6;    //[0.8:3.2:0.1]

// LCD bezel/body
module_thickness_mm        = 8.5;   //[4.0:17.0:0.1]
display_body_width_mm      = 66.0;  //[33.0:132.0:0.1]
display_body_height_mm     = 16.0;  //[8.0:32.0:0.1]
display_body_offset_x_mm   = 0;     //[-10:10:0.1]
display_body_offset_y_mm   = 0;     //[-6:6:0.1]

// Viewing window
viewing_window_width_mm    = 56.0;  //[28.0:112.0:0.1]
viewing_window_height_mm   = 12.0;  //[6.0:24.0:0.1]
viewing_window_offset_x_mm = 0;     //[-10:10:0.1]
viewing_window_offset_y_mm = 0;     //[-6:6:0.1]
viewing_window_depth_mm    = 1.2;   //[0.5:3.0:0.1]

// Mount holes
mount_hole_diameter_mm     = 3.2;   //[2.0:6.0:0.1]
mount_hole_edge_margin_x_mm= 2.5;   //[1.0:6.0:0.1]
mount_hole_edge_margin_y_mm= 2.0;   //[1.0:6.0:0.1]

// 16-pin header (typical 1x16, 2.54mm pitch)
pin_header_pitch_mm        = 2.54;  //[1.27:5.08:0.01]
pin_count                  = 16;    //[8:24:1]
pin_header_orientation_long_edge = 1; //[0:1:1]
pin_header_depth_mm        = 3.5;   //[2.0:8.0:0.1]   // plastic width (short dimension)
pin_header_height_mm       = 8.0;   //[4.0:16.0:0.1]  // plastic height
pin_header_edge_margin_mm  = 1.5;   //[0.5:5.0:0.1]

// Pins (simple representation)
pin_square_mm              = 0.64;  //[0.3:1.2:0.01]
pin_length_below_pcb_mm    = 3.0;   //[1.0:8.0:0.1]
pin_length_above_plastic_mm= 2.5;   //[0.5:6.0:0.1]

// Robust overlap to ensure ONE connected solid
overlap_mm = 0.6; //[0.2:2.0:0.1]

// Derived
pin_header_row_length_mm = (pin_count - 1) * pin_header_pitch_mm;

// Z references (PCB centered at Z=0)
pcb_top_z = pcb_thickness_mm/2;
pcb_bot_z = -pcb_thickness_mm/2;

// LCD body placement (sits on PCB top, with slight overlap)
lcd_body_center_z = pcb_top_z + module_thickness_mm/2 - overlap_mm;

// Header placement (sits on PCB top, with slight overlap)
header_plastic_center_z = pcb_top_z + pin_header_height_mm/2 - overlap_mm;

// Pin placement (goes through PCB and into plastic a bit)
pin_total_len = pin_length_below_pcb_mm + pcb_thickness_mm + pin_header_height_mm + pin_length_above_plastic_mm;
pin_center_z  = pcb_bot_z - pin_length_below_pcb_mm/2 + (pin_total_len/2);

// Helper: mounting hole positions
function hole_x(sign) = sign * (module_width_mm/2  - mount_hole_edge_margin_x_mm);
function hole_y(sign) = sign * (module_height_mm/2 - mount_hole_edge_margin_y_mm);

// PCB with holes (holes are cut through entire assembly thickness)
module pcb_with_holes(cut_h) {
  difference() {
    cube([module_width_mm, module_height_mm, pcb_thickness_mm], center=true);
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([hole_x(sx), hole_y(sy), 0])
        cylinder(d=mount_hole_diameter_mm, h=cut_h, center=true);
    }
  }
}

// LCD body with recessed window
module lcd_body() {
  translate([display_body_offset_x_mm, display_body_offset_y_mm, lcd_body_center_z])
    difference() {
      cube([display_body_width_mm, display_body_height_mm, module_thickness_mm], center=true);

      // Recess for viewing window (cut from front/top face)
      translate([viewing_window_offset_x_mm, viewing_window_offset_y_mm,
                 module_thickness_mm/2 - viewing_window_depth_mm/2 + overlap_mm])
        cube([viewing_window_width_mm, viewing_window_height_mm, viewing_window_depth_mm + overlap_mm*2], center=true);
    }
}

// Viewing window "glass" (slightly inset, overlaps body)
module viewing_window() {
  translate([display_body_offset_x_mm + viewing_window_offset_x_mm,
             display_body_offset_y_mm + viewing_window_offset_y_mm,
             pcb_top_z + module_thickness_mm - viewing_window_depth_mm/2 - overlap_mm])
    cube([viewing_window_width_mm, viewing_window_height_mm, viewing_window_depth_mm], center=true);
}

// Header plastic block + pins (connected to PCB via overlap)
module pin_header() {
  // Determine header axis and placement along an edge
  if (pin_header_orientation_long_edge == 1) {
    // Along X (long edge), placed near -Y edge
    header_center_y = -(module_height_mm/2) + pin_header_edge_margin_mm + pin_header_depth_mm/2 - overlap_mm;

    // Plastic
    translate([0, header_center_y, header_plastic_center_z])
      cube([pin_header_row_length_mm + pin_header_pitch_mm, pin_header_depth_mm, pin_header_height_mm], center=true);

    // Pins (1xN)
    for (i = [0:pin_count-1]) {
      x_i = -((pin_count-1)*pin_header_pitch_mm)/2 + i*pin_header_pitch_mm;
      translate([x_i, header_center_y, pin_center_z])
        cube([pin_square_mm, pin_square_mm, pin_total_len], center=true);
    }
  } else {
    // Along Y (short edge), placed near -X edge
    header_center_x = -(module_width_mm/2) + pin_header_edge_margin_mm + pin_header_depth_mm/2 - overlap_mm;

    // Plastic
    translate([header_center_x, 0, header_plastic_center_z])
      cube([pin_header_depth_mm, pin_header_row_length_mm + pin_header_pitch_mm, pin_header_height_mm], center=true);

    // Pins (1xN)
    for (i = [0:pin_count-1]) {
      y_i = -((pin_count-1)*pin_header_pitch_mm)/2 + i*pin_header_pitch_mm;
      translate([header_center_x, y_i, pin_center_z])
        cube([pin_square_mm, pin_square_mm, pin_total_len], center=true);
    }
  }
}

// Final assembly: ONE connected solid (union), with holes cut after union
module assembly() {
  // Height for hole cutting: cover pins below PCB to top of LCD body
  cut_h = (pin_length_below_pcb_mm + pcb_thickness_mm + module_thickness_mm + pin_header_height_mm + pin_length_above_plastic_mm) + 10;

  difference() {
    union() {
      pcb_with_holes(0); // no holes here; holes cut in final difference for robustness
      lcd_body();
      viewing_window();
      pin_header();
    }

    // Cut mounting holes through everything
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([hole_x(sx), hole_y(sy), 0])
        cylinder(d=mount_hole_diameter_mm, h=cut_h, center=true);
    }
  }
}

assembly();