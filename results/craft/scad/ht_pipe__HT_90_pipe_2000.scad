// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 90; //[50:180:1]
length_mm = 2000; //[1000:4000:10]
include_end_fitting = 1; //[0:1:1]
pipe_od = 90; //[50:180:1]
pipe_wall = 2.7; //[1.5:5.4:0.1]
pipe_id = 84.6; //[40:170:0.1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 60; //[0:120:1]
fitting_od = 98; //[90:140:1]
fitting_wall = 3.2; //[2:6:0.1]
socket_depth = 45; //[20:80:1]
stop_ring_thickness = 4; //[2:10:0.5]
chamfer_length = 6; //[2:15:0.5]
chamfer_extra_radius = 2; //[0.5:6:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm + 2*overlap, r=(pipe_od - 2*pipe_wall)/2, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        union() {
          cylinder(h=fitting_length, r=fitting_od/2, center=false);
          translate([0, 0, length_mm - overlap])
            cylinder(h=overlap, r=pipe_od/2 + overlap, center=false);
        }
        translate([0, 0, length_mm - overlap - overlap])
          cylinder(h=fitting_length + 2*overlap, r=(fitting_od - 2*fitting_wall)/2, center=false);
        translate([0, 0, length_mm - overlap])
          cylinder(h=socket_depth + overlap, r=pipe_od/2 + overlap, center=false);
        translate([0, 0, length_mm - overlap + socket_depth - stop_ring_thickness])
          cylinder(h=stop_ring_thickness + overlap, r=(pipe_od - 2*pipe_wall)/2, center=false);
        translate([0, 0, length_mm - overlap])
          cylinder(h=chamfer_length, r1=pipe_od/2 + chamfer_extra_radius, r2=pipe_od/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();