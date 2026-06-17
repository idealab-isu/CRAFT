// Parameters
tape_length = 100; //[50:200:1]
tape_width = 50; //[25:100:1]
tape_thickness = 0.08; //[0.04:0.2:0.01]
corner_radius = 2; //[1:6:0.5]
edge_chamfer = 0.3; //[0.1:1:0.05]
texture_depth = 0.01; //[0.005:0.03:0.001]
texture_pitch = 6; //[3:12:0.5]
texture_bump_radius = 1.2; //[0.6:2.5:0.1]
texture_margin = 4; //[2:10:0.5]
overlap = 0.5; //[0.2:2:0.1]

// Base shapes
module tape_sheet() {
  cube([tape_length, tape_width, tape_thickness], center=true);
}

module rounded_corners() {
  linear_extrude(height=tape_thickness, center=true) {
    polygon(points=[
      [-tape_length/2 + corner_radius, -tape_width/2],
      [tape_length/2 - corner_radius, -tape_width/2],
      [tape_length/2, -tape_width/2 + corner_radius],
      [tape_length/2, tape_width/2 - corner_radius],
      [tape_length/2 - corner_radius, tape_width/2],
      [-tape_length/2 + corner_radius, tape_width/2],
      [-tape_length/2, tape_width/2 - corner_radius],
      [-tape_length/2, -tape_width/2 + corner_radius]
    ]);
  }
}

module edge_chamfer() {
  cube([tape_length + 2*edge_chamfer, tape_width + 2*edge_chamfer, tape_thickness + 2*edge_chamfer], center=true);
}

module surface_texture_bump(pos_x, pos_y) {
  translate([pos_x, pos_y, tape_thickness/2 - texture_depth + overlap])
    sphere(r=texture_bump_radius, center=true);
}

// Operations
module tape_thickness() {
  intersection() {
    tape_sheet();
    rounded_corners();
  }
}

module surface_texture() {
  union() {
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*0, -tape_width/2 + texture_margin + texture_pitch*0);
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*1, -tape_width/2 + texture_margin + texture_pitch*0.5);
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*2, -tape_width/2 + texture_margin + texture_pitch*0);
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*0.5, -tape_width/2 + texture_margin + texture_pitch*1.5);
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*1.5, -tape_width/2 + texture_margin + texture_pitch*1.5);
    surface_texture_bump(-tape_length/2 + texture_margin + texture_pitch*2.5, -tape_width/2 + texture_margin + texture_pitch*1.5);
  }
}

// Final output
color("Silver") {
  union() {
    difference() {
      tape_thickness();
      edge_chamfer();
    }
    surface_texture();
  }
}