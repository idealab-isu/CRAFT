// HT 160 Cap + short pipe stub (ONE connected solid) - fixed connectivity/visibility

// Parameters
nominal_size = 160; //[80:320:1]
pipe_outer_diameter_mm = 160; //[80:320:0.1]
pipe_wall_thickness_mm = 4; //[2:8:0.1]
pipe_visual_length_mm = 120; //[60:240:1]

cap_wall_thickness_mm = 4; //[2:8:0.1]
insertion_depth_mm = 50; //[25:100:1]
end_face_thickness_mm = 6; //[3:12:0.1]
clearance_mm = 0.5; //[0.1:1.5:0.05]

outer_rim_thickness_mm = 2; //[1:5:0.1]
outer_rim_height_mm = 8; //[4:20:0.5]

chamfer_lead_in_mm = 1.5; //[0.5:4:0.1]

stop_shoulder_height_mm = 3; //[1:8:0.1]
stop_shoulder_radial_mm = 2; //[1:6:0.1]

cap_overlap_mm = 1; //[0.5:2:0.1]

// Quality
$fn = 128;

// Derived
pipe_ro = pipe_outer_diameter_mm/2;
pipe_ri = max(0.01, pipe_ro - pipe_wall_thickness_mm);

cap_socket_r = pipe_ro + clearance_mm;                 // inner radius of cap socket
cap_outer_r  = cap_socket_r + cap_wall_thickness_mm;   // outer radius of cap body
cap_len = end_face_thickness_mm + insertion_depth_mm;  // total cap length

// Z layout (cap spans [-cap_len/2 .. +cap_len/2])
cap_zmin = -cap_len/2;
cap_zmax =  cap_len/2;

// Pipe stub placed so its top overlaps into cap socket opening at z=cap_zmax
pipe_zmax = cap_zmax + cap_overlap_mm;
pipe_zmin = pipe_zmax - pipe_visual_length_mm;
pipe_zc   = (pipe_zmin + pipe_zmax)/2;

// Cap solid (single connected body)
module cap_solid() {
  difference() {
    union() {
      // Main outer body
      cylinder(r=cap_outer_r, h=cap_len, center=true);

      // Outer grip rim near the open end (top) - ensure overlap into main body
      translate([0, 0, cap_zmax - outer_rim_height_mm/2 - cap_overlap_mm/2])
        cylinder(r=cap_outer_r + outer_rim_thickness_mm,
                 h=outer_rim_height_mm + cap_overlap_mm,
                 center=true);

      // Internal stop shoulder ring (inside socket)
      translate([0, 0, cap_zmax - insertion_depth_mm + stop_shoulder_height_mm/2])
        difference() {
          cylinder(r=cap_socket_r + stop_shoulder_radial_mm,
                   h=stop_shoulder_height_mm,
                   center=true);
          cylinder(r=cap_socket_r,
                   h=stop_shoulder_height_mm + cap_overlap_mm,
                   center=true);
        }
    }

    // Inner socket cavity (open at top, closed by end face thickness)
    // Start at top and go down insertion_depth, with a tiny overlap to avoid coplanar faces
    translate([0, 0, cap_zmax - insertion_depth_mm/2 + cap_overlap_mm/2])
      cylinder(r=cap_socket_r,
               h=insertion_depth_mm + cap_overlap_mm,
               center=true);

    // Lead-in chamfer at the opening (top)
    translate([0, 0, cap_zmax - chamfer_lead_in_mm/2 + cap_overlap_mm/2])
      cylinder(r1=cap_socket_r + chamfer_lead_in_mm,
               r2=cap_socket_r,
               h=chamfer_lead_in_mm + cap_overlap_mm,
               center=true);
  }
}

// Pipe stub (hollow)
module pipe_stub() {
  difference() {
    cylinder(r=pipe_ro, h=pipe_visual_length_mm, center=true);
    cylinder(r=pipe_ri, h=pipe_visual_length_mm + 2*cap_overlap_mm, center=true);
  }
}

// Assembly as ONE connected solid
union() {
  cap_solid();
  translate([0, 0, pipe_zc]) pipe_stub();
}