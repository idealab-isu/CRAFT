// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[63:250:1]
length_mm = 2000; //[1000:4000:10]
wall_thickness_mm = 3.2; //[2:6.5:0.1]
od_mm = 125; //[63:250:1]
id_mm = 118.6; //[50:245:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_od_increase_mm = 8; //[3:20:0.5]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe Body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=id_mm/2, center=false);
    }
    
    // End Fitting
    difference() {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm, r=(od_mm + fitting_od_increase_mm)/2, center=false);
      translate([0, 0, length_mm - overlap_mm + (wall_thickness_mm + fitting_wall_extra_mm)])
        cylinder(h=fitting_length_mm, r=(id_mm/2) + wall_thickness_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();