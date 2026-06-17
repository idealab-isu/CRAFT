// Parameters
nominal_diameter_mm = 160; //[80:320:1]
pipe_outer_diameter_mm = 160; //[80:320:1]
cap_wall_thickness_mm = 4; //[2:8:0.5]
socket_insertion_depth_mm = 50; //[25:100:1]
end_thickness_mm = 6; //[3:12:0.5]
clearance_mm = 0.5; //[0.2:1.5:0.1]
outer_rim_thickness_mm = 3; //[1.5:6:0.5]
outer_rim_height_mm = 10; //[5:25:1]
fillet_radius_mm = 1; //[0:3:0.5]
pipe_wall_thickness_mm = 4.7; //[2.5:9.5:0.1]
ht_pipe_length_mm = 120; //[60:240:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_outer_diameter_mm/2, h=ht_pipe_length_mm, center=true);
      // Inner cavity
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm, h=ht_pipe_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap Body - complete geometry
module cap_body() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      union() {
        // Outer cap body
        cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm + cap_wall_thickness_mm + outer_rim_thickness_mm, h=socket_insertion_depth_mm + end_thickness_mm, center=true);
        // Outer grip rim
        translate([0, 0, ((socket_insertion_depth_mm + end_thickness_mm)/2) - outer_rim_height_mm/2])
          cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm + cap_wall_thickness_mm + outer_rim_thickness_mm, h=outer_rim_height_mm, center=true);
      }
      // Inner socket cavity
      translate([0, 0, ((socket_insertion_depth_mm + end_thickness_mm)/2) - socket_insertion_depth_mm/2 + overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm, h=socket_insertion_depth_mm + overlap_mm, center=true);
    }
  }
}

// Pipe Stop Shoulder
module pipe_stop_shoulder() {
  color([0.2, 0.2, 0.2]) {
    translate([0, 0, -((socket_insertion_depth_mm + end_thickness_mm)/2) + end_thickness_mm/2])
      cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm, h=end_thickness_mm, center=true);
  }
}

// Assembly
module assembly() {
  cap_body();
  pipe_stop_shoulder();
  translate([0, 0, ((socket_insertion_depth_mm + end_thickness_mm)/2) - socket_insertion_depth_mm/2])
    ht_pipe();
}

assembly();