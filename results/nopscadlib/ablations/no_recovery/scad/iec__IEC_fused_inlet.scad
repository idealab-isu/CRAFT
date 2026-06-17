// Parameters
cutout_width_mm = 36; //[18:72:0.1]
cutout_height_mm = 27; //[13.5:54:0.1]
cutout_clearance_mm = 0.2; //[0:1:0.05]
hole_clearance_mm = 0.2; //[0:1:0.05]
panel_thickness_mm = 2; //[1:6:0.1]
flange_width_mm = 50; //[30:100:0.1]
flange_height_mm = 35; //[20:70:0.1]
flange_thickness_mm = 3; //[1.5:8:0.1]
bezel_thickness_mm = 1.5; //[0.8:5:0.1]
bezel_inset_mm = 2; //[0.5:6:0.1]
body_wall_mm = 2; //[1:5:0.1]
body_depth_mm = 45; //[25:90:0.5]
front_face_recess_mm = 2; //[0:6:0.1]
socket_opening_width_mm = 24.5; //[18:35:0.1]
socket_opening_height_mm = 16.34; //[12:25:0.1]
socket_opening_depth_mm = 17; //[10:30:0.5]
fuse_drawer_width_mm = 20; //[12:35:0.1]
fuse_drawer_height_mm = 8; //[5:15:0.1]
fuse_drawer_offset_y_mm = 10; //[0:20:0.1]
clip_width_mm = 8; //[4:16:0.1]
clip_thickness_mm = 2; //[1:5:0.1]
clip_length_mm = 18; //[10:35:0.5]
spade_width_mm = 6.3; //[4.8:9.5:0.1]
spade_thickness_mm = 0.8; //[0.5:2:0.05]
spade_length_mm = 12; //[6:25:0.5]
spade_spacing_x_mm = 14; //[10:20:0.1]
spade_row_offset_y_mm = -6; //[-15:5:0.1]
spade_depth_from_back_mm = 2; //[0:10:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// IEC Inlet Module
module iec() {
  color("Black") {
    // Front flange with bezel
    union() {
      translate([0, 0, flange_thickness_mm / 2])
        cube([flange_width_mm, flange_height_mm, flange_thickness_mm], center=true);
      translate([0, 0, flange_thickness_mm + bezel_thickness_mm / 2 - overlap_mm])
        cube([flange_width_mm - 2 * bezel_inset_mm, flange_height_mm - 2 * bezel_inset_mm, bezel_thickness_mm], center=true);
    }
    
    // IEC inlet body with clips
    union() {
      translate([0, 0, -body_depth_mm / 2 + overlap_mm])
        cube([cutout_width_mm + 2 * body_wall_mm, cutout_height_mm + 2 * body_wall_mm, body_depth_mm], center=true);
      translate([-(cutout_width_mm + 2 * body_wall_mm) / 2 - clip_width_mm / 2 + overlap_mm, 0, -clip_length_mm / 2 + overlap_mm])
        cube([clip_width_mm, clip_thickness_mm, clip_length_mm], center=true);
      translate([(cutout_width_mm + 2 * body_wall_mm) / 2 + clip_width_mm / 2 - overlap_mm, 0, -clip_length_mm / 2 + overlap_mm])
        cube([clip_width_mm, clip_thickness_mm, clip_length_mm], center=true);
    }
    
    // Socket opening and fuse drawer access
    difference() {
      translate([0, 0, (socket_opening_depth_mm) / 2 - overlap_mm / 2])
        cube([socket_opening_width_mm, socket_opening_height_mm, socket_opening_depth_mm + overlap_mm], center=true);
      translate([0, fuse_drawer_offset_y_mm, front_face_recess_mm / 2 - overlap_mm / 2])
        cube([fuse_drawer_width_mm, fuse_drawer_height_mm, front_face_recess_mm + overlap_mm], center=true);
    }
  }
}

// Mod Module
module mod() {
  color("DimGray") {
    // Terminal spade positions
    union() {
      translate([-spade_spacing_x_mm / 2, spade_row_offset_y_mm, -body_depth_mm + spade_length_mm / 2 + spade_depth_from_back_mm - overlap_mm])
        cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
      translate([spade_spacing_x_mm / 2, spade_row_offset_y_mm, -body_depth_mm + spade_length_mm / 2 + spade_depth_from_back_mm - overlap_mm])
        cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
      translate([0, spade_row_offset_y_mm + (socket_opening_height_mm / 2 - spade_thickness_mm / 2), -body_depth_mm + spade_length_mm / 2 + spade_depth_from_back_mm - overlap_mm])
        cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
    }
    
    // Rear body depth envelope
    translate([0, 0, -body_depth_mm / 2 + overlap_mm])
      cube([cutout_width_mm + 2 * body_wall_mm, cutout_height_mm + 2 * body_wall_mm, body_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  iec();
  mod();
}

assembly();