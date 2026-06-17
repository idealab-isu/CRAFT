$fn = 128;

// Parameters
nominal_diameter_mm = 125; //[62.5:250:1]
pipe_outer_diameter_mm = 125; //[62.5:250:0.1]
pipe_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
cap_wall_thickness_mm = 4; //[2:8:0.1]
socket_insertion_depth_mm = 50; //[25:100:1]
internal_clearance_mm = 0.4; //[0.1:1:0.05]
end_face_thickness_mm = 5; //[2.5:10:0.5]
outer_diameter_mm = 133; //[66.5:266:0.1]
overall_length_mm = 60; //[30:120:1]
fillet_radius_mm = 1; //[0:3:0.1]
chamfer_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
stop_ring_axial_thickness_mm = 4; //[2:8:0.5]
stop_ring_radial_width_mm = 3; //[1.5:6:0.5]
grip_rim_radial_add_mm = 3; //[1:8:0.5]
grip_rim_axial_height_mm = 10; //[5:25:1]
pipe_preview_length_mm = 80; //[40:200:1]

// Helpers
function clamp_min(x, mn) = (x < mn) ? mn : x;

// Derived
pipe_r = pipe_outer_diameter_mm/2;
pipe_inner_r = pipe_r - pipe_wall_thickness_mm;

cap_outer_r = outer_diameter_mm/2;
cap_inner_r = cap_outer_r - cap_wall_thickness_mm;

socket_r = pipe_r + internal_clearance_mm;

pipe_inner_r_ok = clamp_min(pipe_inner_r, 0.01);
cap_inner_r_ok  = clamp_min(cap_inner_r, 0.01);

// Ensure valid axial layout (avoid negative/zero heights that can yield empty geometry)
socket_depth_ok = clamp_min(socket_insertion_depth_mm, 0.01);
end_face_ok     = clamp_min(end_face_thickness_mm, 0.01);
overall_len_ok  = clamp_min(overall_length_mm, socket_depth_ok + end_face_ok + 0.01);

inner_behind_socket_h = clamp_min(overall_len_ok - socket_depth_ok - end_face_ok, 0.01);

module ht_pipe(len=pipe_preview_length_mm) {
  len_ok = clamp_min(len, 0.01);
  difference() {
    cylinder(r=pipe_r, h=len_ok, center=true);
    cylinder(r=pipe_inner_r_ok, h=len_ok + 2*overlap_mm, center=true);
  }
}

module ht_125_cap_solid() {
  // Z reference: open end at z = -overall_len_ok/2, closed end at z = +overall_len_ok/2
  z_open   = -overall_len_ok/2;
  z_closed =  overall_len_ok/2;

  union() {
    // Main cap body (outer) with internal cavities subtracted
    difference() {
      cylinder(r=cap_outer_r, h=overall_len_ok, center=true);

      // Socket void: from open end upward
      translate([0, 0, z_open + socket_depth_ok/2])
        cylinder(r=socket_r, h=socket_depth_ok + 2*overlap_mm, center=true);

      // Inner void behind socket, leaving end_face_ok at the closed end
      translate([0, 0, z_open + socket_depth_ok + inner_behind_socket_h/2])
        cylinder(r=cap_inner_r_ok, h=inner_behind_socket_h + 2*overlap_mm, center=true);
    }

    // Internal stop ring (added material) at the socket end (depth stop)
    // Positioned so it overlaps the shell and sits at the top of the socket region.
    translate([0, 0, z_open + socket_depth_ok - stop_ring_axial_thickness_mm/2])
      difference() {
        cylinder(r=socket_r + stop_ring_radial_width_mm,
                 h=stop_ring_axial_thickness_mm + 2*overlap_mm, center=true);
        cylinder(r=socket_r,
                 h=stop_ring_axial_thickness_mm + 4*overlap_mm, center=true);
      }

    // Outer grip rim near open end; overlaps shell
    translate([0, 0, z_open + grip_rim_axial_height_mm/2])
      cylinder(r=cap_outer_r + grip_rim_radial_add_mm,
               h=grip_rim_axial_height_mm + 2*overlap_mm, center=true);
  }
}

module assembly() {
  // One connected solid: cap + pipe stub inserted into socket with overlap
  union() {
    ht_125_cap_solid();

    pipe_stub_len = socket_depth_ok;
    z_open = -overall_len_ok/2;

    // Place stub so its bottom is slightly below the open end (overlap),
    // ensuring a manifold union with the cap at the mouth.
    translate([0, 0, z_open + pipe_stub_len/2 - overlap_mm])
      ht_pipe(len=pipe_stub_len + 2*overlap_mm);
  }
}

assembly();