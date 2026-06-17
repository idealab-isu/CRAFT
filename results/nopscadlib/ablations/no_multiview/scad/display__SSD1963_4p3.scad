// Parameters
overall_width_mm = 105.5; //[52.75:211:0.1]
overall_height_mm = 67.2; //[33.6:134.4:0.1]
overall_thickness_mm = 3.4; //[1.7:6.8:0.1]
eps_mm = 0.2; //[0.05:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]
aperture_min_x_mm = -50; //[-100:0:0.1]
aperture_min_y_mm = -26.5; //[-67.2:0:0.1]
aperture_max_x_mm = 50; //[0:105.5:0.1]
aperture_max_y_mm = 31.5; //[0:67.2:0.1]
aperture_max_z_mm = 0.5; //[0.1:3.4:0.1]
touch_min_x_mm = -52.75; //[-105.5:0:0.1]
touch_min_y_mm = -31.5; //[-67.2:0:0.1]
touch_max_x_mm = 52.75; //[0:105.5:0.1]
touch_max_y_mm = 33.5; //[0:67.2:0.1]
touch_max_z_mm = 1; //[0:5:0.1]
pcb_enable = 1; //[0:1:1]
pcb_width_mm = 104.5; //[52.25:209:0.1]
pcb_height_mm = 66.2; //[33.1:132.4:0.1]
pcb_thickness_mm = 1.6; //[0:3.2:0.1]
pcb_offset_x_mm = 0; //[-10:10:0.1]
pcb_offset_y_mm = 0; //[-10:10:0.1]
pcb_offset_z_mm = 0; //[-5:5:0.1]
mounting_enable = 1; //[0:1:1]
mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_edge_margin_x_mm = 6; //[3:12:0.1]
mount_edge_margin_y_mm = 6; //[3:12:0.1]
thread_depth_or_threads_mm = 0; //[0:6:0.1]
connector_width_mm = 18; //[9:36:0.1]
connector_height_mm = 6; //[3:12:0.1]
connector_thickness_mm = 2; //[1:6:0.1]
connector_offset_y_from_bottom_mm = 4; //[0:15:0.1]

// Display module with detailed geometry
module display() {
  color([0.85, 0.85, 0.8]) {
    // Main body
    difference() {
      cube([overall_width_mm, overall_height_mm, overall_thickness_mm], center=true);
      
      // Aperture cutout
      translate([(aperture_min_x_mm + aperture_max_x_mm)/2,
                 (aperture_min_y_mm + aperture_max_y_mm)/2,
                 overall_thickness_mm/2 - (aperture_max_z_mm + eps_mm)/2 + eps_mm/2])
        cube([aperture_max_x_mm - aperture_min_x_mm,
              aperture_max_y_mm - aperture_min_y_mm,
              aperture_max_z_mm + eps_mm], center=true);
    }
    
    // Touch screen volume
    translate([(touch_min_x_mm + touch_max_x_mm)/2,
               (touch_min_y_mm + touch_max_y_mm)/2,
               overall_thickness_mm/2 + touch_max_z_mm/2 - overlap_mm])
      cube([touch_max_x_mm - touch_min_x_mm,
            touch_max_y_mm - touch_min_y_mm,
            touch_max_z_mm], center=true);
    
    // PCB volume
    if (pcb_enable) {
      translate([pcb_offset_x_mm,
                 pcb_offset_y_mm,
                 -overall_thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm + pcb_offset_z_mm])
        cube([pcb_width_mm, pcb_height_mm, pcb_thickness_mm], center=true);
    }
    
    // Connector or feature region
    translate([0,
               -overall_height_mm/2 + connector_offset_y_from_bottom_mm + connector_height_mm/2,
               -overall_thickness_mm/2 - connector_thickness_mm/2 + overlap_mm])
      cube([connector_width_mm, connector_height_mm, connector_thickness_mm], center=true);
    
    // Mounting holes
    if (mounting_enable) {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (overall_width_mm/2 - mount_edge_margin_x_mm),
                   y * (overall_height_mm/2 - mount_edge_margin_y_mm),
                   0])
          cylinder(r=mount_hole_diameter_mm/2,
                   h=overall_thickness_mm + thread_depth_or_threads_mm + 2*eps_mm,
                   center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  display();
}

assembly();