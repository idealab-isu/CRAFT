// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 10; //[5:20:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_inset = 1; //[0.5:2:0.1]
chamfer_depth = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Rounded-rectangle prism (single connected solid)
module rounded_plate(L, W, T, R) {
  R2 = min(R, min(L, W)/2);
  linear_extrude(height = T, center = true, convexity = 10)
    offset(r = R2)
      square([L - 2*R2, W - 2*R2], center = true);
}

module acrylic_sheet() {
  // Acrylic-like appearance: transparent/translucent
  color([0.85, 0.95, 1.0, 0.25])
  difference() {
    // Main sheet with rounded corners (ONE solid)
    rounded_plate(sheet_length, sheet_width, sheet_thickness, corner_radius);

    // Mounting holes (through)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (sheet_length/2 - hole_edge_offset),
                 y * (sheet_width/2 - hole_edge_offset),
                 0])
        cylinder(h = sheet_thickness + 2*overlap, r = hole_diameter/2, center = true);
    }

    // Shallow top recess to suggest edge chamfer (keeps one connected solid)
    translate([0, 0, sheet_thickness/2 - chamfer_depth/2])
      rounded_plate(sheet_length - 2*chamfer_inset,
                    sheet_width  - 2*chamfer_inset,
                    chamfer_depth + 2*overlap,
                    max(corner_radius - chamfer_inset, 0));
  }
}

acrylic_sheet();