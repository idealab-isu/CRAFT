// Parameters
nominal_size = 125; //[60:250:1]
pipe_od_mm = 125; //[60:250:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
socket_clearance_mm = 0.4; //[0.1:1.0:0.05]
socket_insertion_depth_mm = 50; //[25:100:1]
cap_wall_thickness_mm = 4; //[2:10:0.5]
end_plate_thickness_mm = 6; //[3:15:0.5]
outer_edge_fillet_radius_mm = 1.5; //[0.5:4:0.25]
inner_lead_in_chamfer_mm = 1.0; //[0.5:3.0:0.25]
stop_shoulder_height_mm = 2.0; //[1.0:5.0:0.25]
overlap_mm = 1.0; //[0.5:2.0:0.1]
pipe_length_mm = 80; //[40:200:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(h=pipe_length_mm, r=pipe_od_mm/2, center=true);
      // Inner void
      translate([0, 0, -overlap_mm/2])
        cylinder(h=pipe_length_mm + overlap_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=true);
    }
  }
}

// Cap Assembly
module cap_assembly() {
  color([0.85, 0.85, 0.8]) {
    // Cap shell outer
    difference() {
      union() {
        // Cap shell outer
        cylinder(h=socket_insertion_depth_mm + end_plate_thickness_mm, 
                 r=pipe_od_mm/2 + socket_clearance_mm + cap_wall_thickness_mm, center=true);
        // Closed end plate
        translate([0, 0, (socket_insertion_depth_mm + end_plate_thickness_mm)/2 - end_plate_thickness_mm/2])
          cylinder(h=end_plate_thickness_mm, 
                   r=pipe_od_mm/2 + socket_clearance_mm + cap_wall_thickness_mm, center=true);
        // Insertion stop shoulder ring
        translate([0, 0, (socket_insertion_depth_mm + end_plate_thickness_mm)/2 - end_plate_thickness_mm - stop_shoulder_height_mm/2 + overlap_mm])
          cylinder(h=stop_shoulder_height_mm, 
                   r=pipe_od_mm/2 + socket_clearance_mm + cap_wall_thickness_mm, center=true);
      }
      // Pipe socket interface void
      translate([0, 0, (socket_insertion_depth_mm + overlap_mm)/2 - (socket_insertion_depth_mm + end_plate_thickness_mm)/2])
        cylinder(h=socket_insertion_depth_mm + overlap_mm, 
                 r=pipe_od_mm/2 + socket_clearance_mm, center=true);
      // Insertion stop shoulder inner void
      translate([0, 0, (socket_insertion_depth_mm + end_plate_thickness_mm)/2 - end_plate_thickness_mm - stop_shoulder_height_mm/2 + overlap_mm])
        cylinder(h=stop_shoulder_height_mm + overlap_mm, 
                 r=pipe_od_mm/2 + socket_clearance_mm, center=true);
      // Lead-in chamfer cone cut
      translate([0, 0, -(socket_insertion_depth_mm + end_plate_thickness_mm)/2 + inner_lead_in_chamfer_mm/2])
        rotate([180, 0, 0])
        cylinder(h=inner_lead_in_chamfer_mm, 
                 r1=pipe_od_mm/2 + socket_clearance_mm + inner_lead_in_chamfer_mm, r2=0, center=true);
    }
  }
  // HT Pipe
  translate([0, 0, -(socket_insertion_depth_mm + end_plate_thickness_mm)/2 - pipe_length_mm/2 + overlap_mm])
    ht_pipe();
}

// Final assembly
module assembly() {
  cap_assembly();
}

assembly();