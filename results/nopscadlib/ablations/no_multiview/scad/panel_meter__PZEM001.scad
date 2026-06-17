// Parameters
overall_width_mm = 48; //[24:96:1]
overall_height_mm = 29; //[15:58:1]
overall_depth_mm = 24; //[12:48:1]
bezel_width_mm = 50; //[25:100:1]
bezel_height_mm = 31; //[16:62:1]
bezel_thickness_mm = 3; //[1.5:6:0.5]
bezel_corner_radius_mm = 2; //[0:6:0.5]
bezel_bevel_mm = 0.8; //[0:3:0.1]
body_wall_thickness_mm = 1.6; //[0.8:3.2:0.1]
display_window_width_mm = 34; //[17:68:1]
display_window_height_mm = 14; //[7:28:1]
display_window_corner_radius_mm = 1; //[0:4:0.5]
panel_cutout_width_mm = 45; //[22.5:90:1]
panel_cutout_height_mm = 26; //[13:52:1]
panel_thickness_range_mm = 3; //[1:6:0.5]
tab_width_mm = 6; //[3:12:0.5]
tab_height_mm = 12; //[6:24:1]
tab_depth_mm = 3; //[1.5:8:0.5]
tab_offset_z_mm = 10; //[0:20:1]
inner_aperture_width_mm = 40; //[20:80:1]
inner_aperture_height_mm = 20; //[10:40:1]
inner_aperture_depth_mm = 1.2; //[0.6:3:0.1]
button_count = 2; //[0:4:1]
button_width_mm = 8; //[4:16:0.5]
button_height_mm = 4; //[2:10:0.5]
button_depth_mm = 1.5; //[0.8:4:0.1]
assembly_overlap_mm = 1; //[0.5:2:0.1]
clearance_mm = 0.5; //[0.2:1.5:0.1]
rear_clearance_extra_mm = 6; //[3:15:1]

// Panel Meter - complete geometry
module panel_meter() {
  color("Black") {
    // Front Bezel
    translate([0, 0, bezel_thickness_mm / 2])
      cube([bezel_width_mm, bezel_height_mm, bezel_thickness_mm], center=true);
    
    // Meter Body
    translate([0, 0, -overall_depth_mm / 2 + assembly_overlap_mm])
      cube([overall_width_mm, overall_height_mm, overall_depth_mm], center=true);
    
    // Inner Aperture Frame
    difference() {
      translate([0, bezel_height_mm * 0.15, inner_aperture_depth_mm / 2 + assembly_overlap_mm])
        cube([inner_aperture_width_mm, inner_aperture_height_mm, inner_aperture_depth_mm], center=true);
      translate([0, bezel_height_mm * 0.15, inner_aperture_depth_mm / 2 + assembly_overlap_mm])
        cube([display_window_width_mm + 2 * clearance_mm, display_window_height_mm + 2 * clearance_mm, inner_aperture_depth_mm + 2 * assembly_overlap_mm], center=true);
    }
    
    // Mounting Tabs
    translate([-overall_width_mm / 2 - tab_width_mm / 2 + assembly_overlap_mm, 0, -tab_offset_z_mm])
      cube([tab_width_mm, tab_height_mm, tab_depth_mm], center=true);
    translate([overall_width_mm / 2 + tab_width_mm / 2 - assembly_overlap_mm, 0, -tab_offset_z_mm])
      cube([tab_width_mm, tab_height_mm, tab_depth_mm], center=true);
  }
}

// Panel Meter Button - complete geometry
module panel_meter_button() {
  color("Silver") {
    // Front Buttons
    translate([-bezel_width_mm * 0.18, -bezel_height_mm * 0.25, bezel_thickness_mm + button_depth_mm / 2 - assembly_overlap_mm])
      cube([button_width_mm, button_height_mm, button_depth_mm], center=true);
    translate([bezel_width_mm * 0.18, -bezel_height_mm * 0.25, bezel_thickness_mm + button_depth_mm / 2 - assembly_overlap_mm])
      cube([button_width_mm, button_height_mm, button_depth_mm], center=true);
  }
}

// Panel Meter Cutout - complete geometry
module panel_meter_cutout() {
  color("DimGray") {
    // Panel Cutout
    translate([0, 0, -panel_thickness_range_mm / 2])
      cube([panel_cutout_width_mm, panel_cutout_height_mm, panel_thickness_range_mm], center=true);
    
    // Rear Clearance Volume
    translate([0, 0, -(overall_depth_mm + rear_clearance_extra_mm) / 2 + assembly_overlap_mm])
      cube([overall_width_mm + 2 * clearance_mm, overall_height_mm + 2 * clearance_mm, overall_depth_mm + rear_clearance_extra_mm], center=true);
  }
}

// Assembly
module assembly() {
  panel_meter();
  panel_meter_button();
  panel_meter_cutout();
}

assembly();