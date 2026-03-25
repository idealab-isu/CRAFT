// Parameters
pipe_outer_diameter_mm = 75; //[60:150:1]
cap_wall_thickness_mm = 3; //[1.5:6:0.5]
socket_insertion_depth_mm = 35; //[20:70:1]
end_face_thickness_mm = 4; //[2:10:0.5]
clearance_mm = 0.3; //[0.1:1:0.05]
lead_in_chamfer_mm = 1; //[0.5:3:0.25]
outer_grip_band_height_mm = 12; //[6:30:1]
outer_grip_band_depth_mm = 1; //[0.5:3:0.25]
insertion_stop_shoulder_thickness_mm = 2; //[1:5:0.5]
connection_overlap_mm = 1; //[0.5:2:0.1]
pipe_stub_length_mm = 25; //[10:80:1]
pipe_stub_wall_mm = 2.5; //[1.5:5:0.5]

$fn = 160;

// Derived radii
pipe_or = pipe_outer_diameter_mm/2;
pipe_ir = pipe_or - pipe_stub_wall_mm;

cap_ir  = pipe_or + clearance_mm;                 // socket inner radius
cap_or  = cap_ir + cap_wall_thickness_mm;         // cap outer radius

// Heights
cap_h   = socket_insertion_depth_mm + end_face_thickness_mm;

// Z layout (cap centered at z=0)
cap_zmin = -cap_h/2;
cap_zmax =  cap_h/2;

// Socket opening at bottom, closed at top by end_face_thickness
socket_zmin = cap_zmin;
socket_zmax = cap_zmin + socket_insertion_depth_mm;

// Pipe stub placed so it inserts into socket with overlap
pipe_zmax = socket_zmax - connection_overlap_mm;
pipe_zmin = pipe_zmax - pipe_stub_length_mm;
pipe_zc   = (pipe_zmin + pipe_zmax)/2;

// Small robustness overlap for boolean ops
eps = 0.02;

// Cap geometry (hollow socket + closed end + grip band)
module ht_cap_75() {
  union() {
    // Main cap shell with internal cavity and lead-in chamfer
    difference() {
      // Outer body
      translate([0,0,(cap_zmin+cap_zmax)/2])
        cylinder(r=cap_or, h=cap_h, center=true);

      // Internal socket cavity (open at bottom, stops before top face)
      // Ensure it does NOT break through the closed end.
      translate([0,0,(socket_zmin + socket_zmax)/2])
        cylinder(r=cap_ir, h=(socket_zmax - socket_zmin) + eps, center=true);

      // Insertion stop shoulder ring (reduces ID slightly near socket end)
      // This creates a visible internal step.
      translate([0,0, socket_zmax - insertion_stop_shoulder_thickness_mm/2])
        cylinder(r=cap_ir - max(connection_overlap_mm, 0.6),
                 h=insertion_stop_shoulder_thickness_mm + eps,
                 center=true);

      // Lead-in chamfer at opening (bottom) on the INNER edge
      translate([0,0, socket_zmin + lead_in_chamfer_mm/2])
        cylinder(r1=cap_ir + lead_in_chamfer_mm,
                 r2=cap_ir,
                 h=lead_in_chamfer_mm + eps,
                 center=true);
    }

    // Outer grip band (connected, slightly larger OD)
    translate([0,0, cap_zmin + outer_grip_band_height_mm/2])
      cylinder(r=cap_or + outer_grip_band_depth_mm,
               h=outer_grip_band_height_mm,
               center=true);
  }
}

// Pipe stub (for visualization/assembly) - connected to cap via overlap
module ht_pipe_stub() {
  difference() {
    translate([0,0,pipe_zc])
      cylinder(r=pipe_or, h=pipe_stub_length_mm, center=true);

    translate([0,0,pipe_zc])
      cylinder(r=pipe_ir, h=pipe_stub_length_mm + eps, center=true);
  }
}

// One connected solid assembly
union() {
  ht_cap_75();
  ht_pipe_stub();
}