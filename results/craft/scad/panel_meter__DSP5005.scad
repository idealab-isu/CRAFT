$fn = 64;

// Parameters
overall_size_x_mm = 48; //[24:96:1]
overall_size_y_mm = 29; //[15:58:1]
overall_size_z_mm = 22; //[11:44:1]

bezel_size_x_mm = 50; //[25:100:1]
bezel_size_y_mm = 31; //[16:62:1]
bezel_size_z_mm = 3; //[2:8:1]
bezel_corner_radius_mm = 3; //[0:8:1]
bezel_bevel_mm = 1; //[0:4:1]

body_wall_thickness_mm = 1.6; //[0.8:3.2:0.1]

display_aperture_x_mm = 36; //[18:72:1]
display_aperture_y_mm = 14; //[7:28:1]
display_aperture_corner_radius_mm = 1; //[0:4:0.1]
aperture_bezel_lip_mm = 1.2; //[0.5:3:0.1]

panel_thickness_min_mm = 1; //[0.5:3:0.1]
panel_thickness_max_mm = 3; //[1:6:0.1]

mounting_tab_size_x_mm = 8; //[4:16:1]
mounting_tab_size_y_mm = 10; //[5:20:1]
mounting_tab_size_z_mm = 2.5; //[1:6:0.1]
mounting_tab_offset_z_mm = 10; //[0:20:1]
mounting_tab_angle_deg = 10; //[0:25:1]

pcb_size_x_mm = 44; //[22:88:1]
pcb_size_y_mm = 25; //[13:50:1]
pcb_size_z_mm = 1.6; //[0.8:3.2:0.1]
pcb_offset_z_mm = 6; //[0:15:1]

button_count = 3; //[0:6:1]
button_pitch_x_mm = 8; //[5:15:1]
button_row_offset_y_mm = -9; //[-15:0:1]
button_size_x_mm = 5; //[3:10:1]
button_size_y_mm = 3; //[2:8:1]
button_size_z_mm = 1.2; //[0.6:3:0.1]
button_corner_radius_mm = 0.8; //[0:3:0.1]

panel_cutout_clearance_mm = 0.3; //[0:1:0.1]
rear_clearance_margin_mm = 2; //[0:6:1]

connect_overlap_mm = 1; //[0.5:2:0.1]

// Extra detailing parameters (kept derived / conservative)
terminal_block_w_mm = overall_size_x_mm * 0.55;
terminal_block_h_mm = 7;
terminal_block_d_mm = 6;
terminal_pitch_mm = 7.5;
terminal_hole_r_mm = 1.2;
terminal_hole_depth_mm = terminal_block_d_mm * 0.75;

screen_recess_depth_mm = 0.8;
screen_glass_thickness_mm = 0.6;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  if (r2 <= 0)
    square([w, h], center=true);
  else
    offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module rounded_box(w, h, d, r) {
  linear_extrude(height=d, center=true)
    rounded_rect_2d(w, h, r);
}

// ---------- Main solids (ONE connected solid) ----------
module front_bezel_solid() {
  // Bezel centered so its front face is at z=0, body extends to negative z
  translate([0, 0, -bezel_size_z_mm/2])
    rounded_box(bezel_size_x_mm, bezel_size_y_mm, bezel_size_z_mm, bezel_corner_radius_mm);
}

module rear_body_shell_solid() {
  body_z = overall_size_z_mm - bezel_size_z_mm;
  // Rear body sits behind bezel: its front face overlaps into bezel by connect_overlap_mm
  translate([0, 0, -(bezel_size_z_mm + body_z)/2 + connect_overlap_mm/2])
    rounded_box(overall_size_x_mm, overall_size_y_mm, body_z + connect_overlap_mm, 1.2);
}

module mounting_tabs_solid() {
  body_z = overall_size_z_mm - bezel_size_z_mm;

  // Place tabs near the rear half, attached to body sides with overlap
  tab_z_center = -(bezel_size_z_mm + body_z) + mounting_tab_offset_z_mm;
  // Clamp within body depth so it doesn't float
  tab_z_center_clamped = max(tab_z_center, -(bezel_size_z_mm + body_z) + mounting_tab_size_z_mm/2);

  for (sx = [-1, 1]) {
    rotate([0, sx * mounting_tab_angle_deg, 0])
      translate([ sx*(overall_size_x_mm/2 + mounting_tab_size_x_mm/2 - connect_overlap_mm),
                  0,
                  tab_z_center_clamped ])
        cube([mounting_tab_size_x_mm, mounting_tab_size_y_mm, mounting_tab_size_z_mm], center=true);
  }
}

module button_solid_at(x, y) {
  // Buttons protrude slightly from bezel front (z>0), but overlap into bezel to ensure connectivity
  translate([x, y, button_size_z_mm/2 - connect_overlap_mm])
    rounded_box(button_size_x_mm, button_size_y_mm, button_size_z_mm + connect_overlap_mm, button_corner_radius_mm);
}

module buttons_solid() {
  if (button_count <= 0) {
    // nothing
  } else if (button_count == 1) {
    button_solid_at(0, button_row_offset_y_mm);
  } else {
    // Centered row
    for (i = [0:button_count-1]) {
      x = (i - (button_count-1)/2) * button_pitch_x_mm;
      button_solid_at(x, button_row_offset_y_mm);
    }
  }
}

module terminal_block_solid() {
  body_z = overall_size_z_mm - bezel_size_z_mm;

  // Terminal block on rear face, centered in X, near bottom in Y
  // Rear face of body is at z = -(bezel_size_z_mm + body_z) + connect_overlap_mm/2
  rear_face_z = -(bezel_size_z_mm + body_z) + connect_overlap_mm/2;
  // Put block behind rear face but overlapping for connectivity
  block_center_z = rear_face_z - terminal_block_d_mm/2 + connect_overlap_mm;

  block_center_y = -overall_size_y_mm*0.18;

  translate([0, block_center_y, block_center_z])
    cube([terminal_block_w_mm, terminal_block_h_mm, terminal_block_d_mm], center=true);
}

module panel_meter_solid() {
  union() {
    front_bezel_solid();
    rear_body_shell_solid();
    mounting_tabs_solid();
    buttons_solid();
    terminal_block_solid();
  }
}

// ---------- Subtractions (details) ----------
module display_window_cut() {
  // Cut a recessed window into bezel front, leaving a lip
  // Front face at z=0, cut goes into negative z
  outer_w = display_aperture_x_mm;
  outer_h = display_aperture_y_mm;
  inner_w = max(outer_w - 2*aperture_bezel_lip_mm, 1);
  inner_h = max(outer_h - 2*aperture_bezel_lip_mm, 1);

  // Recess pocket
  translate([0, 0, -screen_recess_depth_mm/2])
    rounded_box(outer_w, outer_h, screen_recess_depth_mm + connect_overlap_mm, display_aperture_corner_radius_mm);

  // Through opening (slightly smaller) to suggest glass inset; still only a cut
  translate([0, 0, -(bezel_size_z_mm/2)])
    rounded_box(inner_w, inner_h, bezel_size_z_mm + 2*connect_overlap_mm, max(display_aperture_corner_radius_mm-0.3, 0));
}

module body_cavity_cut() {
  body_z = overall_size_z_mm - bezel_size_z_mm;

  inner_x = overall_size_x_mm - 2*body_wall_thickness_mm;
  inner_y = overall_size_y_mm - 2*body_wall_thickness_mm;
  inner_z = body_z - body_wall_thickness_mm;

  // Keep some material near bezel interface for strength
  translate([0, 0, -(bezel_size_z_mm + body_z)/2 + connect_overlap_mm/2 - body_wall_thickness_mm/2])
    cube([max(inner_x,1), max(inner_y,1), max(inner_z,1)], center=true);
}

module terminal_holes_cut() {
  body_z = overall_size_z_mm - bezel_size_z_mm;
  rear_face_z = -(bezel_size_z_mm + body_z) + connect_overlap_mm/2;
  block_center_z = rear_face_z - terminal_block_d_mm/2 + connect_overlap_mm;
  block_center_y = -overall_size_y_mm*0.18;

  // Two screw holes on terminal block, drilled from rear
  for (sx = [-1, 1]) {
    translate([sx*terminal_pitch_mm/2, block_center_y, rear_face_z - terminal_hole_depth_mm/2 - 0.01])
      rotate([90, 0, 0])  // orient along Y? better drill along Z: keep cylinder along Z
        children();
  }
}

// Drill along Z (rear to front)
module terminal_holes_cut_z() {
  body_z = overall_size_z_mm - bezel_size_z_mm;
  rear_face_z = -(bezel_size_z_mm + body_z) + connect_overlap_mm/2;
  block_center_y = -overall_size_y_mm*0.18;

  for (sx = [-1, 1]) {
    translate([sx*terminal_pitch_mm/2, block_center_y, rear_face_z - terminal_hole_depth_mm/2 + connect_overlap_mm])
      cylinder(r=terminal_hole_r_mm, h=terminal_hole_depth_mm + 2*connect_overlap_mm, center=true);
  }
}

// ---------- Cutout geometry (kept separate module, but not unioned into final solid) ----------
module panel_meter_cutout() {
  // Panel cutout volume (for reference/printing jigs). Not part of the meter solid.
  union() {
    translate([0, 0, -panel_thickness_max_mm/2])
      cube([overall_size_x_mm + 2*panel_cutout_clearance_mm,
            overall_size_y_mm + 2*panel_cutout_clearance_mm,
            panel_thickness_max_mm], center=true);

    translate([0, 0, -((overall_size_z_mm - bezel_size_z_mm) + rear_clearance_margin_mm)/2])
      cube([overall_size_x_mm + 2*rear_clearance_margin_mm,
            overall_size_y_mm + 2*rear_clearance_margin_mm,
            (overall_size_z_mm - bezel_size_z_mm) + rear_clearance_margin_mm], center=true);
  }
}

// ---------- Final: ONE connected solid with recognizable features ----------
difference() {
  panel_meter_solid();

  // Front display window / bezel recess
  display_window_cut();

  // Hollow rear body cavity
  body_cavity_cut();

  // Terminal screw holes
  terminal_holes_cut_z();
}