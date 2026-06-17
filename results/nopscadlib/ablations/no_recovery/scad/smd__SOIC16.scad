// Parameters
body_length = 9.9; //[5:20:0.1]
body_width = 3.9; //[2:8:0.1]
body_height = 1.25; //[0.6:2.5:0.05]
overlap = 0.8; //[0.5:2:0.1]
placeholder_thickness = 0.01; //[0.001:0.1:0.001]

// SMD Package
module smd_body() {
  color([0.85, 0.85, 0.8]) // Off-white for SMD body
  cube([body_length, body_width, body_height], center=true);
}

module pin_1_mark() {
  color([0.7, 0.7, 0.7]) // Light gray for marking
  translate([0, 0, body_height/2 - placeholder_thickness/2])
    cube([body_length, body_width, placeholder_thickness], center=true);
}

module top_marking() {
  color([0.7, 0.7, 0.7]) // Light gray for marking
  translate([0, 0, body_height/2 - placeholder_thickness/2])
    cube([body_length, body_width, placeholder_thickness], center=true);
}

module edge_chamfer() {
  color([0.7, 0.7, 0.7]) // Light gray for chamfer
  cube([body_length, body_width, placeholder_thickness], center=true);
}

module terminal_metallization() {
  color([0.5, 0.5, 0.5]) // Darker gray for metallization
  translate([0, 0, -body_height/2 + placeholder_thickness/2])
    cube([body_length, body_width, placeholder_thickness], center=true);
}

// Complete SMD Package
module smd_complete() {
  union() {
    smd_body();
    pin_1_mark();
    top_marking();
    edge_chamfer();
    terminal_metallization();
  }
}

// Render the final SMD package
smd_complete();