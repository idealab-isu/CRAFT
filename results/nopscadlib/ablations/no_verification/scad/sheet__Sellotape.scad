// Parameters
tape_outer_diameter = 95; //[50:190:1]
core_inner_diameter = 76; //[40:152:1]
roll_width = 24; //[12:48:1]
core_wall_thickness = 2; //[1:6:0.5]
tape_radial_thickness = 8; //[3:20:1]
chamfer_size = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]
flap_length = 18; //[8:40:1]
flap_thickness = 0.8; //[0.4:2:0.1]
flap_width_margin = 1; //[0.5:4:0.5]

// Base Shapes
module tape_roll_body() {
  cylinder(r=tape_outer_diameter/2, h=roll_width, center=true);
}

module core_hole() {
  cylinder(r=core_inner_diameter/2, h=roll_width + 2*overlap, center=true);
}

module core_outer_cyl() {
  cylinder(r=core_inner_diameter/2 + core_wall_thickness, h=roll_width, center=true);
}

module tape_inner_void() {
  cylinder(r=tape_outer_diameter/2 - tape_radial_thickness, h=roll_width + 2*overlap, center=true);
}

module chamfer_top_ring() {
  translate([0, 0, roll_width/2 - chamfer_size/2])
    cylinder(r=tape_outer_diameter/2, h=chamfer_size, center=true);
}

module chamfer_bottom_ring() {
  translate([0, 0, -roll_width/2 + chamfer_size/2])
    cylinder(r=tape_outer_diameter/2, h=chamfer_size, center=true);
}

module chamfer_top_inner_cut() {
  translate([0, 0, roll_width/2 - chamfer_size/2])
    cylinder(r=tape_outer_diameter/2 - chamfer_size, h=chamfer_size + 2*overlap, center=true);
}

module chamfer_bottom_inner_cut() {
  translate([0, 0, -roll_width/2 + chamfer_size/2])
    cylinder(r=tape_outer_diameter/2 - chamfer_size, h=chamfer_size + 2*overlap, center=true);
}

module tape_end_flap() {
  translate([tape_outer_diameter/2 + flap_length/2 - overlap, 0, 0])
    cube([flap_length, flap_thickness, roll_width - 2*flap_width_margin], center=true);
}

// Operations
module core_wall() {
  difference() {
    core_outer_cyl();
    core_hole();
  }
}

module tape_body_ring() {
  difference() {
    tape_roll_body();
    tape_inner_void();
  }
}

module tape_edge_chamfers() {
  difference() {
    tape_body_ring();
    chamfer_top_inner_cut();
    chamfer_bottom_inner_cut();
  }
}

module tape_roll_complete() {
  union() {
    tape_edge_chamfers();
    core_wall();
    tape_end_flap();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for tape
tape_roll_complete();