// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 5; //[2:15:0.5]
mount_hole_radius = 3; //[1.5:8:0.5]
mount_hole_edge_offset = 12; //[6:30:1]
texture_depth = 0.3; //[0.1:1:0.1]
texture_pitch = 12; //[6:30:1]
texture_bump_radius = 3; //[1:8:0.5]
texture_margin = 10; //[5:25:1]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module silicone_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner(position) {
  intersection() {
    translate(position)
      cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
    translate(position)
      cube([corner_radius*2, corner_radius*2, sheet_thickness + 4*overlap], center=true);
  }
}

module mounting_hole(position) {
  translate(position)
    cylinder(r=mount_hole_radius, h=sheet_thickness + 4*overlap, center=true);
}

module texture_bump(position) {
  translate(position)
    cylinder(r=texture_bump_radius, h=texture_depth + 2*overlap, center=true);
}

module embossed_label() {
  translate([0, 0, sheet_thickness/2 - (sheet_thickness/10)/2 - overlap])
    cube([sheet_length/4, sheet_width/6, sheet_thickness/10], center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corner([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner([-(sheet_length/2 - corner_radius), sheet_width/2 - corner_radius, 0]);
    rounded_corner([-(sheet_length/2 - corner_radius), -(sheet_width/2 - corner_radius), 0]);
    rounded_corner([sheet_length/2 - corner_radius, -(sheet_width/2 - corner_radius), 0]);
  }
}

module sheet_with_rounded_corners() {
  hull() {
    rounded_corners_union();
    silicone_sheet_body();
  }
}

module surface_texture() {
  union() {
    for (x = [-texture_pitch, 0, texture_pitch])
      for (y = [-texture_pitch, 0, texture_pitch])
        texture_bump([x, y, sheet_thickness/2 - texture_depth/2 + overlap]);
  }
}

module mounting_holes() {
  union() {
    mounting_hole([-(sheet_length/2 - mount_hole_edge_offset), -(sheet_width/2 - mount_hole_edge_offset), 0]);
    mounting_hole([sheet_length/2 - mount_hole_edge_offset, -(sheet_width/2 - mount_hole_edge_offset), 0]);
    mounting_hole([sheet_length/2 - mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset, 0]);
    mounting_hole([-(sheet_length/2 - mount_hole_edge_offset), sheet_width/2 - mount_hole_edge_offset, 0]);
  }
}

module sheet_minus_holes() {
  difference() {
    sheet_with_rounded_corners();
    mounting_holes();
  }
}

module sheet_minus_holes_minus_texture() {
  difference() {
    sheet_minus_holes();
    surface_texture();
  }
}

// Final model
module complete_model() {
  union() {
    sheet_minus_holes_minus_texture();
    embossed_label();
  }
}

// Render the complete model
color([0.85, 0.85, 0.8]) // Silicone color
complete_model();