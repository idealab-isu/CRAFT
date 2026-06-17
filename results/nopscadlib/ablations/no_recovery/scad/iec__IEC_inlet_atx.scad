// Parameters
cutout_width_mm = 40.0; //[20.0:80.0:0.5]
cutout_height_mm = 27.0; //[13.5:54.0:0.5]
panel_thickness_mm = 2.0; //[1.0:4.0:0.25]
fit_clearance_mm = 0.4; //[0.1:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
flange_width_mm = 50.0; //[40.0:80.0:0.5]
flange_height_mm = 35.0; //[27.0:70.0:0.5]
flange_thickness_mm = 3.0; //[1.5:6.0:0.25]
bezel_thickness_mm = 2.0; //[1.0:5.0:0.25]
bezel_radius_mm = 2.5; //[0.5:6.0:0.25]
body_depth_mm = 28.0; //[14.0:56.0:0.5]
body_wall_extra_mm = 2.0; //[1.0:5.0:0.25]
screw_hole_diameter_mm = 3.2; //[2.0:6.0:0.1]
screw_hole_pitch_mm = 40.0; //[25.0:70.0:0.5]
screw_hole_edge_margin_mm = 6.0; //[3.0:12.0:0.5]
terminal_clearance_width_mm = 26.0; //[15.0:45.0:0.5]
terminal_clearance_height_mm = 18.0; //[10.0:35.0:0.5]
terminal_clearance_depth_mm = 12.0; //[6.0:30.0:0.5]
rear_clearance_extra_depth_mm = 6.0; //[2.0:20.0:0.5]

// IEC Module - complete geometry
module iec() {
  color("Black") {
    // Body
    translate([0, 0, -(panel_thickness_mm/2 + (body_depth_mm + overlap_mm)/2 - overlap_mm)])
      cube([cutout_width_mm + 2*body_wall_extra_mm, cutout_height_mm + 2*body_wall_extra_mm, body_depth_mm + overlap_mm], center=true);
    // Front Flange Bezel
    translate([0, 0, (panel_thickness_mm/2 + (flange_thickness_mm + bezel_thickness_mm)/2 - overlap_mm)])
      cube([flange_width_mm, flange_height_mm, flange_thickness_mm + bezel_thickness_mm], center=true);
  }
}

// Mod Module - complete geometry
module mod() {
  color("DimGray") {
    // Rear Body Clearance Volume
    translate([0, 0, -(panel_thickness_mm/2 + (body_depth_mm + rear_clearance_extra_depth_mm)/2 - overlap_mm)])
      cube([cutout_width_mm + 2*(body_wall_extra_mm + fit_clearance_mm), cutout_height_mm + 2*(body_wall_extra_mm + fit_clearance_mm), body_depth_mm + rear_clearance_extra_depth_mm], center=true);
    // Spade Terminal Clearance
    translate([0, 0, -(panel_thickness_mm/2 + body_depth_mm - overlap_mm + terminal_clearance_depth_mm/2 - overlap_mm)])
      cube([terminal_clearance_width_mm, terminal_clearance_height_mm, terminal_clearance_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  // Panel Cutout
  color("Silver") translate([0, 0, 0])
    cube([cutout_width_mm + 2*fit_clearance_mm, cutout_height_mm + 2*fit_clearance_mm, panel_thickness_mm + 2*overlap_mm], center=true);
  
  // IEC Inlet with Flange and Bezel
  iec();
  
  // Mod with Rear Body and Terminal Clearance
  mod();
  
  // Mounting Screw Holes
  color("Silver") {
    translate([-(screw_hole_pitch_mm/2), 0, (panel_thickness_mm/2 + (flange_thickness_mm + bezel_thickness_mm)/2 - overlap_mm)])
      cylinder(r=screw_hole_diameter_mm/2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 4*overlap_mm, center=true);
    translate([(screw_hole_pitch_mm/2), 0, (panel_thickness_mm/2 + (flange_thickness_mm + bezel_thickness_mm)/2 - overlap_mm)])
      cylinder(r=screw_hole_diameter_mm/2, h=flange_thickness_mm + bezel_thickness_mm + panel_thickness_mm + 4*overlap_mm, center=true);
  }
}

assembly();