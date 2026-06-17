// Parameters
nominal_size_mm = 32; //[16:64:1]
tolerance_mm = 0.2; //[0.05:0.6:0.05]
wall_thickness_mm = 2; //[1:4:0.1]
cap_depth_mm = 25; //[12:50:1]
end_face_thickness_mm = 3; //[1.5:8:0.1]
internal_stop_lip_height_mm = 2; //[1:6:0.1]
socket_extra_radial_mm = 1.5; //[0.5:4:0.1]
stop_lip_radial_mm = 1.2; //[0.5:3:0.1]
pipe_wall_mm = 2.4; //[1.2:5:0.1]
pipe_length_mm = 60; //[20:150:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// Derived radii
pipe_ro = nominal_size_mm/2;
pipe_ri = max(0.01, pipe_ro - pipe_wall_mm);

cap_ro  = pipe_ro + wall_thickness_mm + socket_extra_radial_mm;
cap_ri  = pipe_ro + tolerance_mm;

lip_r   = max(0.01, cap_ri - stop_lip_radial_mm);

// Heights
cap_h = cap_depth_mm + end_face_thickness_mm;

// HT Pipe (open tube)
module ht_pipe() {
  difference() {
    cylinder(h=pipe_length_mm, r=pipe_ro, center=true);
    cylinder(h=pipe_length_mm + 2*overlap_mm, r=pipe_ri, center=true);
  }
}

// End Cap (socket + closed end)
module end_cap() {
  union() {
    // Main cap body: outer cylinder minus inner socket void (leaves end face thickness)
    difference() {
      cylinder(h=cap_h, r=cap_ro, center=true);

      // Inner void: open end at bottom face, stops before closed face
      // Outer cap spans z=[-cap_h/2, +cap_h/2]
      // Inner void spans z=[-cap_h/2 - overlap, +cap_h/2 - end_face_thickness]
      inner_h = cap_depth_mm + overlap_mm;
      inner_center_z = (-cap_h/2) + inner_h/2 - overlap_mm;

      translate([0, 0, inner_center_z])
        cylinder(h=inner_h, r=cap_ri, center=true);
    }

    // Internal stop lip (ring) inside the socket near the open end
    lip_center_z = (-cap_h/2) + internal_stop_lip_height_mm/2;

    translate([0, 0, lip_center_z])
      difference() {
        cylinder(h=internal_stop_lip_height_mm, r=cap_ri, center=true);
        cylinder(h=internal_stop_lip_height_mm + 2*overlap_mm, r=lip_r, center=true);
      }
  }
}

// Assembly: ONE connected solid (cap + pipe inserted into socket with overlap)
module assembly() {
  union() {
    end_cap();

    // Cap open end plane at z = -cap_h/2
    // Pipe top end should be at z = cap_open + overlap_mm
    // pipe_center_z + pipe_length/2 = (-cap_h/2) + overlap_mm
    pipe_center_z = (-cap_h/2 + overlap_mm) - pipe_length_mm/2;

    translate([0, 0, pipe_center_z])
      ht_pipe();
  }
}

color([0.85, 0.85, 0.8]) assembly();