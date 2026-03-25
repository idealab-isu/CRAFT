// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[5:20:1]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1;   //[0.5:3:0.25]
overlap = 1;        //[0.5:2:0.5]

$fn = 96;

// 2D rounded rectangle (robust, non-Minkowski 3D)
module rounded_rect_2d(L, W, R) {
  R2 = min(R, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R2), sy*(W/2 - R2)])
        circle(r = R2);
  }
}

// Main sheet (single connected solid)
module sheet_solid() {
  linear_extrude(height = sheet_thickness, center = true)
    rounded_rect_2d(sheet_length, sheet_width, corner_radius);
}

// Mounting holes (through)
module hole_at(x, y) {
  translate([x, y, 0])
    cylinder(h = sheet_thickness + 2*overlap, r = hole_diameter/2, center = true);
}

// Final part
module sheet_with_holes() {
  difference() {
    sheet_solid();

    xh = sheet_length/2 - hole_edge_offset;
    yh = sheet_width/2  - hole_edge_offset;

    hole_at(-xh,  yh);
    hole_at(-xh, -yh);
    hole_at( xh, -yh);
    hole_at( xh,  yh);
  }
}

color("Silver") sheet_with_holes();