$fn = 128;

// Parameters
nominal_diameter_mm = 160; //[80:320:1]
pipe_od_mm = 160; //[80:320:1]
pipe_wall_mm = 4; //[2:8:0.5]
pipe_length_mm = 120; //[60:240:1]
cap_outer_wall_mm = 6; //[3:12:0.5]
socket_depth_mm = 70; //[35:140:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
end_wall_thickness_mm = 8; //[4:16:0.5]
cap_extra_length_mm = 10; //[5:30:1]
overlap_mm = 1; //[0.5:2:0.1]
include_socket = 1; //[0:1:1]
include_end_wall = 1; //[0:1:1]
center = 0; //[0:1:1]
cap_outer_diameter_mm = 172; //[140:220:1]

// Derived
pipe_r_o = pipe_od_mm/2;
pipe_r_i = pipe_r_o - pipe_wall_mm;

cap_r_o = cap_outer_diameter_mm/2;
cap_r_i = cap_r_o - cap_outer_wall_mm;

end_wall = include_end_wall ? end_wall_thickness_mm : 0;
cap_h_total = socket_depth_mm + cap_extra_length_mm + end_wall;

// Place cap so its socket overlaps the pipe end (connected solid)
cap_z0 = pipe_length_mm - socket_depth_mm + overlap_mm; // cap bottom z

// Safety / robustness eps
eps = 0.01;

module ht_pipe() {
  difference() {
    cylinder(r=pipe_r_o, h=pipe_length_mm, center=false);
    translate([0,0,-overlap_mm])
      cylinder(r=pipe_r_i, h=pipe_length_mm + 2*overlap_mm, center=false);
  }
}

module ht_cap() {
  // Closed-end sleeve:
  // Outer cylinder full height.
  // Inner cavity starts at bottom and stops before the end wall.
  // Socket clearance enlarges only the socket region.
  difference() {
    translate([0,0,cap_z0])
      cylinder(r=cap_r_o, h=cap_h_total, center=false);

    // Inner cavity (leave end wall thickness at the top if enabled)
    translate([0,0,cap_z0 - overlap_mm])
      cylinder(
        r = cap_r_i,
        h = (cap_h_total - end_wall) + 2*overlap_mm,
        center=false
      );

    // Socket clearance for pipe OD (only in socket region)
    if (include_socket) {
      translate([0,0,cap_z0 - overlap_mm])
        cylinder(
          r = pipe_r_o + socket_clearance_mm,
          h = socket_depth_mm + 2*overlap_mm,
          center=false
        );
    }
  }
}

module assembly() {
  // Ensure ONE connected solid by forcing a tiny overlap union between pipe and cap
  union() {
    ht_pipe();
    ht_cap();

    // Connection "stitch" ring at the interface (guarantees manifold union even with tolerances)
    // Located where cap socket meets pipe end.
    translate([0,0,pipe_length_mm - overlap_mm])
      cylinder(r=pipe_r_o + eps, h=2*overlap_mm, center=false);
  }
}

// Optional centering
if (center)
  translate([0,0,-(pipe_length_mm + cap_h_total)/2])
    assembly();
else
  assembly();