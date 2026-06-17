// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 10; //[5:20:1]
chamfer_size = 1; //[0.5:3:0.5]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
hole_clearance_z = 1; //[0.5:2:0.5]

// Main module
module final_plate() {
  difference() {
    intersection() {
      intersection() {
        // Base sheet with rounded corners
        linear_extrude(height = sheet_thickness, center = true) {
          offset(r = corner_radius) {
            square([sheet_length - 2 * corner_radius, sheet_width - 2 * corner_radius], center = true);
          }
        }
        // Chamfered edges
        rotate([45, 45, 0]) {
          cube([sheet_length + 2 * chamfer_size, sheet_width + 2 * chamfer_size, sheet_thickness + 2 * chamfer_size], center = true);
        }
      }
    }
    // Mounting holes
    union() {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (sheet_length / 2 - hole_edge_margin), y * (sheet_width / 2 - hole_edge_margin), 0]) {
          cylinder(r = hole_diameter / 2, h = sheet_thickness + 2 * hole_clearance_z, center = true);
        }
      }
    }
  }
}

// Render the final plate
color("Silver") final_plate();