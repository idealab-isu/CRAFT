// Parameters
overall_width_mm = 46.0; //[23.0:92.0:0.5]
overall_height_mm = 34.0; //[17.0:68.0:0.5]
display_thickness_mm = 2.5; //[1.5:5.0:0.25]
overall_thickness_mm = 6.0; //[3.0:12.0:0.25]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_xy_mm = 0.5; //[0.0:2.0:0.1]
pcb_offset_z_mm = 1.0; //[0.0:4.0:0.25]
active_area_width_mm = 28.0; //[14.0:56.0:0.5]
active_area_height_mm = 35.0; //[17.5:70.0:0.5]
bezel_frame_thickness_mm = 1.2; //[0.6:3.0:0.1]
bezel_border_mm = 3.0; //[1.0:8.0:0.25]
rear_clearance_height_mm = 3.0; //[1.0:8.0:0.25]
rear_clearance_margin_xy_mm = 1.0; //[0.0:4.0:0.25]
mount_hole_diameter_mm = 2.2; //[1.0:4.5:0.1]
mount_hole_edge_offset_mm = 3.0; //[1.5:6.0:0.25]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Display module
module display() {
  color([0.85, 0.85, 0.8]) {
    translate([0, 0, overall_thickness_mm/2 - bezel_frame_thickness_mm - display_thickness_mm/2 + overlap_mm])
      cube([overall_width_mm, overall_height_mm, display_thickness_mm], center=true);
  }
}

// Mod module
module mod() {
  color([0.0, 0.4, 0.2]) {
    // Rear clearance volume
    translate([0, 0, -overall_thickness_mm/2 + rear_clearance_height_mm/2])
      cube([overall_width_mm - 2*rear_clearance_margin_xy_mm, overall_height_mm - 2*rear_clearance_margin_xy_mm, rear_clearance_height_mm], center=true);
    
    // PCB body with drilled holes
    difference() {
      translate([0, 0, -overall_thickness_mm/2 + rear_clearance_height_mm + pcb_thickness_mm/2])
        cube([overall_width_mm - 2*pcb_margin_xy_mm, overall_height_mm - 2*pcb_margin_xy_mm, pcb_thickness_mm], center=true);
      
      // Mount holes
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * ((overall_width_mm - 2*pcb_margin_xy_mm)/2 - mount_hole_edge_offset_mm),
                   y * ((overall_height_mm - 2*pcb_margin_xy_mm)/2 - mount_hole_edge_offset_mm),
                   -overall_thickness_mm/2 + rear_clearance_height_mm + pcb_thickness_mm/2])
          cylinder(r=mount_hole_diameter_mm/2, h=pcb_thickness_mm + 2*overlap_mm, center=true);
      }
    }
    
    // Front bezel frame
    difference() {
      translate([0, 0, overall_thickness_mm/2 - bezel_frame_thickness_mm/2])
        cube([min(overall_width_mm, active_area_width_mm + 2*bezel_border_mm), min(overall_height_mm, active_area_height_mm + 2*bezel_border_mm), bezel_frame_thickness_mm], center=true);
      
      translate([0, 0, overall_thickness_mm/2 - bezel_frame_thickness_mm/2])
        cube([active_area_width_mm, active_area_height_mm, bezel_frame_thickness_mm + 2*overlap_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  display();
  mod();
}

assembly();