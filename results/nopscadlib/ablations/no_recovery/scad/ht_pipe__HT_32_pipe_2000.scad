// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size_mm = 32; //[16:64:1]
length_mm = 2000; //[1000:4000:10]
center = 0; //[0:1:1]
od_mm = 32; //[16:64:1]
wall_mm = 2.4; //[1.2:4.8:0.1]
id_mm = 27.2; //[10:60:0.1]
fitting_len_mm = 45; //[25:90:1]
fitting_od_mm = 38; //[30:60:1]
fitting_wall_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      // Hollow bore
      translate([0, 0, 0])
        cylinder(h=length_mm + fitting_len_mm, r=id_mm/2, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - overlap_mm])
      difference() {
        cylinder(h=fitting_len_mm, r=fitting_od_mm/2, center=false);
        translate([0, 0, 0])
          cylinder(h=fitting_len_mm + overlap_mm, r=fitting_od_mm/2 - fitting_wall_mm, center=false);
      }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();