// Parameters
cutout_width_mm = 40; //[20:80:0.5]
cutout_height_mm = 27; //[13.5:54:0.5]
panel_thickness_mm = 2; //[1:6:0.5]
flange_width_mm = 50; //[35:80:0.5]
flange_height_mm = 35; //[25:70:0.5]
flange_thickness_mm = 3; //[1.5:8:0.5]
bezel_thickness_mm = 2; //[1:6:0.5]
bezel_radius_mm = 2; //[0.5:6:0.5]
overall_depth_mm = 45; //[25:90:1]
body_wall_mm = 2; //[1:5:0.5]
overlap_mm = 1; //[0.5:2:0.1]
screw_hole_diameter_mm = 3.2; //[2:6:0.1]
screw_hole_pitch_mm = 44; //[30:70:0.5]
screw_hole_edge_margin_mm = 6; //[3:12:0.5]
switch_opening_width_mm = 19; //[10:30:0.5]
switch_opening_height_mm = 13; //[8:20:0.5]
fuse_opening_width_mm = 22; //[12:35:0.5]
fuse_opening_height_mm = 12; //[7:20:0.5]
feature_opening_depth_mm = 6; //[3:15:0.5]
rear_terminal_width_mm = 30; //[15:60:0.5]
rear_terminal_height_mm = 18; //[10:40:0.5]
rear_terminal_depth_mm = 12; //[6:30:0.5]
include_switch = 1; //[0:1:1]
include_fuse_drawer = 1; //[0:1:1]
include_screw_mounts = 1; //[0:1:1]

// IEC Module - complete geometry
module iec() {
  color("Black") {
    // IEC Inlet Body
    difference() {
      translate([0, 0, -overall_depth_mm/2 + overlap_mm])
        cube([cutout_width_mm + 2*body_wall_mm, cutout_height_mm + 2*body_wall_mm, overall_depth_mm], center=true);
      translate([0, 0, -(overall_depth_mm - flange_thickness_mm - bezel_thickness_mm)/2 + overlap_mm - (flange_thickness_mm + bezel_thickness_mm)])
        cube([cutout_width_mm, cutout_height_mm, overall_depth_mm - flange_thickness_mm - bezel_thickness_mm], center=true);
    }
  }
}

// Mod - complete geometry
module mod() {
  color("DimGray") {
    // Rear Terminal Region
    translate([0, 0, -overall_depth_mm + rear_terminal_depth_mm/2 + overlap_mm])
      cube([rear_terminal_width_mm, rear_terminal_height_mm, rear_terminal_depth_mm], center=true);
  }
}

// Front Flange and Bezel
module front_flange_bezel() {
  color("Silver") {
    difference() {
      union() {
        // Front Flange Plate
        translate([0, 0, flange_thickness_mm/2])
          cube([flange_width_mm, flange_height_mm, flange_thickness_mm], center=true);
        // Front Bezel Plate
        translate([0, 0, flange_thickness_mm + bezel_thickness_mm/2 - overlap_mm])
          cube([flange_width_mm - 2*bezel_radius_mm, flange_height_mm - 2*bezel_radius_mm, bezel_thickness_mm], center=true);
        // Bezel Corner Cylinders
        for (x = [-1, 1], y = [-1, 1])
          translate([x * (flange_width_mm/2 - bezel_radius_mm), y * (flange_height_mm/2 - bezel_radius_mm), flange_thickness_mm + bezel_thickness_mm/2 - overlap_mm])
            cylinder(r=bezel_radius_mm, h=bezel_thickness_mm, center=true);
      }
      // IEC Socket Opening Cut
      translate([0, 0, (flange_thickness_mm + bezel_thickness_mm)/2])
        cube([cutout_width_mm, cutout_height_mm, flange_thickness_mm + bezel_thickness_mm + feature_opening_depth_mm], center=true);
      // Switch Actuator Opening
      if (include_switch)
        translate([-(cutout_width_mm/2) + switch_opening_width_mm/2 + body_wall_mm, (cutout_height_mm/2) - switch_opening_height_mm/2 - body_wall_mm, (flange_thickness_mm + bezel_thickness_mm)/2])
          cube([switch_opening_width_mm, switch_opening_height_mm, flange_thickness_mm + bezel_thickness_mm + feature_opening_depth_mm], center=true);
      // Fuse Drawer Opening
      if (include_fuse_drawer)
        translate([(cutout_width_mm/2) - fuse_opening_width_mm/2 - body_wall_mm, (cutout_height_mm/2) - fuse_opening_height_mm/2 - body_wall_mm, (flange_thickness_mm + bezel_thickness_mm)/2])
          cube([fuse_opening_width_mm, fuse_opening_height_mm, flange_thickness_mm + bezel_thickness_mm + feature_opening_depth_mm], center=true);
      // Mounting Screw Holes
      if (include_screw_mounts) {
        for (x = [-1, 1])
          translate([x * screw_hole_pitch_mm/2, flange_height_mm/2 - screw_hole_edge_margin_mm, (flange_thickness_mm + bezel_thickness_mm)/2])
            cylinder(r=screw_hole_diameter_mm/2, h=flange_thickness_mm + bezel_thickness_mm + feature_opening_depth_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  iec();
  mod();
  front_flange_bezel();
}

assembly();