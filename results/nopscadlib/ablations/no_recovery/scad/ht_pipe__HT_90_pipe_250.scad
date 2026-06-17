// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 90; //[50:180:1]
length_mm = 250; //[125:500:1]
end_fitting = 1; //[0:1:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 35; //[15:70:1]
fitting_wall_extra = 2.0; //[0.5:5.0:0.1]
fitting_od_extra = 8; //[2:20:1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe Body
    difference() {
      cylinder(r=nominal_diameter/2, h=length_mm - (end_fitting * fitting_length), center=false);
      translate([0, 0, pipe_wall])
        cylinder(r=nominal_diameter/2 - pipe_wall, h=length_mm - (end_fitting * fitting_length) + overlap, center=false);
    }
    
    // Integrated End Fitting
    if (end_fitting == 1) {
      difference() {
        translate([0, 0, length_mm - (end_fitting * fitting_length) - overlap])
          cylinder(r=(nominal_diameter + fitting_od_extra)/2, h=end_fitting * fitting_length, center=false);
        translate([0, 0, length_mm - (end_fitting * fitting_length) - overlap + (pipe_wall + fitting_wall_extra)])
          cylinder(r=nominal_diameter/2 - (pipe_wall + fitting_wall_extra), h=end_fitting * fitting_length + overlap, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();