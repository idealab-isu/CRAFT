// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 125; //[60:250:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
ht125_outer_diameter = 125; //[110:140:0.5]
ht125_wall_thickness = 3.2; //[2:6:0.1]
fit_overlap = 1; //[0.5:2:0.1]
fitting_length = 35; //[15:70:1]
fitting_wall_extra = 2.5; //[1:6:0.1]
fitting_bore_extra = 1.0; //[0:3:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe segment
    difference() {
      cylinder(r=ht125_outer_diameter/2, h=length_mm, center=true);
      translate([0, 0, -fit_overlap])
        cylinder(r=ht125_outer_diameter/2 - ht125_wall_thickness, h=length_mm + 2*fit_overlap, center=true);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm/2 + fitting_length/2 - fit_overlap])
          cylinder(r=ht125_outer_diameter/2 + fitting_wall_extra, h=fitting_length, center=true);
        translate([0, 0, length_mm/2 + fitting_length/2 - fit_overlap])
          cylinder(r=ht125_outer_diameter/2 - ht125_wall_thickness + fitting_bore_extra, h=fitting_length + 2*fit_overlap, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();