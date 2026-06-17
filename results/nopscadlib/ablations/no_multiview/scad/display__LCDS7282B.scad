// Parameters
width_mm = 73.6; //[36.8:147.2:0.1]
height_mm = 28.7; //[14.35:57.4:0.1]
display_thickness_mm = 5; //[2.5:10:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
aperture_margin_mm = 2; //[1:6:0.1]
corner_radius_mm = 0.5; //[0:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
aperture_cut_depth_mm = 1.5; //[0.5:4:0.1]
pcb_enabled = 1; //[0:1:1]

// Display module with viewing aperture
module display() {
  color([0.85, 0.85, 0.8]) { // Off-white for display
    difference() {
      // Main display body
      cube([width_mm, height_mm, display_thickness_mm], center=true);
      // Viewing aperture cutout
      translate([0, 0, display_thickness_mm/2 - aperture_cut_depth_mm/2])
        cube([width_mm - 2*aperture_margin_mm, height_mm - 2*aperture_margin_mm, aperture_cut_depth_mm + overlap_mm], center=true);
    }
  }
}

// PCB/backing plate
module pcb_backing_plate() {
  if (pcb_enabled) {
    color([0.0, 0.4, 0.2]) { // Green for PCB
      translate([0, 0, -display_thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm])
        cube([width_mm, height_mm, pcb_thickness_mm], center=true);
    }
  }
}

// Assembly of display and PCB
module assembly() {
  display();
  pcb_backing_plate();
}

// Final assembly call
assembly();