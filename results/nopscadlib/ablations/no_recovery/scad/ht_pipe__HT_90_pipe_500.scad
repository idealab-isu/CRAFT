// Parameters
nominal_diameter_mm = 90; //[50:160:1]
length_mm = 500; //[250:1000:1]
outer_diameter_mm = 90; //[50:160:0.5]
wall_thickness_mm = 2.7; //[1.5:6:0.1]
inner_diameter_mm = 84.6; //[40:155:0.5]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 55; //[30:120:1]
fitting_wall_extra_mm = 2.5; //[1:8:0.1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      translate([0, 0, 0])
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=false, $fn=64);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=inner_diameter_mm/2, center=false, $fn=64);
    }
    
    // End fitting (socket)
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=outer_diameter_mm/2 + fitting_wall_extra_mm, center=false, $fn=64);
        translate([0, 0, length_mm - 2*overlap_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=outer_diameter_mm/2 + socket_clearance_mm, center=false, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();