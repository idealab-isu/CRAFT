// Parameters
tolerance_mm = 0.2; //[0.05:0.6:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
overall_width_mm = 48; //[24:96:1]
overall_height_mm = 29; //[15:58:1]
overall_depth_mm = 24; //[12:48:1]
bezel_width_mm = 50; //[25:100:1]
bezel_height_mm = 31; //[16:62:1]
bezel_thickness_mm = 3; //[1.5:6:0.5]
corner_radius_mm = 2; //[0:6:0.5]
panel_cutout_width_mm = 46; //[23:92:1]
panel_cutout_height_mm = 27; //[14:54:1]
panel_thickness_mm = 3; //[1:6:0.5]
display_window_width_mm = 34; //[17:68:1]
display_window_height_mm = 14; //[7:28:1]
display_window_inset_mm = 0.5; //[0.2:2:0.1]
mounting_tab_width_mm = 6; //[3:12:0.5]
mounting_tab_height_mm = 18; //[9:36:1]
mounting_tab_depth_mm = 3; //[1.5:8:0.5]
mounting_tab_angle_deg = 10; //[0:20:1]
rear_clearance_width_mm = 52; //[26:104:1]
rear_clearance_height_mm = 33; //[17:66:1]
rear_clearance_depth_mm = 35; //[18:70:1]
connector_clearance_mm = 6; //[3:15:1]
pcb_width_mm = 44; //[22:88:1]
pcb_height_mm = 25; //[13:50:1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_offset_from_front_mm = 10; //[4:20:1]
button_diameter_mm = 4; //[2:8:0.5]
button_height_mm = 1.5; //[0.8:4:0.1]
button_spacing_mm = 8; //[4:16:0.5]
button_y_offset_mm = -10; //[-20:0:1]

// Panel Meter - complete geometry
module panel_meter() {
  color("Black") {
    // Meter Body
    translate([0, 0, -(bezel_thickness_mm/2 + overall_depth_mm/2 - overlap_mm)])
      cube([overall_width_mm, overall_height_mm, overall_depth_mm], center=true);
    
    // Front Bezel
    difference() {
      translate([0, 0, 0])
        cube([bezel_width_mm, bezel_height_mm, bezel_thickness_mm], center=true);
      translate([0, 0, 0])
        cube([display_window_width_mm, display_window_height_mm, (bezel_thickness_mm + 2*overlap_mm)], center=true);
    }
    
    // Mounting Tabs
    rotate([0, mounting_tab_angle_deg, 0])
      translate([-(overall_width_mm/2 + mounting_tab_width_mm/2 - overlap_mm), 0, -(bezel_thickness_mm + mounting_tab_depth_mm/2 - overlap_mm)])
        cube([mounting_tab_width_mm, mounting_tab_height_mm, mounting_tab_depth_mm], center=true);
    rotate([0, -mounting_tab_angle_deg, 0])
      translate([(overall_width_mm/2 + mounting_tab_width_mm/2 - overlap_mm), 0, -(bezel_thickness_mm + mounting_tab_depth_mm/2 - overlap_mm)])
        cube([mounting_tab_width_mm, mounting_tab_height_mm, mounting_tab_depth_mm], center=true);
    
    // PCB Volume
    translate([0, 0, -(pcb_offset_from_front_mm)])
      cube([pcb_width_mm, pcb_height_mm, pcb_thickness_mm], center=true);
    
    // Rear Clearance Volume
    translate([0, 0, -(bezel_thickness_mm + overall_depth_mm - overlap_mm) - (rear_clearance_depth_mm + connector_clearance_mm)/2 + overlap_mm])
      cube([rear_clearance_width_mm, rear_clearance_height_mm, (rear_clearance_depth_mm + connector_clearance_mm)], center=true);
  }
}

// Panel Meter Cutout - complete geometry
module panel_meter_cutout() {
  color("Silver") {
    translate([0, 0, 0])
      cube([(panel_cutout_width_mm + 2*tolerance_mm), (panel_cutout_height_mm + 2*tolerance_mm), panel_thickness_mm], center=true);
  }
}

// Panel Meter Button - complete geometry
module panel_meter_button() {
  color("White") {
    // Left Button
    translate([-button_spacing_mm/2, button_y_offset_mm, (bezel_thickness_mm/2 + button_height_mm/2 - overlap_mm)])
      cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
    
    // Right Button
    translate([button_spacing_mm/2, button_y_offset_mm, (bezel_thickness_mm/2 + button_height_mm/2 - overlap_mm)])
      cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  panel_meter();
  panel_meter_cutout();
  panel_meter_button();
}

assembly();