// Parameters
outer_diameter_mm = 50; //[25:100:0.1]
socket_depth_mm = 40; //[20:80:0.5]
wall_thickness_mm = 2.5; //[1.25:5:0.1]
end_wall_thickness_mm = 3; //[1.5:6:0.1]
clearance_mm = 0.3; //[0.1:1:0.05]
chamfer_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
stop_lip_thickness_mm = 2; //[1:4:0.1]
stop_lip_radial_mm = 1.5; //[0.5:3:0.1]
pipe_stub_length_mm = 60; //[30:120:1]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer cylinder of the pipe
      cylinder(h=pipe_stub_length_mm, r=outer_diameter_mm/2, center=true);
      // Inner cylinder of the pipe
      translate([0, 0, -overlap_mm/2])
        cylinder(h=pipe_stub_length_mm + overlap_mm, r=outer_diameter_mm/2 - pipe_wall_mm, center=true);
    }
  }
}

// Cap with socket interface
module cap_socket_interface() {
  color([0.75, 0.75, 0.77]) {
    difference() {
      // Outer cylinder of the cap
      cylinder(h=socket_depth_mm + end_wall_thickness_mm, r=outer_diameter_mm/2 + wall_thickness_mm, center=true);
      // Inner bore cylinder
      translate([0, 0, end_wall_thickness_mm/2 - overlap_mm/2])
        cylinder(h=socket_depth_mm + overlap_mm, r=outer_diameter_mm/2 + clearance_mm, center=true);
      // Chamfer cone at the mouth
      translate([0, 0, (socket_depth_mm + end_wall_thickness_mm)/2 - chamfer_mm/2])
        cylinder(h=chamfer_mm, r1=outer_diameter_mm/2 + clearance_mm + chamfer_mm, r2=outer_diameter_mm/2 + clearance_mm, center=true);
    }
  }
}

// Internal stop lip
module internal_stop_lip() {
  color([0.4, 0.4, 0.43]) {
    difference() {
      // Outer ring of the stop lip
      translate([0, 0, -((socket_depth_mm + end_wall_thickness_mm)/2) + end_wall_thickness_mm + stop_lip_thickness_mm/2])
        cylinder(h=stop_lip_thickness_mm, r=outer_diameter_mm/2 + clearance_mm, center=true);
      // Inner ring of the stop lip
      translate([0, 0, -((socket_depth_mm + end_wall_thickness_mm)/2) + end_wall_thickness_mm + stop_lip_thickness_mm/2])
        cylinder(h=stop_lip_thickness_mm + overlap_mm, r=outer_diameter_mm/2 + clearance_mm - stop_lip_radial_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  // Cap with socket interface and internal stop lip
  union() {
    cap_socket_interface();
    internal_stop_lip();
  }
  // HT Pipe
  translate([0, 0, end_wall_thickness_mm/2 + socket_depth_mm/2 - overlap_mm])
    ht_pipe();
}

assembly();