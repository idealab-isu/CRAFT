// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 125; //[60:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
clearance_mm = 0.5; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 70; //[35:140:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_stop_thickness_mm = 4; //[2:10:0.5]
fitting_stop_length_mm = 10; //[5:25:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow Tube Body
    difference() {
      cylinder(r=od_mm/2, h=length_mm, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(r=od_mm/2 - wall_thickness_mm, h=length_mm, center=false);
    }
    
    // End Fitting
    if (include_end_fitting) {
      union() {
        // End Fitting Shell
        difference() {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(r=od_mm/2 + fitting_wall_extra_mm, h=fitting_length_mm, center=false);
          translate([0, 0, length_mm - overlap_mm])
            cylinder(r=od_mm/2 + clearance_mm, h=fitting_length_mm, center=false);
        }
        
        // End Fitting Stop Ring
        difference() {
          translate([0, 0, length_mm - overlap_mm + fitting_length_mm - fitting_stop_length_mm])
            cylinder(r=od_mm/2 + clearance_mm + fitting_stop_thickness_mm, h=fitting_stop_length_mm, center=false);
          translate([0, 0, length_mm - overlap_mm + fitting_length_mm - fitting_stop_length_mm])
            cylinder(r=od_mm/2 + clearance_mm, h=fitting_stop_length_mm, center=false);
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