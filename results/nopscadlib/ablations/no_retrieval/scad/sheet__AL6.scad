// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200;  //[100:400:1]
plate_thickness = 12; //[6:24:1]
chamfer_size = 1;   //[0.5:3:0.5]
corner_radius = 6; //[2:15:1]
hole_diameter = 10; //[4:20:1]
hole_edge_offset = 25; //[10:60:1]
hole_through_extra = 2; //[1:5:1]

$fn = 96;

// 2D rounded rectangle (outer profile)
module rounded_rect_2d(L, W, R) {
  R2 = min(R, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R2), sy*(W/2 - R2)])
        circle(r=R2);
  }
}

// Main tooling plate: single connected solid with rounded corners and top chamfer
module tooling_plate() {
  R = min(corner_radius, min(plate_length, plate_width)/2);
  c = min(chamfer_size, plate_thickness/2);

  // Build as a hull between a larger bottom profile and a slightly smaller top profile
  // to create a continuous chamfer around the perimeter.
  color("Silver")
  hull() {
    translate([0, 0, -plate_thickness/2])
      linear_extrude(height=0.01, center=false)
        rounded_rect_2d(plate_length, plate_width, R);

    translate([0, 0,  plate_thickness/2 - c])
      linear_extrude(height=0.01, center=false)
        rounded_rect_2d(plate_length - 2*c, plate_width - 2*c, max(R - c, 0));
  }
}

// Mounting holes (through)
module mounting_holes() {
  for (x_mult = [-1, 1], y_mult = [-1, 1]) {
    translate([x_mult * (plate_length/2 - hole_edge_offset),
               y_mult * (plate_width/2 - hole_edge_offset),
               0])
      cylinder(r=hole_diameter/2, h=plate_thickness + hole_through_extra, center=true);
  }
}

// Final assembly
difference() {
  tooling_plate();
  mounting_holes();
}