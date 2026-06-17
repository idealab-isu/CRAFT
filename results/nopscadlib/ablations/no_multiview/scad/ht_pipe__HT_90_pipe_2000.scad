// Parameters
length_mm = 2000; //[1000:4000:10]
outer_diameter_mm = 90; //[45:180:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_length_mm = 70; //[35:140:1]
socket_outer_diameter_mm = 110; //[95:140:1]
socket_wall_thickness_mm = 4; //[2:8:0.1]
socket_insert_depth_mm = 55; //[30:110:1]
socket_stop_thickness_mm = 3; //[1:8:0.1]
overlap_mm = 1; //[0.5:2:0.1]
include_end_fitting = 1; //[0:1:1]

// HT Pipe Body
module ht_pipe_body() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      translate([0, 0, 0])
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=false, $fn=64);
      // Inner void
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false, $fn=64);
    }
  }
}

// End Fitting Socket
module end_fitting_socket() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer socket
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=socket_length_mm, r=socket_outer_diameter_mm/2, center=false, $fn=64);
      // Inner void
      translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
        cylinder(h=socket_length_mm + overlap_mm, r=socket_outer_diameter_mm/2 - socket_wall_thickness_mm, center=false, $fn=64);
      // Insert bore
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=socket_insert_depth_mm, r=outer_diameter_mm/2 + overlap_mm, center=false, $fn=64);
      // Stop relief
      translate([0, 0, length_mm - overlap_mm + socket_insert_depth_mm - overlap_mm/2])
        cylinder(h=socket_stop_thickness_mm + overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false, $fn=64);
    }
  }
}

// HT Pipe with optional end fitting
module ht_pipe() {
  if (include_end_fitting) {
    union() {
      ht_pipe_body();
      end_fitting_socket();
    }
  } else {
    ht_pipe_body();
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();