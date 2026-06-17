// Parameters
width_mm = 71.3; //[35.65:142.6:0.1]
height_mm = 24.3; //[12.15:48.6:0.1]
thickness_mm = 8; //[4:16:0.1]
include_pcb = 1; //[0:1:1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_overlap_mm = 1; //[0.5:2:0.1]
include_aperture = 1; //[0:1:1]
aperture_width_mm = 64; //[32:70:0.1]
aperture_height_mm = 14; //[7:22:0.1]
aperture_depth_mm = 1.2; //[0.5:3:0.1]
hole_cut_extra_mm = 0.5; //[0.2:2:0.1]
include_mounting_features = 0; //[0:1:1]
mounting_hole_diameter_mm = 3.2; //[0:6.4:0.1]
mounting_hole_edge_offset_x_mm = 2.5; //[1:10:0.1]
mounting_hole_edge_offset_y_mm = 2.5; //[1:10:0.1]
display_window_thickness_mm = 0.8; //[0.3:2:0.1]
display_window_overlap_mm = 0.6; //[0.3:1.5:0.1]

// Display module - complete geometry
module display() {
  color([0.85, 0.85, 0.8]) {
    // Main body
    cube([width_mm, height_mm, thickness_mm], center=true);
    
    // PCB backing plate
    if (include_pcb) {
      translate([0, 0, -thickness_mm/2 - pcb_thickness_mm/2 + pcb_overlap_mm])
        cube([width_mm, height_mm, pcb_thickness_mm], center=true);
    }
    
    // Active area aperture
    if (include_aperture) {
      translate([0, 0, thickness_mm/2 - aperture_depth_mm/2 + hole_cut_extra_mm/2])
        cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm + hole_cut_extra_mm], center=true);
    }
    
    // Display window
    translate([0, 0, thickness_mm/2 - display_window_thickness_mm/2 - display_window_overlap_mm])
      cube([aperture_width_mm, aperture_height_mm, display_window_thickness_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  // Placeholder for additional components or modifications
  // Currently, it is the same as the display module
  display();
}

// Assembly
module assembly() {
  display();
  mod();
}

assembly();