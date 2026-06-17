// Parameters
pipe_outer_diameter = 125; //[90:200:0.5]
wall_thickness = 3.2; //[1.6:6.4:0.1]
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 45; //[25:90:1]
fitting_wall_extra = 2.5; //[1:6:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
socket_step_length = 12; //[5:25:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe segment
    cylinder(h=length_mm, r=pipe_outer_diameter/2, center=false);

    // Hollow bore
    translate([0, 0, -overlap])
      cylinder(h=length_mm + 2*overlap, r=pipe_outer_diameter/2 - wall_thickness, center=false);

    if (include_end_fitting) {
      // End fitting outer
      translate([0, 0, length_mm - fitting_length])
        cylinder(h=fitting_length, r=pipe_outer_diameter/2 + fitting_wall_extra, center=false);

      // End fitting socket void
      translate([0, 0, length_mm - fitting_length - overlap])
        cylinder(h=fitting_length + 2*overlap, r=pipe_outer_diameter/2 + socket_clearance, center=false);

      // End fitting stop void
      translate([0, 0, length_mm - socket_step_length - overlap])
        cylinder(h=socket_step_length + 2*overlap, r=pipe_outer_diameter/2 - wall_thickness, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();