// Parameters
length_mm = 1000; //[500:2000:10]
pipe_od_mm = 75; //[60:90:1]
wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 55; //[30:110:1]
fitting_od_scale = 1.18; //[1.05:1.4:0.01]
fitting_wall_extra_mm = 1.2; //[0.5:3:0.1]
fitting_overlap_mm = 1; //[0.5:2:0.1]
inner_clearance_mm = 0.3; //[0:1:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting main shell
      difference() {
        translate([0, 0, length_mm - fitting_overlap_mm])
          cylinder(h=fitting_length_mm, r=(pipe_od_mm*fitting_od_scale)/2, center=false);
        translate([0, 0, length_mm - fitting_overlap_mm])
          cylinder(h=fitting_length_mm, r=pipe_od_mm/2 - wall_thickness_mm + inner_clearance_mm, center=false);
      }
      
      // End fitting step shell
      difference() {
        translate([0, 0, length_mm - fitting_overlap_mm + fitting_length_mm*0.65])
          cylinder(h=fitting_length_mm*0.35, r=(pipe_od_mm*(fitting_od_scale - 0.06))/2, center=false);
        translate([0, 0, length_mm - fitting_overlap_mm + fitting_length_mm*0.65])
          cylinder(h=fitting_length_mm*0.35, r=pipe_od_mm/2 - (wall_thickness_mm + fitting_wall_extra_mm), center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();