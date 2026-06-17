// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 40; //[30:80:0.5]
pipe_wall = 1.8; //[1:4:0.1]
end_fitting_length = 45; //[25:90:1]
end_fitting_od_scale = 1.25; //[1.05:1.6:0.01]
end_fitting_wall_extra = 0.8; //[0:3:0.1]
include_end_fitting = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm - pipe_wall, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap]) {
        difference() {
          cylinder(h=end_fitting_length, r=(pipe_od * end_fitting_od_scale) / 2, center=false);
          translate([0, 0, 0])
            cylinder(h=end_fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
          translate([0, 0, 0])
            cylinder(h=end_fitting_length * 0.6, r=(pipe_od/2 - pipe_wall) + end_fitting_wall_extra, center=false);
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