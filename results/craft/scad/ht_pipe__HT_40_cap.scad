$fn = 128;

// Parameters
pipe_outer_diameter_mm = 40; //[20:80:0.1]
cap_outer_diameter_mm = 48; //[24:96:0.1]
cap_wall_thickness_mm = 4; //[2:8:0.1]
socket_inner_diameter_mm = 40.5; //[20.2:81:0.1]
socket_depth_mm = 30; //[15:60:0.5]
end_face_thickness_mm = 4; //[2:8:0.1]
stop_shoulder_thickness_mm = 2; //[1:4:0.1]
chamfer_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_length_mm = 60; //[30:120:1]
pipe_wall_thickness_mm = 2.5; //[1.5:5:0.1]
cap_total_height_mm = 34; //[17:68:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(r=pipe_outer_diameter_mm/2, h=pipe_length_mm, center=true);
    translate([0, 0, 0])
      cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm,
               h=pipe_length_mm + overlap_mm, center=true);
  }
}

// HT 40 End Cap (closed end)
module cap() {
  color([0.2, 0.2, 0.2])
  union() {
    // Outer cap body with inner socket cavity (open end at +Z, closed end at -Z)
    difference() {
      cylinder(r=cap_outer_diameter_mm/2, h=cap_total_height_mm, center=true);

      // Inner socket cavity: starts at open end (+Z) and stops before the closed end
      translate([0, 0, cap_total_height_mm/2 - socket_depth_mm/2])
        cylinder(r=socket_inner_diameter_mm/2,
                 h=socket_depth_mm + overlap_mm, center=true);

      // Chamfer at the open mouth
      translate([0, 0, cap_total_height_mm/2 - chamfer_mm/2])
        cylinder(r1=socket_inner_diameter_mm/2 + chamfer_mm,
                 r2=socket_inner_diameter_mm/2,
                 h=chamfer_mm + overlap_mm, center=true);
    }

    // Internal stop shoulder ring (inside the socket), connected to cap body
    translate([0, 0, cap_total_height_mm/2 - socket_depth_mm + stop_shoulder_thickness_mm/2 - overlap_mm/2])
      difference() {
        cylinder(r=socket_inner_diameter_mm/2, h=stop_shoulder_thickness_mm, center=true);
        cylinder(r=socket_inner_diameter_mm/2 - cap_wall_thickness_mm,
                 h=stop_shoulder_thickness_mm + overlap_mm, center=true);
      }
  }
}

// Assembly: cap with pipe inserted into socket (one connected solid)
module assembly() {
  union() {
    cap();

    // Place pipe so its top end is slightly past the shoulder (overlap ensures union connectivity)
    translate([0, 0,
      (cap_total_height_mm/2 - socket_depth_mm) - pipe_length_mm/2 + overlap_mm
    ])
      ht_pipe();
  }
}

assembly();