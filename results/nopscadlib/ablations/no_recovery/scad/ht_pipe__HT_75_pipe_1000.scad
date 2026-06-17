// Parameters
pipe_type = 75; //[50:150:1]
length_mm = 1000; //[500:2000:10]
pipe_od = 75; //[50:150:1]
pipe_wall = 2.7; //[1.5:5.4:0.1]
fitting_length = 55; //[30:110:1]
fitting_od_scale = 1.12; //[1.05:1.3:0.01]
fitting_wall_extra = 1.5; //[0.5:4:0.1]
socket_depth = 40; //[20:80:1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Outer pipe with end fitting
    union() {
      // Main pipe segment
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2, center=false, $fn=64);
      
      // End fitting
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length, r=(pipe_od * fitting_od_scale) / 2, center=false, $fn=64);
    }
    
    // Hollow out the pipe and fitting
    difference() {
      // Outer structure
      union() {
        // Main pipe segment
        translate([0, 0, 0])
          cylinder(h=length_mm, r=pipe_od/2, center=false, $fn=64);
        
        // End fitting
        translate([0, 0, length_mm - overlap])
          cylinder(h=fitting_length, r=(pipe_od * fitting_od_scale) / 2, center=false, $fn=64);
      }
      
      // Main bore
      translate([0, 0, -overlap/2])
        cylinder(h=length_mm + overlap, r=pipe_od/2 - pipe_wall, center=false, $fn=64);
      
      // End fitting bore
      translate([0, 0, length_mm - overlap/2])
        cylinder(h=fitting_length + overlap, r=(pipe_od/2 - pipe_wall) + overlap, center=false, $fn=64);
      
      // Socket void
      translate([0, 0, length_mm - overlap/2])
        cylinder(h=socket_depth + overlap, r=pipe_od/2 + overlap, center=false, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();