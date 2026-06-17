// Parameters
length_mm = 1000; //[500:2000:10]
ht50_outer_diameter = 50; //[40:80:1]
ht50_wall_thickness = 1.8; //[1:4:0.1]
fitting_length = 55; //[30:120:1]
fitting_outer_diameter = 58; //[52:90:1]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
fitting_stop_thickness = 3; //[1:8:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false);
        translate([0, 0, -overlap_mm])
          cylinder(h=length_mm + overlap_mm*2, r=ht50_outer_diameter/2 - ht50_wall_thickness, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - fitting_length - overlap_mm])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        translate([0, 0, length_mm - fitting_length - overlap_mm - overlap_mm])
          cylinder(h=fitting_length + overlap_mm*2, r=fitting_outer_diameter/2 - (ht50_wall_thickness + fitting_wall_extra), center=false);
        translate([0, 0, length_mm - fitting_stop_thickness - overlap_mm])
          cylinder(h=fitting_stop_thickness + overlap_mm*2, r=ht50_outer_diameter/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();