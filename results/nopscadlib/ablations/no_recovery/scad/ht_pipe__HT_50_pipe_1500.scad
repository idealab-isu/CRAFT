// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 50; //[25:100:1]
length_mm = 1500; //[750:3000:10]
ht50_outer_diameter = 50; //[40:60:0.5]
ht50_wall_thickness = 1.8; //[1.0:3.6:0.1]
fitting_length = 45; //[25:90:1]
fitting_outer_diameter = 56; //[50:80:0.5]
fitting_wall_extra = 2.2; //[1.0:5.0:0.1]
fitting_stop_ring_length = 6; //[2:15:1]
fitting_stop_ring_thickness = 1.2; //[0.5:3.0:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false);
      translate([0, 0, ht50_wall_thickness])
        cylinder(h=length_mm, r=ht50_outer_diameter/2 - ht50_wall_thickness, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - overlap]) {
      difference() {
        cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        translate([0, 0, ht50_wall_thickness + fitting_wall_extra])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2 - (ht50_wall_thickness + fitting_wall_extra), center=false);
        translate([0, 0, fitting_length - fitting_stop_ring_length])
          cylinder(h=fitting_stop_ring_length, r=ht50_outer_diameter/2 - ht50_wall_thickness - fitting_stop_ring_thickness, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();