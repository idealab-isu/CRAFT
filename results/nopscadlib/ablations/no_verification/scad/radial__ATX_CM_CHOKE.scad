// Parameters
outer_radius = 17.4; //[8.7:34.8:0.1]
inner_radius = 11.4; //[5.7:22.8:0.1]
height = 9; //[4.5:18:0.1]
wall_thickness = 0.5; //[0.25:1:0.05]
overlap = 1; //[0.5:2:0.1]
chamfer_size = 1; //[0.5:2:0.1]
axis_marker_radius = 1.2; //[0.6:2.4:0.1]
axis_marker_height = 2; //[1:4:0.1]

// Base Shapes
module revolved_main_body() {
  color("Silver")
  cylinder(r=outer_radius, h=height, center=true);
}

module inner_bore() {
  cylinder(r=inner_radius, h=height + 2*overlap, center=true);
}

module wall_shell_outer() {
  cylinder(r=inner_radius + wall_thickness, h=height, center=true);
}

module wall_shell_inner_void() {
  cylinder(r=inner_radius, h=height + 2*overlap, center=true);
}

module edge_fillet_chamfer() {
  rotate_extrude() {
    polygon(points=[
      [outer_radius - chamfer_size, height/2 - chamfer_size],
      [outer_radius, height/2 - chamfer_size],
      [outer_radius, height/2]
    ]);
  }
}

module reference_axis_marker() {
  color("DimGray")
  translate([0, 0, height/2 + axis_marker_height/2 - overlap])
  cylinder(r=axis_marker_radius, h=axis_marker_height, center=true);
}

// Operations
module wall_shell() {
  difference() {
    wall_shell_outer();
    wall_shell_inner_void();
  }
}

module main_body_with_bore() {
  difference() {
    revolved_main_body();
    inner_bore();
  }
}

module body_plus_shell() {
  union() {
    main_body_with_bore();
    wall_shell();
  }
}

module body_plus_shell_plus_chamfer() {
  union() {
    body_plus_shell();
    edge_fillet_chamfer();
  }
}

module complete_model() {
  union() {
    body_plus_shell_plus_chamfer();
    reference_axis_marker();
  }
}

// Final Output
complete_model();