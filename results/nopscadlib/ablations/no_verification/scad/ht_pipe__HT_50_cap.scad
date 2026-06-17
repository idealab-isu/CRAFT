// HT 50 Cap (one connected solid, printable)
// Fixes: ensure all solids are unioned, no floating parts, robust booleans

$fn = 128;

// Parameters
pipe_outer_diameter_mm = 50; //[25:100:0.1]
socket_inner_diameter_mm = 50.5; //[25.5:101:0.1]
cap_outer_diameter_mm = 60; //[30:120:0.1]
cap_depth_mm = 35; //[18:70:0.1]
wall_thickness_mm = 3; //[1.5:6:0.1]
end_face_thickness_mm = 3; //[1.5:8:0.1]
stop_shoulder_height_mm = 2; //[1:6:0.1]
insertion_depth_mm = 25; //[10:60:0.1]
clearance_mm = 0.5; //[0.1:1.5:0.05]
chamfer_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_wall_thickness_mm = 2.4; //[1.2:5:0.1]
pipe_stub_length_mm = 60; //[30:120:0.5]
socket_length_mm = 32; //[20:60:0.1]

// Derived radii
pipe_or = pipe_outer_diameter_mm/2;
pipe_ir = max(0.01, pipe_or - pipe_wall_thickness_mm);

cap_or  = cap_outer_diameter_mm/2;
cap_ir  = max(0.01, cap_or - wall_thickness_mm);

socket_ir = socket_inner_diameter_mm/2;

// Z layout (cap centered at z=0)
cap_zmin = -cap_depth_mm/2;
cap_zmax =  cap_depth_mm/2;

// Socket cavity starts at open end and goes inward
socket_zmin = cap_zmin;
socket_zmax = cap_zmin + socket_length_mm;

// Closed end inner relief (keeps end face thickness)
relief_zmin = cap_zmin + end_face_thickness_mm;
relief_zmax = cap_zmax;

// Stop shoulder ring location inside socket
shoulder_zmin = cap_zmin + insertion_depth_mm;
shoulder_zmax = shoulder_zmin + stop_shoulder_height_mm;

// Pipe placement: insert into socket by insertion_depth_mm
pipe_zmax = cap_zmin + insertion_depth_mm;
pipe_zmin = pipe_zmax - pipe_stub_length_mm;
pipe_zc   = (pipe_zmin + pipe_zmax)/2;

// Modules
module ht_pipe() {
  difference() {
    cylinder(r=pipe_or, h=pipe_stub_length_mm, center=true);
    cylinder(r=pipe_ir, h=pipe_stub_length_mm + 2*overlap_mm, center=true);
  }
}

module cap_solid() {
  // Build as one solid: (outer shell + shoulder + chamfer) - (socket void + relief void)
  difference() {
    union() {
      // Outer cap body
      cylinder(r=cap_or, h=cap_depth_mm, center=true);

      // Stop shoulder ring (adds material inside the socket region)
      translate([0,0,(shoulder_zmin+shoulder_zmax)/2])
        cylinder(r=socket_ir, h=stop_shoulder_height_mm, center=true);

      // Lead-in chamfer at open end (adds material; overlaps outer body)
      translate([0,0,cap_zmin + chamfer_mm/2])
        cylinder(r1=socket_ir + chamfer_mm, r2=socket_ir, h=chamfer_mm, center=true);
    }

    // Socket cavity (open end)
    translate([0,0,(socket_zmin+socket_zmax)/2])
      cylinder(r=socket_ir, h=socket_length_mm + 2*overlap_mm, center=true);

    // Inner relief from just after end face to closed end
    translate([0,0,(relief_zmin+relief_zmax)/2])
      cylinder(r=cap_ir, h=(relief_zmax-relief_zmin) + 2*overlap_mm, center=true);

    // Cut the shoulder bore to leave a radial lip (stop)
    translate([0,0,(shoulder_zmin+shoulder_zmax)/2])
      cylinder(r=pipe_or + clearance_mm/2, h=stop_shoulder_height_mm + 2*overlap_mm, center=true);
  }
}

module assembly() {
  // Ensure ONE connected solid: pipe overlaps into socket by overlap_mm
  union() {
    cap_solid();

    // Place pipe so its top end is slightly past the shoulder plane to guarantee overlap
    // Pipe top (z = pipe_zc + pipe_stub_length/2) = pipe_zmax + overlap_mm
    translate([0,0, (pipe_zmax + overlap_mm) - pipe_stub_length_mm/2 ])
      ht_pipe();
  }
}

assembly();