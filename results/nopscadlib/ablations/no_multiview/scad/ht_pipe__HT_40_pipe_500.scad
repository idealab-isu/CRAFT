// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 500; //[250:1000:10]
ht40_outer_diameter = 40; //[30:60:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
fitting_length = 35; //[20:70:1]
fitting_outer_diameter = 46; //[40:70:1]
fitting_wall_thickness = 2.5; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=ht40_outer_diameter/2, center=false);
        translate([0, 0, ht40_wall_thickness])
          cylinder(h=length_mm, r=ht40_outer_diameter/2 - ht40_wall_thickness, center=false);
      }
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        translate([0, 0, length_mm - overlap_mm + fitting_wall_thickness])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2 - fitting_wall_thickness, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();