// Parameters
nominal_size = 160; //[80:320:1]
cap_outer_diameter = 160; //[120:240:1]
cap_wall_thickness = 4; //[2:8:0.5]
socket_inner_diameter = 160; //[120:240:1]
tolerance_clearance = 0.5; //[0.1:1.5:0.1]
socket_depth = 50; //[25:100:1]
end_face_thickness = 6; //[3:12:0.5]
internal_stop_position_from_open_end = 45; //[20:90:1]
internal_stop_thickness = 3; //[1:8:0.5]
fillet_radius = 2; //[0:6:0.5]
overlap = 1; //[0.5:2:0.5]
pipe_wall_thickness = 4; //[2:8:0.5]
pipe_stub_length = 80; //[40:160:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Cap outer cylinder
    difference() {
      translate([0, 0, 0])
        cylinder(r=cap_outer_diameter/2, h=socket_depth + end_face_thickness, center=true);
      // Cap inner void cylinder
      translate([0, 0, end_face_thickness/2])
        cylinder(r=(socket_inner_diameter + 2*tolerance_clearance)/2, h=socket_depth + end_face_thickness, center=true);
    }
    
    // Internal stop ring
    difference() {
      translate([0, 0, -(socket_depth + end_face_thickness)/2 + internal_stop_position_from_open_end])
        cylinder(r=(socket_inner_diameter + 2*tolerance_clearance)/2, h=internal_stop_thickness, center=true);
      translate([0, 0, -(socket_depth + end_face_thickness)/2 + internal_stop_position_from_open_end])
        cylinder(r=(socket_inner_diameter + 2*tolerance_clearance)/2 - cap_wall_thickness, h=internal_stop_thickness + 2*overlap, center=true);
    }
    
    // Pipe outer cylinder
    difference() {
      translate([0, 0, -(socket_depth + end_face_thickness)/2 + pipe_stub_length/2 - overlap])
        cylinder(r=socket_inner_diameter/2, h=pipe_stub_length, center=true);
      // Pipe inner void cylinder
      translate([0, 0, -(socket_depth + end_face_thickness)/2 + pipe_stub_length/2 - overlap])
        cylinder(r=socket_inner_diameter/2 - pipe_wall_thickness, h=pipe_stub_length + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();