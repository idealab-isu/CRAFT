// Parameters
tape_length = 100; //[50:200:1]
tape_width = 50; //[25:100:1]
tape_thickness = 0.08; //[0.04:0.16:0.01]
corner_radius = 1.0; //[0.5:2.0:0.1]
adhesive_thickness = 0.03; //[0.01:0.08:0.01]
edge_chamfer = 0.2; //[0.05:0.6:0.05]
overlap = 0.5; //[0.2:1.5:0.1]
texture_depth = 0.01; //[0.0:0.03:0.005]
texture_pitch_x = 10; //[5:20:1]
texture_pitch_y = 10; //[5:20:1]
texture_radius = 1.2; //[0.5:2.5:0.1]

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

module corner_round(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=tape_thickness, center=true);
}

module adhesive_layer() {
  translate([0, 0, -tape_thickness/2 - (adhesive_thickness + overlap)/2 + overlap])
    cube([tape_length, tape_width, adhesive_thickness + overlap], center=true);
}

module edge_chamfer_x(pos) {
  translate([pos * (tape_length/2 - edge_chamfer), 0, -adhesive_thickness/2])
    rotate([0, 45, 0])
      cube([edge_chamfer*2, tape_width + edge_chamfer*2, tape_thickness + adhesive_thickness + overlap], center=true);
}

module edge_chamfer_y(pos) {
  translate([0, pos * (tape_width/2 - edge_chamfer), -adhesive_thickness/2])
    rotate([45, 0, 0])
      cube([tape_length + edge_chamfer*2, edge_chamfer*2, tape_thickness + adhesive_thickness + overlap], center=true);
}

module surface_texture_dimple(x, y) {
  translate([x * texture_pitch_x, y * texture_pitch_y, tape_thickness/2 + texture_radius - texture_depth])
    sphere(r=texture_radius, center=true);
}

// Operations
module tape_thickness() {
  union() {
    rounded_corners();
    corner_round(-tape_length/2 + corner_radius, tape_width/2 - corner_radius);
    corner_round(tape_length/2 - corner_radius, tape_width/2 - corner_radius);
    corner_round(-tape_length/2 + corner_radius, -tape_width/2 + corner_radius);
    corner_round(tape_length/2 - corner_radius, -tape_width/2 + corner_radius);
  }
}

module surface_texture() {
  union() {
    surface_texture_dimple(-1, -1);
    surface_texture_dimple(0, -1);
    surface_texture_dimple(1, -1);
    surface_texture_dimple(-1, 0);
    surface_texture_dimple(0, 0);
    surface_texture_dimple(1, 0);
    surface_texture_dimple(-1, 1);
    surface_texture_dimple(0, 1);
    surface_texture_dimple(1, 1);
  }
}

module tape_with_adhesive() {
  union() {
    tape_thickness();
    adhesive_layer();
  }
}

module tape_with_chamfer() {
  difference() {
    tape_with_adhesive();
    edge_chamfer_x(1);
    edge_chamfer_x(-1);
    edge_chamfer_y(1);
    edge_chamfer_y(-1);
  }
}

module tape_final() {
  difference() {
    tape_with_chamfer();
    surface_texture();
  }
}

// Final output
color([0.85, 0.85, 0.8]) // Off-white for aluminum foil tape
tape_final();