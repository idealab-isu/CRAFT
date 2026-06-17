// Parameters
width_mm = 71.3; //[35.65:142.6:0.1]
height_mm = 24.3; //[12.15:48.6:0.1]
thickness_mm = 8.0; //[4.0:16.0:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
aperture_enabled = 1; //[0:1:1]
aperture_margin_mm = 3.0; //[1.5:6.0:0.1]
mounting_holes_enabled = 1; //[0:1:1]
mounting_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
corner_radius_mm = 0.5; //[0.25:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
aperture_depth_mm = 2.0; //[0.8:4.0:0.1]
aperture_extra_mm = 0.2; //[0.1:1.0:0.1]
hole_edge_margin_mm = 2.5; //[1.5:5.0:0.1]

// Display module - complete geometry
module display() {
  color([0.0, 0.4, 0.2]) { // PCB green
    // Main body
    cube([width_mm, height_mm, thickness_mm], center=true);
    
    // PCB plate
    translate([0, 0, -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm])
      cube([width_mm, height_mm, pcb_thickness_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.0, 0.4, 0.2]) { // PCB green
    // Viewing aperture cutout
    if (aperture_enabled) {
      difference() {
        display();
        translate([0, 0, thickness_mm/2 - (aperture_depth_mm + aperture_extra_mm)/2])
          cube([width_mm - 2*aperture_margin_mm, height_mm - 2*aperture_margin_mm, aperture_depth_mm + aperture_extra_mm], center=true);
      }
    } else {
      display();
    }
    
    // Mounting holes
    if (mounting_holes_enabled) {
      difference() {
        display();
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (width_mm/2 - hole_edge_margin_mm - mounting_hole_diameter_mm/2),
                     y * (height_mm/2 - hole_edge_margin_mm - mounting_hole_diameter_mm/2),
                     -pcb_thickness_mm/2 + overlap_mm])
            cylinder(h=pcb_thickness_mm + thickness_mm + 2*overlap_mm, r=mounting_hole_diameter_mm/2, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();