// Parameters
display_width = 105.5; //[52.75:211:0.1]
display_height = 67.2; //[33.6:134.4:0.1]
display_thickness = 3.4; //[1.7:6.8:0.1]
aperture_min_x = -50; //[-100:0:0.1]
aperture_min_y = -26.5; //[-67.2:0:0.1]
aperture_max_x = 50; //[0:100:0.1]
aperture_max_y = 31.5; //[0:67.2:0.1]
aperture_depth = 0.5; //[0.2:3.4:0.1]
touchscreen_min_x = -52.75; //[-105.5:0:0.1]
touchscreen_min_y = -31.5; //[-67.2:0:0.1]
touchscreen_max_x = 52.75; //[0:105.5:0.1]
touchscreen_max_y = 33.5; //[0:67.2:0.1]
touchscreen_thickness = 1; //[0.3:2.5:0.1]
touchscreen_enabled = 1; //[0:1:1]
pcb_width = 105; //[52.5:210:0.1]
pcb_height = 66.7; //[33.35:133.4:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
display_pcb_offset_x = 0; //[-20:20:0.1]
display_pcb_offset_y = 0; //[-20:20:0.1]
display_pcb_offset_z = 0; //[-10:20:0.1]
pcb_offset_gap = 2; //[0:10:0.1]
bottom_conn_min_x = 0; //[-52.75:52.75:0.1]
bottom_conn_min_y = -34.5; //[-67.2:0:0.1]
bottom_conn_max_x = 12; //[-52.75:52.75:0.1]
bottom_conn_max_y = -31.5; //[-67.2:0:0.1]
bottom_connector_thickness = 2.2; //[1:6:0.1]
overlap = 1; //[0.5:2:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Display module with detailed geometry
module display() {
  color([0.85, 0.85, 0.8]) {
    // Display body with aperture cutout
    difference() {
      cube([display_width, display_height, display_thickness], center=true);
      translate([aperture_min_x, aperture_min_y, display_thickness/2 - aperture_depth])
        cube([aperture_max_x - aperture_min_x, aperture_max_y - aperture_min_y, aperture_depth + eps], center=false);
    }
    
    // Touchscreen layer
    if (touchscreen_enabled) {
      translate([touchscreen_min_x, touchscreen_min_y, display_thickness/2 - overlap])
        cube([touchscreen_max_x - touchscreen_min_x, touchscreen_max_y - touchscreen_min_y, touchscreen_thickness], center=false);
    }
    
    // PCB offset gap
    translate([0, 0, -display_thickness/2 - pcb_offset_gap/2 + overlap])
      cube([display_width - 1, display_height - 1, pcb_offset_gap], center=true);
    
    // PCB block
    translate([display_pcb_offset_x, display_pcb_offset_y, -display_thickness/2 - pcb_offset_gap - pcb_thickness/2 + overlap + display_pcb_offset_z])
      cube([pcb_width, pcb_height, pcb_thickness], center=true);
    
    // Bottom connector region
    translate([bottom_conn_min_x, bottom_conn_min_y, -display_thickness/2 - bottom_connector_thickness + overlap])
      cube([bottom_conn_max_x - bottom_conn_min_x, bottom_conn_max_y - bottom_conn_min_y, bottom_connector_thickness], center=false);
  }
}

// Assembly
module assembly() {
  display();
}

assembly();