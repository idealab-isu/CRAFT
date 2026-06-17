// Parameters
overall_width = 48; //[24:96:1]
overall_height = 29; //[15:58:1]
overall_depth = 25; //[13:50:1]
bezel_width = 50; //[25:100:1]
bezel_height = 31; //[16:62:1]
bezel_thickness = 3; //[1.5:6:0.5]
corner_radius = 2; //[0:6:0.5]
panel_cutout_width = 45.2; //[22.6:90.4:0.1]
panel_cutout_height = 26.2; //[13.1:52.4:0.1]
panel_thickness_range_min = 1; //[0.5:3:0.5]
panel_thickness_range_max = 3; //[1.5:6:0.5]
display_window_width = 34; //[17:68:1]
display_window_height = 14; //[7:28:1]
display_window_offset_x = 0; //[-10:10:0.5]
display_window_offset_y = 0; //[-10:10:0.5]
tab_width = 6; //[3:12:0.5]
tab_height = 10; //[5:20:0.5]
tab_depth = 2.5; //[1:6:0.5]
tab_offset_z = 8; //[0:20:0.5]
tolerance_xy = 0.2; //[0:1:0.05]
tolerance_z = 0.2; //[0:1:0.05]
overlap = 1; //[0.5:2:0.1]
rear_housing_clearance_xy = 0.5; //[0.2:2:0.1]
rear_housing_clearance_z = 1; //[0.5:3:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin_xy = 2; //[1:6:0.5]
pcb_offset_z = 6; //[2:15:0.5]
button_diameter = 6; //[3:12:0.5]
button_height = 1.5; //[0.8:4:0.1]
button_offset_x = 0; //[-15:15:0.5]
button_offset_y = -9.5; //[-20:20:0.5]
panel_cutout_depth = 5; //[1:20:1]

// Panel Meter - complete geometry
module panel_meter() {
  color("Black") {
    // Front Bezel with Display Window
    difference() {
      translate([0, 0, bezel_thickness/2])
        cube([bezel_width, bezel_height, bezel_thickness], center=true);
      translate([display_window_offset_x, display_window_offset_y, bezel_thickness/2])
        cube([display_window_width, display_window_height, bezel_thickness + 2*overlap], center=true);
    }
    // Rear Body
    translate([0, 0, -overall_depth/2 + overlap])
      cube([overall_width, overall_height, overall_depth], center=true);
    // Retention Tabs
    translate([-(overall_width/2 + tab_width/2 - overlap), 0, -tab_offset_z])
      cube([tab_width, tab_height, tab_depth], center=true);
    translate([(overall_width/2 + tab_width/2 - overlap), 0, -tab_offset_z])
      cube([tab_width, tab_height, tab_depth], center=true);
    // PCB Envelope
    translate([0, 0, -pcb_offset_z])
      cube([overall_width - 2*pcb_margin_xy, overall_height - 2*pcb_margin_xy, pcb_thickness], center=true);
  }
}

// Panel Meter Button - complete geometry
module panel_meter_button() {
  color("White") {
    translate([button_offset_x, button_offset_y, bezel_thickness + button_height/2 - overlap])
      cylinder(r=button_diameter/2, h=button_height, center=true);
  }
}

// Panel Meter Cutout - complete geometry
module panel_meter_cutout() {
  color("Silver") {
    translate([0, 0, -panel_cutout_depth/2])
      cube([panel_cutout_width, panel_cutout_height, panel_cutout_depth], center=true);
    translate([0, 0, -(overall_depth + rear_housing_clearance_z)/2 + overlap])
      cube([overall_width + 2*rear_housing_clearance_xy, overall_height + 2*rear_housing_clearance_xy, overall_depth + rear_housing_clearance_z], center=true);
  }
}

// Assembly
module assembly() {
  panel_meter();
  panel_meter_button();
  panel_meter_cutout();
}

assembly();