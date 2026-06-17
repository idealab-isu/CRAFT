// UK mains socket (Screwfix-style), switched - single connected solid
// Parameters
plate_width_mm = 86; //[70:120]
plate_height_mm = 86; //[70:120]
overall_depth_mm = 9; //[6:18]
front_lip_thickness_mm = 2.5; //[1.5:5]
rear_cavity_margin_mm = 6; //[3:12]
rear_cavity_depth_mm = 6.5; //[3:14]
mount_hole_pitch_mm = 60.3; //[50:80]
mount_screw_clear_diameter_mm = 4.0; //[3.0:6.0]
counterbore_diameter_mm = 8.0; //[6.0:12.0]
counterbore_depth_mm = 2.5; //[1.0:5.0]

// Socket aperture geometry (UK)
pin_live_neutral_center_x_mm = 11.1; //[9:14]
pin_live_neutral_center_y_mm = -11.1; //[-14:-8]
pin_live_neutral_size_x_mm = 7.0; //[5.0:10.0]
pin_live_neutral_size_y_mm = 4.5; //[3.0:7.0]
pin_earth_center_y_mm = 11.1; //[8:14]
pin_earth_size_x_mm = 4.5; //[3.0:7.0]
pin_earth_size_y_mm = 8.5; //[6.0:12.0]
aperture_cut_depth_mm = 30; //[6:40]  // ensure fully through plate + rear housing

// Switch placement and features
switch_offset_x_mm = 22; //[10:30]
switch_offset_y_mm = 18; //[10:30]
switch_feature_width_mm = 28; //[18:45]
switch_feature_height_mm = 18; //[12:30]
switch_feature_depth_mm = 1.5; //[0.5:4]
connect_overlap_mm = 1; //[0.5:2]

// Rear housing + rocker details
rear_housing_depth_mm = 25; //[10:45]
rear_housing_margin_mm = 10; //[6:18]
rear_housing_corner_r_mm = 3; //[0:8]
terminal_boss_w_mm = 14; //[8:22]
terminal_boss_h_mm = 10; //[6:18]
terminal_boss_depth_mm = 8; //[4:16]
terminal_boss_offset_y_mm = -18; //[-30:-5]
terminal_boss_offset_x_mm = 18; //[10:30]

switch_rocker_w_mm = 30; //[18:45]
switch_rocker_h_mm = 20; //[12:35]
switch_rocker_thickness_mm = 4; //[2:8]
switch_bezel_margin_mm = 2; //[1:5]
switch_bezel_depth_mm = 1.2; //[0.5:3]
switch_gap_mm = 0.6; //[0.2:1.2]

// Added: socket front recess + shutter cues (visual recognizability)
socket_center_x_mm = -18; // place socket on left, switch on right
socket_center_y_mm = -2;
socket_recess_w_mm = 44; //[34:55]
socket_recess_h_mm = 36; //[28:48]
socket_recess_depth_mm = 1.2; //[0.6:2.5]
socket_recess_corner_r_mm = 3; //[0:6]

shutter_slot_w_mm = 2.2; //[1.2:3.5]
shutter_slot_h_mm = 6.0; //[4:10]
shutter_slot_offset_y_mm = 2.0; //[0:5]
shutter_slot_depth_mm = 0.8; //[0.3:1.5]

$fn = 64;

module rounded_box(size=[10,10,10], r=2, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2);
  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
      for (ix = [-1, 1], iy = [-1, 1])
        translate([ix*(sx/2-rr), iy*(sy/2-rr), 0])
          cylinder(r=rr, h=sz, center=true);
    }
}

module faceplate_solid() {
  union() {
    // Main plate
    cube([plate_width_mm, plate_height_mm, overall_depth_mm], center=true);

    // Front lip frame (thin raised border)
    lip_w = plate_width_mm - 2*front_lip_thickness_mm;
    lip_h = plate_height_mm - 2*front_lip_thickness_mm;
    lip_t = front_lip_thickness_mm;

    translate([0,0, overall_depth_mm/2 - lip_t/2])
      difference() {
        cube([plate_width_mm, plate_height_mm, lip_t], center=true);
        cube([lip_w, lip_h, lip_t + 2*connect_overlap_mm], center=true);
      }
  }
}

module rear_housing_solid() {
  housing_w = plate_width_mm - 2*rear_housing_margin_mm;
  housing_h = plate_height_mm - 2*rear_housing_margin_mm;

  translate([0, 0, -overall_depth_mm/2 - rear_housing_depth_mm/2 + connect_overlap_mm])
    rounded_box([housing_w, housing_h, rear_housing_depth_mm], r=rear_housing_corner_r_mm, center=true);
}

module switch_bezel_and_rocker_solid() {
  bezel_w = switch_rocker_w_mm + 2*switch_bezel_margin_mm;
  bezel_h = switch_rocker_h_mm + 2*switch_bezel_margin_mm;

  bezel_zc = overall_depth_mm/2 - switch_bezel_depth_mm/2;
  rocker_zc = overall_depth_mm/2 + switch_rocker_thickness_mm/2 - connect_overlap_mm;

  translate([switch_offset_x_mm, switch_offset_y_mm, 0]) {
    // Bezel frame
    translate([0,0,bezel_zc])
      difference() {
        cube([bezel_w, bezel_h, switch_bezel_depth_mm + connect_overlap_mm], center=true);
        cube([switch_rocker_w_mm + switch_gap_mm, switch_rocker_h_mm + switch_gap_mm,
              switch_bezel_depth_mm + 2*connect_overlap_mm], center=true);
      }

    // Rocker (raised)
    translate([0,0,rocker_zc])
      hull() {
        cube([switch_rocker_w_mm, switch_rocker_h_mm, switch_rocker_thickness_mm], center=true);
        translate([0,0, switch_rocker_thickness_mm/2])
          cube([switch_rocker_w_mm*0.92, switch_rocker_h_mm*0.92, 0.01], center=true);
      }
  }
}

module terminal_bosses_solid() {
  boss_zc = -overall_depth_mm/2 - terminal_boss_depth_mm/2 + connect_overlap_mm;

  for (sx = [-1, 1]) {
    translate([sx*terminal_boss_offset_x_mm, terminal_boss_offset_y_mm, boss_zc])
      rounded_box([terminal_boss_w_mm, terminal_boss_h_mm, terminal_boss_depth_mm], r=2, center=true);
  }
}

module socket_front_recess_cut() {
  // Recessed area around apertures (recognizable socket front)
  recess_zc = overall_depth_mm/2 - socket_recess_depth_mm/2 + connect_overlap_mm/2;
  translate([socket_center_x_mm, socket_center_y_mm, recess_zc])
    rounded_box([socket_recess_w_mm, socket_recess_h_mm, socket_recess_depth_mm + connect_overlap_mm],
                r=socket_recess_corner_r_mm, center=true);
}

module pin_apertures_cut() {
  // Through cuts for UK socket apertures (L, N, E)
  // Ensure cuts go through plate and into rear housing
  cut_h = overall_depth_mm + rear_housing_depth_mm + 6*connect_overlap_mm;
  cut_zc = -rear_housing_depth_mm/2; // centered so it spans both plate and housing

  translate([socket_center_x_mm, socket_center_y_mm, 0]) {
    translate([ pin_live_neutral_center_x_mm, pin_live_neutral_center_y_mm, cut_zc])
      cube([pin_live_neutral_size_x_mm, pin_live_neutral_size_y_mm, cut_h], center=true);
    translate([-pin_live_neutral_center_x_mm, pin_live_neutral_center_y_mm, cut_zc])
      cube([pin_live_neutral_size_x_mm, pin_live_neutral_size_y_mm, cut_h], center=true);
    translate([0, pin_earth_center_y_mm, cut_zc])
      cube([pin_earth_size_x_mm, pin_earth_size_y_mm, cut_h], center=true);
  }
}

module shutter_cues_cut() {
  // Small shallow slots above L/N to suggest shutter mechanism (visual cue only)
  slot_zc = overall_depth_mm/2 - shutter_slot_depth_mm/2 + connect_overlap_mm/2;

  translate([socket_center_x_mm, socket_center_y_mm, 0]) {
    for (sx = [-1, 1]) {
      translate([sx*pin_live_neutral_center_x_mm, pin_live_neutral_center_y_mm + shutter_slot_offset_y_mm, slot_zc])
        cube([shutter_slot_w_mm, shutter_slot_h_mm, shutter_slot_depth_mm + connect_overlap_mm], center=true);
    }
  }
}

module mounting_holes_cut() {
  // Through holes + counterbores from front
  through_h = overall_depth_mm + rear_housing_depth_mm + 6*connect_overlap_mm;

  for (sy = [-1, 1]) {
    translate([0, sy*mount_hole_pitch_mm/2, -rear_housing_depth_mm/2])
      cylinder(r=mount_screw_clear_diameter_mm/2, h=through_h, center=true);

    translate([0, sy*mount_hole_pitch_mm/2, overall_depth_mm/2 - counterbore_depth_mm/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + 2*connect_overlap_mm, center=true);
  }
}

module rear_cavity_cut() {
  // Hollow cavity behind faceplate (leave front skin)
  cavity_w = plate_width_mm - 2*rear_cavity_margin_mm;
  cavity_h = plate_height_mm - 2*rear_cavity_margin_mm;

  cavity_depth = min(rear_cavity_depth_mm, max(0.1, overall_depth_mm - front_lip_thickness_mm));
  cavity_zc = -overall_depth_mm/2 + cavity_depth/2 + connect_overlap_mm;

  translate([0, 0, cavity_zc])
    cube([cavity_w, cavity_h, cavity_depth + 2*connect_overlap_mm], center=true);
}

module assembly() {
  color([0.85, 0.85, 0.8])
  difference() {
    union() {
      faceplate_solid();
      rear_housing_solid();
      switch_bezel_and_rocker_solid();
      terminal_bosses_solid();
    }
    union() {
      socket_front_recess_cut();
      pin_apertures_cut();
      shutter_cues_cut();
      mounting_holes_cut();
      rear_cavity_cut();
    }
  }
}

assembly();