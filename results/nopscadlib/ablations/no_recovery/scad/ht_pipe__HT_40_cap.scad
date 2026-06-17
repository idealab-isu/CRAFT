// Parameters
nominal_size = 40; //[20:80:1]
pipe_od_mm = 40; //[20:80:0.1]
socket_id_mm = 40.5; //[20.5:81:0.1]
cap_wall_thickness_mm = 2.5; //[1.2:5:0.1]
socket_depth_mm = 30; //[15:60:1]
end_face_thickness_mm = 3; //[1.5:8:0.1]
outer_diameter_mm = 50; //[30:100:0.1]
chamfer_mm = 1; //[0.5:3:0.1]
fillet_radius_mm = 1; //[0.5:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
grip_ring_count = 4; //[2:10:1]
grip_ring_height_mm = 2; //[1:5:0.1]
grip_ring_radial_mm = 0.8; //[0.3:2:0.1]
pipe_wall_mm = 2.2; //[1.2:5:0.1]
pipe_length_mm = 80; //[40:200:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.0, 0.4, 0.2]) { // Green for PVC pipe
    difference() {
      // Outer pipe
      cylinder(r=pipe_od_mm/2, h=pipe_length_mm, center=true);
      // Inner pipe
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_od_mm/2 - pipe_wall_mm, h=pipe_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap Body - complete geometry
module cap_body() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC cap
    difference() {
      // Outer cap body
      translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2])
        cylinder(r=outer_diameter_mm/2, h=socket_depth_mm + end_face_thickness_mm, center=false);
      // Internal clearance bore
      translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + overlap_mm/2])
        cylinder(r=socket_id_mm/2, h=socket_depth_mm + overlap_mm, center=false);
    }
    // Insertion stop shoulder
    translate([0, 0, socket_depth_mm/2 - (socket_depth_mm + end_face_thickness_mm)/2 + end_face_thickness_mm/2])
      cylinder(r=(socket_id_mm/2) - cap_wall_thickness_mm, h=end_face_thickness_mm + overlap_mm, center=true);
    // Socket interface chamfer
    translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + chamfer_mm/2])
      cylinder(r1=socket_id_mm/2, r2=(socket_id_mm/2) + chamfer_mm, h=chamfer_mm, center=true);
    // Outer grip rings
    for (i = [0:grip_ring_count-1]) {
      translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + chamfer_mm + grip_ring_height_mm/2 + i * ((socket_depth_mm - chamfer_mm - grip_ring_height_mm) / grip_ring_count)])
        cylinder(r=outer_diameter_mm/2 + grip_ring_radial_mm, h=grip_ring_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  cap_body();
  translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 - pipe_length_mm/2 + socket_depth_mm - overlap_mm])
    ht_pipe();
}

assembly();