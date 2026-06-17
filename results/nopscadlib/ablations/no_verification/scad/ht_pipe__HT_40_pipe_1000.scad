// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 40; //[20:80:1]
wall_mm = 1.8; //[0.9:3.6:0.1]
id_mm = 36.4; //[18:76:0.1]
eps = 1; //[0.5:2:0.1]
fitting_len = 35; //[15:70:1]
fitting_od = 46; //[40:70:1]
fitting_wall = 2.5; //[1.2:5:0.1]
fitting_id = 41; //[30:80:0.1]
fitting_stop_len = 4; //[2:10:0.5]
fitting_stop_thk = 1.5; //[0.5:4:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, -eps])
        cylinder(h=length_mm + 2*eps, r=id_mm/2, center=false);
    }
    
    // End fitting geometry
    if (include_end_fitting) {
      translate([0, 0, length_mm - eps]) {
        // Fitting sleeve
        difference() {
          cylinder(h=fitting_len, r=fitting_od/2, center=false);
          translate([0, 0, -eps])
            cylinder(h=fitting_len + 2*eps, r=fitting_id/2, center=false);
        }
        
        // Fitting stop ring
        translate([0, 0, fitting_len/2 - fitting_stop_len/2]) {
          difference() {
            cylinder(h=fitting_stop_len, r=fitting_id/2, center=false);
            translate([0, 0, -eps])
              cylinder(h=fitting_stop_len + 2*eps, r=fitting_id/2 - fitting_stop_thk, center=false);
          }
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