// Parameters
cutout_width_mm = 36; //[18:72:0.1]
cutout_height_mm = 27; //[13.5:54:0.1]
panel_thickness_mm = 2; //[1:4:0.1]
flange_width_mm = 50; //[35:80:0.1]
flange_height_mm = 40; //[30:70:0.1]
flange_thickness_mm = 3; //[1.5:6:0.1]
bezel_radius_mm = 2.5; //[1:6:0.1]
corner_radius_mm = 1.5; //[0.5:4:0.1]
screw_hole_diameter_mm = 3.2; //[2.4:5:0.1]
screw_hole_pitch_x_mm = 40; //[28:60:0.1]
screw_hole_pitch_y_mm = 0; //[0:20:0.1]
body_depth_mm = 30; //[20:60:0.1]
fuse_drawer_projection_mm = 8; //[4:16:0.1]
terminal_clearance_depth_mm = 12; //[6:25:0.1]
tolerance_mm = 0.2; //[0:0.8:0.05]
overlap_mm = 1; //[0.5:2:0.1]
body_wall_mm = 2; //[1:4:0.1]
fuse_drawer_width_mm = 18; //[12:28:0.1]
fuse_drawer_height_mm = 12; //[8:20:0.1]
fuse_drawer_depth_mm = 16; //[10:30:0.1]
spade_clearance_width_mm = 26; //[18:40:0.1]
spade_clearance_height_mm = 18; //[12:30:0.1]

// IEC Inlet Module
module iec() {
  color("Black") {
    // Front Flange Bezel
    difference() {
      hull() {
        translate([flange_width_mm/2 - bezel_radius_mm, flange_height_mm/2 - bezel_radius_mm, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=bezel_radius_mm, h=flange_thickness_mm, center=true);
        translate([-flange_width_mm/2 + bezel_radius_mm, flange_height_mm/2 - bezel_radius_mm, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=bezel_radius_mm, h=flange_thickness_mm, center=true);
        translate([flange_width_mm/2 - bezel_radius_mm, -flange_height_mm/2 + bezel_radius_mm, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=bezel_radius_mm, h=flange_thickness_mm, center=true);
        translate([-flange_width_mm/2 + bezel_radius_mm, -flange_height_mm/2 + bezel_radius_mm, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=bezel_radius_mm, h=flange_thickness_mm, center=true);
        translate([0, 0, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cube([flange_width_mm - 2*bezel_radius_mm, flange_height_mm - 2*bezel_radius_mm, flange_thickness_mm], center=true);
      }
      translate([0, 0, 0])
        cube([cutout_width_mm + 2*tolerance_mm, cutout_height_mm + 2*tolerance_mm, panel_thickness_mm + 2*overlap_mm], center=true);
      translate([-screw_hole_pitch_x_mm/2, screw_hole_pitch_y_mm/2, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=screw_hole_diameter_mm/2 + tolerance_mm, h=flange_thickness_mm + panel_thickness_mm + 4*overlap_mm, center=true);
      translate([screw_hole_pitch_x_mm/2, -screw_hole_pitch_y_mm/2, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=screw_hole_diameter_mm/2 + tolerance_mm, h=flange_thickness_mm + panel_thickness_mm + 4*overlap_mm, center=true);
    }
  }
}

// Mod Component
module mod() {
  color("DimGray") {
    // IEC Inlet Body
    hull() {
      translate([cutout_width_mm/2 - corner_radius_mm, cutout_height_mm/2 - corner_radius_mm, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
        cylinder(r=corner_radius_mm, h=body_depth_mm, center=true);
      translate([-cutout_width_mm/2 + corner_radius_mm, cutout_height_mm/2 - corner_radius_mm, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
        cylinder(r=corner_radius_mm, h=body_depth_mm, center=true);
      translate([cutout_width_mm/2 - corner_radius_mm, -cutout_height_mm/2 + corner_radius_mm, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
        cylinder(r=corner_radius_mm, h=body_depth_mm, center=true);
      translate([-cutout_width_mm/2 + corner_radius_mm, -cutout_height_mm/2 + corner_radius_mm, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
        cylinder(r=corner_radius_mm, h=body_depth_mm, center=true);
      translate([0, 0, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
        cube([cutout_width_mm - 2*corner_radius_mm, cutout_height_mm - 2*corner_radius_mm, body_depth_mm], center=true);
    }
    // Fuse Drawer Housing
    translate([0, cutout_height_mm/2 - fuse_drawer_height_mm/2 - body_wall_mm, panel_thickness_mm/2 + flange_thickness_mm + fuse_drawer_projection_mm - fuse_drawer_depth_mm/2])
      cube([fuse_drawer_width_mm, fuse_drawer_height_mm, fuse_drawer_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  iec();
  mod();
}

assembly();