// Parameters
width_mm = 71.3; //[35.65:142.6:0.1]
height_mm = 24.3; //[12.15:48.6:0.1]
thickness_mm = 8.0; //[4.0:16.0:0.1]
aperture_margin_mm = 2.0; //[1.0:6.0:0.1]
aperture_depth_mm = 1.2; //[0.5:3.0:0.1]
window_thickness_mm = 0.8; //[0.4:2.0:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 1.0; //[0.5:4.0:0.1]
mount_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
mount_hole_edge_offset_mm = 2.5; //[1.0:6.0:0.1]
pin_header_pitch_mm = 2.54; //[1.27:5.08:0.01]
pin_count = 16; //[8:24:1]
pin_header_depth_mm = 3.0; //[1.5:8.0:0.1]
pin_header_height_mm = 3.0; //[1.5:8.0:0.1]
pin_header_side_margin_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Display module - complete geometry
module display() {
  color([0.0, 0.4, 0.2]) { // PCB green
    // Main body
    difference() {
      cube([width_mm, height_mm, thickness_mm], center=true);
      // Aperture cutout
      translate([0, 0, thickness_mm/2 - (aperture_depth_mm + overlap_mm)/2])
        cube([width_mm - 2*aperture_margin_mm, height_mm - 2*aperture_margin_mm, aperture_depth_mm + overlap_mm], center=true);
    }
    // Display aperture window
    translate([0, 0, thickness_mm/2 - aperture_depth_mm + window_thickness_mm/2 - overlap_mm])
      cube([width_mm - 2*aperture_margin_mm - 2*overlap_mm, height_mm - 2*aperture_margin_mm - 2*overlap_mm, window_thickness_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.1, 0.1, 0.6]) { // PCB blue
    // PCB backing plate with mounting holes
    difference() {
      translate([0, 0, -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm])
        cube([width_mm - 2*pcb_margin_mm, height_mm - 2*pcb_margin_mm, pcb_thickness_mm], center=true);
      // Mounting holes
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x*((width_mm - 2*pcb_margin_mm)/2 - mount_hole_edge_offset_mm), y*((height_mm - 2*pcb_margin_mm)/2 - mount_hole_edge_offset_mm), -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm])
            cylinder(r=mount_hole_diameter_mm/2, h=pcb_thickness_mm + overlap_mm*2, center=true);
    }
    // Pin header region
    translate([0, -(height_mm - 2*pcb_margin_mm)/2 + pin_header_depth_mm/2 - overlap_mm, -thickness_mm/2 - pcb_thickness_mm + pin_header_height_mm/2 + overlap_mm])
      cube([(pin_count - 1)*pin_header_pitch_mm + 2*pin_header_side_margin_mm, pin_header_depth_mm, pin_header_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  display();
  mod();
}

assembly();