// Parameters
nominal_diameter = 125; //[60:250:1]
cap_outer_diameter = 140; //[100:280:1]
cap_total_height = 60; //[30:120:1]
socket_inner_diameter = 125; //[60:250:1]
socket_depth = 45; //[20:100:1]
cap_wall_thickness = 4; //[2:10:0.5]
end_face_thickness = 5; //[2:15:0.5]
clearance = 0.5; //[0.1:1.5:0.1]
grip_rim_radial = 3; //[1:8:0.5]
grip_rim_height = 10; //[4:25:1]
pipe_wall_thickness = 3.2; //[2:6:0.1]
pipe_length = 80; //[40:200:1]
overlap = 1; //[0.5:2:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      translate([0, 0, cap_total_height/2 - socket_depth/2])
        cylinder(r=socket_inner_diameter/2, h=pipe_length, center=true, $fn=64);
      // Inner pipe
      translate([0, 0, cap_total_height/2 - socket_depth/2])
        cylinder(r=socket_inner_diameter/2 - pipe_wall_thickness, h=pipe_length + overlap, center=true, $fn=64);
    }
  }
}

// Cap with grip rim
module cap_with_rim() {
  union() {
    // Cap body
    translate([0, 0, 0])
      cylinder(r=cap_outer_diameter/2, h=cap_total_height, center=true, $fn=64);
    // Outer grip rim
    translate([0, 0, cap_total_height/2 - grip_rim_height/2])
      cylinder(r=cap_outer_diameter/2 + grip_rim_radial, h=grip_rim_height, center=true, $fn=64);
  }
}

// Cap shell
module cap_shell() {
  difference() {
    cap_with_rim();
    // Inner socket cavity
    translate([0, 0, cap_total_height/2 - socket_depth/2])
      cylinder(r=(socket_inner_diameter + 2*clearance)/2, h=socket_depth + overlap, center=true, $fn=64);
    // Pipe stop shoulder
    translate([0, 0, -cap_total_height/2 + end_face_thickness/2])
      cylinder(r=(socket_inner_diameter + 2*clearance)/2, h=end_face_thickness + overlap, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  union() {
    cap_shell();
    ht_pipe();
  }
}

assembly();