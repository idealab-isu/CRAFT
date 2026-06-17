// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 160; //[80:320:1]
length_mm = 1500; //[750:3000:1]
pipe_od = 160; //[80:320:1]
pipe_wall = 4.9; //[2.5:10:0.1]
fitting_length = 70; //[35:140:1]
fitting_od_factor = 1.12; //[1.05:1.25:0.01]
fitting_wall_factor = 1.3; //[1.0:2.0:0.05]
socket_depth_factor = 0.75; //[0.5:0.95:0.01]
overlap = 1; //[0.5:2:0.1]
orientation_axis_aligned = 1; //[1:1:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length, r=(pipe_od * fitting_od_factor) / 2, center=false);
      
      // Socket void
      translate([0, 0, length_mm - overlap + pipe_wall])
        cylinder(h=fitting_length * socket_depth_factor, r=pipe_od/2 + pipe_wall * 0.2, center=false);
      
      // Through bore void
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();