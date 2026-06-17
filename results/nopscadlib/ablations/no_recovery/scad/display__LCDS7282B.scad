// Parameters
width_mm = 73.6; //[36.8:147.2:0.1]
height_mm = 28.7; //[14.35:57.4:0.1]
thickness_mm = 3; //[1.5:6:0.1]
aperture_margin_mm = 2; //[1:4:0.1]
aperture_depth_mm = 1.2; //[0.6:2.4:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_offset_z_mm = 0; //[-2:2:0.1]
mount_hole_diameter_mm = 2.5; //[1.25:5:0.1]
mount_hole_edge_offset_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Display module with detailed geometry
module display() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Display body
      translate([0, 0, 0])
        cube([width_mm, height_mm, thickness_mm], center=true);
      // Front viewing area aperture
      translate([0, 0, thickness_mm/2 - aperture_depth_mm/2])
        cube([width_mm - 2*aperture_margin_mm, height_mm - 2*aperture_margin_mm, aperture_depth_mm + overlap_mm], center=true);
    }
  }
}

// Mod module with detailed geometry
module mod() {
  color([0.0, 0.4, 0.2]) {
    union() {
      // PCB backing plate
      translate([0, 0, -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm + pcb_offset_z_mm])
        cube([width_mm, height_mm, pcb_thickness_mm], center=true);
      // Mounting holes
      color("Black") {
        for (x = [-1, 1])
          for (y = [-1, 1])
            translate([x * (width_mm/2 - mount_hole_edge_offset_mm), y * (height_mm/2 - mount_hole_edge_offset_mm), -pcb_thickness_mm/2 + pcb_offset_z_mm])
              cylinder(h=thickness_mm + pcb_thickness_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
      }
    }
  }
}

// Assembly of the display and mod
module assembly() {
  display();
  mod();
}

assembly();