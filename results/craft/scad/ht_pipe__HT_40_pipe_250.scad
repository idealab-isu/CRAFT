// Parameters
nominal_diameter = 40; //[20:80:1]
length_mm = 250; //[125:500:1]
ht40_outer_diameter = 40; //[20:80:0.5]
wall_thickness = 1.8; //[0.9:3.6:0.1]
include_end_fitting = 1; //[0:1:1]
epsilon_overlap = 1; //[0.5:2:0.1]
fitting_length = 35; //[18:70:1]
fitting_od_extra = 4; //[2:10:0.5]
fitting_socket_depth = 25; //[12:50:1]
fitting_socket_clearance = 0.4; //[0.1:1.2:0.1]
fitting_stop_thickness = 3; //[1.5:6:0.5]
fitting_chamfer_length = 2; //[1:6:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(r=ht40_outer_diameter/2, h=length_mm, center=false);
      translate([0, 0, wall_thickness])
        cylinder(r=ht40_outer_diameter/2 - wall_thickness, h=length_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm - epsilon_overlap]) {
        difference() {
          cylinder(r=(ht40_outer_diameter + fitting_od_extra)/2, h=fitting_length, center=false);
          union() {
            cylinder(r=ht40_outer_diameter/2 + fitting_socket_clearance, h=fitting_socket_depth, center=false);
            cylinder(r=ht40_outer_diameter/2 - wall_thickness, h=fitting_length + epsilon_overlap, center=false);
            translate([0, 0, fitting_socket_depth])
              cylinder(r1=ht40_outer_diameter/2 + fitting_socket_clearance, 
                       r2=ht40_outer_diameter/2 + fitting_socket_clearance + fitting_chamfer_length, 
                       h=fitting_chamfer_length, center=false);
          }
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();