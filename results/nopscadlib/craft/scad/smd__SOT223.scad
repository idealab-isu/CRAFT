// Parameters
body_length = 6.5; //[3.25:13:0.1]
body_width = 3.5; //[1.75:7:0.1]
body_height = 1.6; //[0.8:3.2:0.05]
terminal_length = 0.8; //[0.4:1.6:0.05]
terminal_thickness = 0.12; //[0.05:0.3:0.01]
terminal_height = 1.2; //[0.6:1.6:0.05]
mark_length = 2.2; //[1.1:4.4:0.1]
mark_width = 1.2; //[0.6:2.4:0.1]
mark_thickness = 0.05; //[0.02:0.15:0.01]
fillet_radius = 0.25; //[0.1:0.6:0.05]
connect_overlap = 0.8; //[0.5:2:0.1]

// Main body
module main_body() {
  color([0.85, 0.85, 0.8]) // Off-white for SMD body
  cube([body_length, body_width, body_height], center=true);
}

// Terminal
module terminal() {
  color([0.72, 0.45, 0.2]) // Copper color for terminals
  cube([terminal_length + connect_overlap, body_width + 2*terminal_thickness, terminal_height], center=true);
}

// Top marking
module top_marking() {
  color([0.1, 0.1, 0.6]) // Blue for marking
  cube([mark_length, mark_width, mark_thickness], center=true);
}

// Edge fillet sphere
module edge_fillet_sphere() {
  sphere(r=fillet_radius, center=true);
}

// Assemble the component
module smd_component() {
  union() {
    // Main body
    main_body();
    
    // Terminals
    translate([-body_length/2 + (terminal_length + connect_overlap)/2, 0, -body_height/2 + terminal_height/2])
      terminal();
    translate([body_length/2 - (terminal_length + connect_overlap)/2, 0, -body_height/2 + terminal_height/2])
      terminal();
    
    // Top marking
    translate([0, 0, body_height/2 + mark_thickness/2 - connect_overlap/4])
      top_marking();
  }
}

// Final output with edge fillet
minkowski() {
  smd_component();
  edge_fillet_sphere();
}