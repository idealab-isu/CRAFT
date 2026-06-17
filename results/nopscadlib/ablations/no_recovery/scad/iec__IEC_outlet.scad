// Parameters
overall_width_mm = 40; //[20:80:0.5]
overall_height_mm = 32; //[16:64:0.5]
flange_thickness_mm = 2.5; //[1.2:5:0.1]
bezel_thickness_mm = 2; //[1:4:0.1]
corner_radius_mm = 2.5; //[0.5:6:0.1]
body_depth_mm = 28; //[14:56:0.5]
body_width_mm = 30; //[15:60:0.5]
body_height_mm = 22; //[11:44:0.5]
cutout_width_mm = 30; //[15:60:0.5]
cutout_height_mm = 22; //[11:44:0.5]
mount_hole_diameter_mm = 3.2; //[2:6.5:0.1]
mount_hole_pitch_x_mm = 30; //[15:60:0.5]
mount_hole_pitch_y_mm = 0; //[0:20:0.5]
mount_hole_offset_from_edges_mm = 5; //[2:12:0.5]
panel_thickness_mm = 2; //[0.8:6:0.1]
rear_body_clearance_extra_mm = 0.5; //[0.2:2:0.1]
terminal_clearance_width_mm = 26; //[13:52:0.5]
terminal_clearance_height_mm = 18; //[9:36:0.5]
terminal_clearance_depth_mm = 14; //[7:28:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// IEC Connector - complete geometry
module iec() {
  color("Black") {
    // Front Flange Bezel
    translate([0, 0, (flange_thickness_mm + bezel_thickness_mm) / 2])
      cube([overall_width_mm, overall_height_mm, flange_thickness_mm + bezel_thickness_mm], center=true);
    
    // IEC Connector Body
    translate([0, 0, -body_depth_mm / 2 + overlap_mm])
      cube([body_width_mm, body_height_mm, body_depth_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color("DimGray") {
    // Mounting Screw Holes
    union() {
      translate([-mount_hole_pitch_x_mm / 2, -mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm) / 2])
        cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + 2 * overlap_mm, center=true);
      translate([mount_hole_pitch_x_mm / 2, mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm) / 2])
        cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + 2 * overlap_mm, center=true);
    }
    
    // Panel Cutout Profile
    translate([0, 0, -panel_thickness_mm / 2])
      cube([cutout_width_mm, cutout_height_mm, panel_thickness_mm + 2 * overlap_mm], center=true);
    
    // Rear Body Clearance Volume
    translate([0, 0, -(body_depth_mm + 2 * rear_body_clearance_extra_mm) / 2 + overlap_mm])
      cube([body_width_mm + 2 * rear_body_clearance_extra_mm, body_height_mm + 2 * rear_body_clearance_extra_mm, body_depth_mm + 2 * rear_body_clearance_extra_mm], center=true);
    
    // Terminal Spade Clearance Zone
    translate([0, 0, -body_depth_mm + overlap_mm - terminal_clearance_depth_mm / 2])
      cube([terminal_clearance_width_mm, terminal_clearance_height_mm, terminal_clearance_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    iec();
    mod();
  }
}

assembly();