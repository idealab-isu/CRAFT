// Parameters
length_mm = 150; //[75:300:1]
ht75_outer_diameter = 75; //[60:90:0.5]
ht75_wall_thickness = 2.2; //[1.1:4.4:0.1]
fitting_length = 25; //[12:50:1]
fitting_outer_diameter = 82; //[75:100:0.5]
fitting_wall_thickness = 3; //[1.5:6:0.1]
socket_depth = 18; //[8:35:1]
connection_overlap = 1; //[0.5:2:0.1]
clearance = 0.4; //[0.1:1:0.1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube wall
    difference() {
      cylinder(h=length_mm, r=ht75_outer_diameter/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht75_outer_diameter/2 - ht75_wall_thickness, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - connection_overlap]) {
      difference() {
        // End fitting shell
        difference() {
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
          translate([0, 0, 0])
            cylinder(h=fitting_length, r=fitting_outer_diameter/2 - fitting_wall_thickness, center=false);
        }
        // Socket void
        translate([0, 0, fitting_length - socket_depth])
          cylinder(h=socket_depth, r=ht75_outer_diameter/2 + clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();