// Parameters
pipe_standard = 0; //[0:0:1]
nominal_size = 50; //[25:110:1]
length_mm = 1500; //[750:3000:10]
ht50_outer_diameter = 50; //[40:75:0.5]
ht50_wall_thickness = 1.8; //[1.0:3.5:0.1]
fitting_length = 45; //[25:90:1]
fitting_outer_diameter = 56; //[52:70:0.5]
fitting_wall_thickness = 2.5; //[1.5:5:0.1]
fitting_stop_ring_length = 6; //[3:15:0.5]
fitting_stop_ring_thickness = 1.5; //[0.8:4:0.1]
overlap = 1; //[0.5:2:0.1]

// Module for the hollow pipe body
module hollow_tube_body() {
  difference() {
    cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false);
    translate([0, 0, 0])
      cylinder(h=length_mm, r=ht50_outer_diameter/2 - ht50_wall_thickness, center=false);
  }
}

// Module for the end fitting
module end_fitting() {
  difference() {
    cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
    translate([0, 0, 0])
      cylinder(h=fitting_length, r=fitting_outer_diameter/2 - fitting_wall_thickness, center=false);
    translate([0, 0, fitting_length - fitting_stop_ring_length])
      cylinder(h=fitting_stop_ring_length, r=(fitting_outer_diameter/2 - fitting_wall_thickness) - fitting_stop_ring_thickness, center=false);
  }
}

// Module for the complete HT pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    union() {
      hollow_tube_body();
      translate([0, 0, length_mm - overlap]) end_fitting();
    }
  }
}

// Assembly module
module assembly() {
  ht_pipe();
}

// Call the assembly
assembly();