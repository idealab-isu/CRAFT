// Parameters
outer_diameter = 95; //[50:190:1]
inner_diameter = 25; //[12.5:50:1]
roll_width = 18; //[9:36:1]
tape_thickness = 0.05; //[0.02:0.2:0.01]
core_wall_thickness = 2; //[1:4:0.5]
overlap = 1; //[0.5:2:0.5]
flap_length = 22; //[10:44:1]
flap_width_factor = 0.85; //[0.5:1:0.05]

// Base Shapes
module tape_roll_body() {
  cylinder(r=outer_diameter/2, h=roll_width, center=true);
}

module inner_core_hole() {
  cylinder(r=inner_diameter/2, h=roll_width + 2*overlap, center=true);
}

module cardboard_core_outer() {
  cylinder(r=inner_diameter/2 + core_wall_thickness, h=roll_width, center=true);
}

module cardboard_core_inner_void() {
  cylinder(r=inner_diameter/2, h=roll_width + 2*overlap, center=true);
}

module tape_end_flap() {
  translate([outer_diameter/2 + flap_length/2 - overlap, 0, roll_width/2 - max(tape_thickness, 0.5)/2])
    cube([flap_length, roll_width*flap_width_factor, max(tape_thickness, 0.5)], center=true);
}

// Operations
module tape_band_thickness() {
  difference() {
    tape_roll_body();
    inner_core_hole();
  }
}

module cardboard_core_insert() {
  difference() {
    cardboard_core_outer();
    cardboard_core_inner_void();
  }
}

module outer_edge_faces() {
  union() {
    tape_band_thickness();
    cardboard_core_insert();
  }
}

module tape_roll_complete() {
  union() {
    outer_edge_faces();
    tape_end_flap();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for tape
tape_roll_complete();