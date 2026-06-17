$fn = 96;

// Parameters
overall_width_mm = 40; //[20:80:0.1]
overall_height_mm = 29; //[14.5:58:0.1]
panel_thickness_mm = 2; //[1:4:0.1]
flange_thickness_mm = 2; //[1:4:0.1]
bezel_thickness_mm = 2; //[1:4:0.1]
body_depth_mm = 30; //[15:60:0.5]
corner_radius_mm = 3; //[1.5:6:0.1]
mount_hole_diameter_mm = 3.2; //[2:6.4:0.1]
mount_hole_pitch_x_mm = 32; //[16:64:0.1]
mount_hole_pitch_y_mm = 21; //[10.5:42:0.1]
socket_opening_width_mm = 27.0; //[12.25:49:0.01]
socket_opening_height_mm = 19.0; //[8.17:32.68:0.01]
socket_opening_depth_mm = 17; //[8.5:34:0.1]
terminal_count = 3; //[2:6:1]
overlap_mm = 1; //[0.5:2:0.1]
body_wall_mm = 2.5; //[1.5:5:0.1]
filter_can_extra_w_mm = 8; //[0:12:0.5]
filter_can_extra_h_mm = 8; //[0:12:0.5]
filter_can_depth_mm = 18; //[8:36:0.5]
terminal_pad_w_mm = 6.3; //[4:10:0.1]
terminal_pad_t_mm = 0.8; //[0.5:2:0.1]
terminal_pad_l_mm = 10; //[6:20:0.5]
terminal_spread_x_mm = 14; //[8:20:0.5]
terminal_offset_y_mm = 3; //[0:8:0.5]

// ---------- helpers ----------
module rounded_rect_2d(x, y, r) {
  rr = min(r, x/2, y/2);
  offset(rr) offset(-rr) square([x, y], center=true);
}

module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  rr = min(r, x/2, y/2);
  translate(center ? [0,0,0] : [x/2,y/2,z/2])
    linear_extrude(height=z, center=true)
      rounded_rect_2d(x, y, rr);
}

// Chamfered rectangular prism by hulling two rounded rectangles of different size
module chamfered_rect_prism(x, y, z, r=1, chamfer=1, center=true) {
  ch = min(chamfer, z/2 - 0.01);
  translate(center ? [0,0,0] : [x/2,y/2,z/2])
    hull() {
      translate([0,0,-z/2 + ch/2])
        linear_extrude(height=ch, center=true)
          rounded_rect_2d(x, y, r);
      translate([0,0, z/2 - ch/2])
        linear_extrude(height=ch, center=true)
          rounded_rect_2d(max(0.1, x-2*ch), max(0.1, y-2*ch), max(0.1, r-ch/2));
    }
}

// ---------- model ----------
module iec_inlet_filtered_40x29() {

  // Derived dimensions (all formula-based)
  front_thk = flange_thickness_mm + bezel_thickness_mm;

  // Keep requested visible face at 40x29; add a small flange overhang for realism
  flange_overhang_mm = 1.5;
  flange_w = overall_width_mm + 2*flange_overhang_mm;
  flange_h = overall_height_mm + 2*flange_overhang_mm;

  // Body outer (behind panel)
  body_outer_w = socket_opening_width_mm + 2*body_wall_mm;
  body_outer_h = socket_opening_height_mm + 2*body_wall_mm;

  // Filter can (rear)
  filter_w = body_outer_w + filter_can_extra_w_mm;
  filter_h = body_outer_h + filter_can_extra_h_mm;

  // Z layout: panel plane at z=0, front is +Z, rear is -Z
  flange_zc = front_thk/2;
  body_zc   = -body_depth_mm/2;
  filter_zc = -(body_depth_mm + filter_can_depth_mm/2 - overlap_mm);

  // Terminal pads attach to rear of filter can
  term_zc = -(body_depth_mm + filter_can_depth_mm - terminal_pad_l_mm/2 - overlap_mm);

  // --- IEC C14-ish inlet geometry (recognizable) ---
  // Outer "IEC profile" opening (chamfered) and inner cavity
  c14_outer_w = socket_opening_width_mm;
  c14_outer_h = socket_opening_height_mm;

  // Shallow chamfered mouth
  mouth_d = min(4.0, front_thk - 0.2);
  mouth_ch = min(1.2, mouth_d/2 - 0.05);

  // Inner cavity behind mouth
  cavity_d = socket_opening_depth_mm;
  cavity_w = c14_outer_w - 1.6;
  cavity_h = c14_outer_h - 1.6;

  // Pin slots (3) as rounded-rect slots (more IEC-like than circles)
  pin_slot_w = 6.2;
  pin_slot_h = 3.2;
  pin_slot_r = 1.2;
  pin_slot_d = min(10, cavity_d - 2);

  // Pin layout (approx C14): two lower, one upper center
  pin_dx = 7.0;
  pin_y_lower = -4.6;
  pin_y_upper =  3.8;

  // Ground pin slightly larger
  gnd_slot_w = 6.6;
  gnd_slot_h = 3.6;

  // Mount holes through flange/bezel
  hole_h = front_thk + 2*overlap_mm;

  // Build as one connected solid: union then subtract openings/holes
  difference() {
    union() {
      // Bezel block at exact requested face size 40x29
      translate([0,0,flange_zc])
        rounded_rect_prism([overall_width_mm, overall_height_mm, front_thk], r=corner_radius_mm, center=true);

      // Flange lip (overhang), connected (overlap into bezel)
      translate([0,0, flange_zc - front_thk/2 + flange_thickness_mm/2 - overlap_mm/2])
        rounded_rect_prism([flange_w, flange_h, flange_thickness_mm + overlap_mm], r=corner_radius_mm, center=true);

      // Main body behind panel (connected with overlap)
      translate([0,0, body_zc - overlap_mm/2])
        rounded_rect_prism([body_outer_w, body_outer_h, body_depth_mm + overlap_mm], r=1.2, center=true);

      // Rear filter can (connected to body with overlap)
      translate([0,0, filter_zc])
        rounded_rect_prism([filter_w, filter_h, filter_can_depth_mm + overlap_mm], r=1.2, center=true);

      // Rear spade terminals (connected to filter can with overlap)
      translate([-terminal_spread_x_mm/2, -terminal_offset_y_mm, term_zc])
        cube([terminal_pad_w_mm, terminal_pad_t_mm, terminal_pad_l_mm + overlap_mm], center=true);
      translate([ terminal_spread_x_mm/2, -terminal_offset_y_mm, term_zc])
        cube([terminal_pad_w_mm, terminal_pad_t_mm, terminal_pad_l_mm + overlap_mm], center=true);
      translate([0, terminal_offset_y_mm, term_zc])
        cube([terminal_pad_w_mm, terminal_pad_t_mm, terminal_pad_l_mm + overlap_mm], center=true);

      // Small rear strain-relief/terminal block bump to make back view clearly different
      bump_w = min(filter_w - 2, body_outer_w + 4);
      bump_h = min(filter_h - 2, body_outer_h + 4);
      bump_d = 6;
      bump_zc = -(body_depth_mm + filter_can_depth_mm - bump_d/2 - overlap_mm);
      translate([0,0,bump_zc])
        rounded_rect_prism([bump_w, bump_h, bump_d + overlap_mm], r=1.0, center=true);
    }

    // --- Subtractions for recognizable IEC inlet geometry ---

    // Chamfered mouth (outer opening) from the front face inward
    // Place so its front is flush with z=front_thk and it cuts backward
    translate([0,0, front_thk - mouth_d/2])
      chamfered_rect_prism(c14_outer_w, c14_outer_h, mouth_d + overlap_mm, r=1.6, chamfer=mouth_ch, center=true);

    // Inner cavity behind mouth (deeper)
    // Starts just behind mouth and extends into body
    translate([0,0, front_thk - mouth_d - cavity_d/2 + overlap_mm/2])
      rounded_rect_prism([cavity_w, cavity_h, cavity_d + overlap_mm], r=1.2, center=true);

    // Add a deeper "throat" step to suggest IEC profile depth
    throat_d = max(6, cavity_d - 7);
    throat_w = max(6, cavity_w - 2.0);
    throat_h = max(6, cavity_h - 2.0);
    translate([0,0, front_thk - mouth_d - throat_d/2 - 5])
      rounded_rect_prism([throat_w, throat_h, throat_d + overlap_mm], r=1.0, center=true);

    // Pin slots (3) cut into the back wall region of the cavity
    // Position them inside the cavity depth (not on the front face)
    pin_zc = front_thk - mouth_d - min(9, cavity_d - 2) + pin_slot_d/2;
    // Left / Right (line)
    for (sx = [-1, 1]) {
      translate([sx*pin_dx, pin_y_lower, pin_zc])
        linear_extrude(height=pin_slot_d + overlap_mm, center=true)
          rounded_rect_2d(pin_slot_w, pin_slot_h, pin_slot_r);
    }
    // Ground (top center) slightly larger
    translate([0, pin_y_upper, pin_zc])
      linear_extrude(height=pin_slot_d + overlap_mm, center=true)
        rounded_rect_2d(gnd_slot_w, gnd_slot_h, pin_slot_r);

    // Mounting holes (4, using provided pitch)
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*mount_hole_pitch_x_mm/2, sy*mount_hole_pitch_y_mm/2, flange_zc])
        cylinder(d=mount_hole_diameter_mm, h=hole_h, center=true);
    }

    // Panel cutout relief behind flange (so it isn't a solid slab behind the face)
    translate([0,0, -panel_thickness_mm/2 - overlap_mm/2])
      rounded_rect_prism([body_outer_w, body_outer_h, panel_thickness_mm + overlap_mm], r=1.0, center=true);

    // Rear filter detail: shallow recess on the back face of the filter can
    // (makes back view clearly different without disconnecting the solid)
    recess_back_d = 2.5;
    recess_back_w = filter_w - 4;
    recess_back_h = filter_h - 4;
    recess_back_zc = -(body_depth_mm + filter_can_depth_mm) + recess_back_d/2;
    translate([0,0,recess_back_zc])
      rounded_rect_prism([recess_back_w, recess_back_h, recess_back_d + overlap_mm], r=1.0, center=true);
  }
}

iec_inlet_filtered_40x29();