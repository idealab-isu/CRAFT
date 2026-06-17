// Parameters
overall_width_mm = 40.0; //[20.0:80.0:0.5]
overall_height_mm = 32.0; //[16.0:64.0:0.5]
panel_thickness_mm = 2.0; //[0.8:6.0:0.1]
cutout_width_mm = 27.5; //[20.0:35.0:0.1]
cutout_height_mm = 20.0; //[14.0:28.0:0.1]
corner_radius_mm = 2.0; //[0.5:5.0:0.1]
flange_thickness_mm = 2.5; //[1.0:6.0:0.1]
bezel_thickness_mm = 1.5; //[0.5:4.0:0.1]
body_depth_mm = 28.0; //[14.0:56.0:0.5]
mount_hole_diameter_mm = 3.2; //[2.0:6.0:0.1]
mount_hole_pitch_x_mm = 30.0; //[20.0:38.0:0.5]
mount_hole_pitch_y_mm = 24.0; //[16.0:30.0:0.5]
clearance_margin_mm = 0.5; //[0.0:2.0:0.1]
rear_clearance_extra_mm = 6.0; //[2.0:20.0:0.5]
terminal_clearance_width_mm = 26.0; //[16.0:40.0:0.5]
terminal_clearance_height_mm = 18.0; //[10.0:30.0:0.5]
terminal_clearance_depth_mm = 14.0; //[8.0:30.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// IEC Flange and Bezel
module iec() {
  color("DimGray") {
    difference() {
      // Flange and Bezel
      translate([0, 0, (flange_thickness_mm + bezel_thickness_mm) / 2])
        cube([overall_width_mm, overall_height_mm, flange_thickness_mm + bezel_thickness_mm], center=true);
      
      // Panel Cutout Profile
      translate([0, 0, -panel_thickness_mm / 2])
        cube([cutout_width_mm + 2 * clearance_margin_mm, cutout_height_mm + 2 * clearance_margin_mm, panel_thickness_mm], center=true);
      
      // Mounting Holes
      union() {
        translate([mount_hole_pitch_x_mm / 2, mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm - panel_thickness_mm) / 2])
          cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 2 * overlap_mm, center=true);
        translate([-mount_hole_pitch_x_mm / 2, mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm - panel_thickness_mm) / 2])
          cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 2 * overlap_mm, center=true);
        translate([mount_hole_pitch_x_mm / 2, -mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm - panel_thickness_mm) / 2])
          cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 2 * overlap_mm, center=true);
        translate([-mount_hole_pitch_x_mm / 2, -mount_hole_pitch_y_mm / 2, (flange_thickness_mm + bezel_thickness_mm - panel_thickness_mm) / 2])
          cylinder(r=mount_hole_diameter_mm / 2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 2 * overlap_mm, center=true);
      }
    }
  }
}

// IEC Inlet Body
module mod() {
  color("Black") {
    // Inlet Body
    translate([0, 0, -body_depth_mm / 2 + overlap_mm])
      cube([cutout_width_mm - 2 * clearance_margin_mm, cutout_height_mm - 2 * clearance_margin_mm, body_depth_mm], center=true);
    
    // Rear Body Depth Clearance
    translate([0, 0, -(body_depth_mm + rear_clearance_extra_mm) / 2 + overlap_mm])
      cube([(cutout_width_mm - 2 * clearance_margin_mm) + 2 * clearance_margin_mm, (cutout_height_mm - 2 * clearance_margin_mm) + 2 * clearance_margin_mm, body_depth_mm + rear_clearance_extra_mm], center=true);
    
    // Terminal Spade Clearance Zone
    translate([0, 0, -body_depth_mm - terminal_clearance_depth_mm / 2 + overlap_mm])
      cube([terminal_clearance_width_mm + 2 * clearance_margin_mm, terminal_clearance_height_mm + 2 * clearance_margin_mm, terminal_clearance_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  iec();
  mod();
}

assembly();