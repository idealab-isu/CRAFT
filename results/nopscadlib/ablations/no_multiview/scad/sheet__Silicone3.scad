// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
edge_fillet_radius = 0.8; //[0.3:2:0.1]
texture_groove_width = 1.2; //[0.6:3:0.1]
texture_groove_depth = 0.25; //[0.1:0.8:0.05]
texture_groove_pitch = 12; //[6:30:1]
texture_groove_count = 9; //[3:25:1]
connect_overlap = 1; //[0.5:2:0.1]

// Base shapes
module silicone_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  linear_extrude(height=sheet_thickness, center=true) {
    polygon(points=[
      [sheet_length/2 - corner_radius, sheet_width/2],
      [-sheet_length/2 + corner_radius, sheet_width/2],
      [-sheet_length/2, sheet_width/2 - corner_radius],
      [-sheet_length/2, -sheet_width/2 + corner_radius],
      [-sheet_length/2 + corner_radius, -sheet_width/2],
      [sheet_length/2 - corner_radius, -sheet_width/2],
      [sheet_length/2, -sheet_width/2 + corner_radius],
      [sheet_length/2, sheet_width/2 - corner_radius]
    ]);
  }
}

module corner_round_sphere() {
  sphere(r=corner_radius, center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_radius, center=true);
}

module texture_groove(y_offset) {
  translate([0, y_offset, sheet_thickness/2 - texture_groove_depth/2])
    cube([sheet_length + 2*connect_overlap, texture_groove_width, texture_groove_depth + connect_overlap], center=true);
}

// Operations
module rounded_corners_minkowski() {
  minkowski() {
    rounded_corners();
    corner_round_sphere();
  }
}

module edge_chamfer_or_fillet() {
  minkowski() {
    rounded_corners_minkowski();
    edge_fillet_sphere();
  }
}

module surface_texture() {
  union() {
    for (i = [0 : texture_groove_count - 1]) {
      texture_groove((-((texture_groove_count-1)/2) + i) * texture_groove_pitch);
    }
  }
}

// Final output
module silicone_sheet_complete() {
  difference() {
    edge_chamfer_or_fillet();
    surface_texture();
  }
}

// Render the final silicone sheet
color([0.85, 0.85, 0.8]) // Off-white for silicone
silicone_sheet_complete();