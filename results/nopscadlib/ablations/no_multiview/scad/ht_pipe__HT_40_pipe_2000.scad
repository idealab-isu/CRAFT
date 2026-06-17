// Parameters
length_mm = 2000; //[1000:4000:10]
pipe_od_mm = 40; //[32:80:1]
wall_thickness_mm = 1.8; //[1:4:0.1]
fitting_length_mm = 55; //[30:120:1]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
fitting_id_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_wall_extra_mm, center=false);
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_id_clearance_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();