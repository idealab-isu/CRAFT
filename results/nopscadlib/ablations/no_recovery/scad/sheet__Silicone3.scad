// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:4:0.5]
corner_radius = 0; //[0:20:1]
edge_chamfer = 0; //[0:2:0.25]

// Module for the silicone sheet with optional rounded corners and chamfered edges
module silicone_sheet() {
  color([0.85, 0.85, 0.8]) { // Off-white color for silicone
    // Base sheet
    difference() {
      // Main body
      cube([sheet_length, sheet_width, sheet_thickness], center=true);
      
      // Apply corner rounding if specified
      if (corner_radius > 0) {
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (sheet_length/2 - corner_radius), y * (sheet_width/2 - corner_radius), 0])
            cylinder(r=corner_radius, h=sheet_thickness, center=true);
        }
      }
      
      // Apply edge chamfer if specified
      if (edge_chamfer > 0) {
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (sheet_length/2 - edge_chamfer), y * (sheet_width/2 - edge_chamfer), 0])
            rotate([90, 0, 0])
            cylinder(r=edge_chamfer, h=sheet_thickness, center=true);
        }
      }
    }
  }
}

// Final output
silicone_sheet();