// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 150; //[75:300:1]
pipe_od = 40; //[20:80:0.5]
pipe_wall = 1.8; //[0.9:3.6:0.1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 25; //[12.5:50:0.5]
fitting_od_scale = 1.15; //[1.05:1.35:0.01]
socket_wall_extra = 1.2; //[0.6:2.4:0.1]
socket_depth = 18; //[9:36:0.5]
lead_in_length = 6; //[3:12:0.5]
lead_in_od_scale = 1.08; //[1.02:1.2:0.01]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm + overlap*2, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - overlap]) {
      difference() {
        union() {
          // Main outer fitting
          cylinder(h=fitting_length, r=(pipe_od*fitting_od_scale)/2, center=false);
          // Lead-in section
          translate([0, 0, fitting_length])
            cylinder(h=lead_in_length, r1=(pipe_od*fitting_od_scale)/2, r2=(pipe_od*lead_in_od_scale)/2, center=false);
        }
        // Socket void
        translate([0, 0, 0])
          cylinder(h=socket_depth + overlap, r=pipe_od/2 + socket_wall_extra - pipe_wall, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();