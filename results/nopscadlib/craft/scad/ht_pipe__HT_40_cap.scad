$fn = 128;

// Parameters
nominal_size_mm = 40; //[20:80:1]
pipe_outer_diameter_mm = 40; //[30:60:0.1]
cap_outer_diameter_mm = 50; //[40:80:0.1]
cap_length_mm = 35; //[20:70:0.1]
socket_inner_diameter_mm = 40.5; //[40.1:41.5:0.05]
wall_thickness_mm = 3; //[1.5:6:0.1]
insertion_depth_mm = 25; //[15:50:0.1]
end_thickness_mm = 4; //[2:10:0.1]
chamfer_mm = 1; //[0:3:0.1]
pipe_wall_mm = 2.2; //[1.2:4.5:0.1]
pipe_length_mm = 60; //[30:120:1]
overlap_mm = 1; //[0.5:2:0.1]
stop_ring_axial_thickness_mm = 3; //[1.5:6:0.1]
stop_ring_radial_height_mm = 1.5; //[0.8:3:0.1]

eps = 0.01;

// Derived / clamped values to avoid invalid (blank) geometry
cap_r = cap_outer_diameter_mm/2;
pipe_r = pipe_outer_diameter_mm/2;
pipe_ir = max(eps, pipe_r - pipe_wall_mm);

socket_r = socket_inner_diameter_mm/2;

// Ensure socket depth fits inside cap while keeping end thickness
socket_depth = min(insertion_depth_mm, max(eps, cap_length_mm - end_thickness_mm));
chamfer_h = min(chamfer_mm, socket_depth);

// Stop ring: a small internal step near the end of the socket
ring_ax_h = min(stop_ring_axial_thickness_mm, socket_depth);
ring_r = max(eps, socket_r - stop_ring_radial_height_mm);

// HT Pipe - complete geometry
module ht_pipe() {
  difference() {
    cylinder(h=pipe_length_mm, r=pipe_r, center=true);
    translate([0, 0, -overlap_mm/2])
      cylinder(h=pipe_length_mm + overlap_mm, r=pipe_ir, center=true);
  }
}

// Cap (single connected solid; stop ring integrated)
module cap() {
  difference() {
    // Outer cap body
    cylinder(h=cap_length_mm, r=cap_r, center=true);

    // Inner voids
    union() {
      // Main socket cavity (from opening inward)
      translate([0, 0, -cap_length_mm/2 + socket_depth/2])
        cylinder(h=socket_depth + overlap_mm, r=socket_r, center=true);

      // Chamfer at opening (only if > 0)
      if (chamfer_h > eps)
        translate([0, 0, -cap_length_mm/2 + chamfer_h/2])
          cylinder(h=chamfer_h + overlap_mm,
                   r1=socket_r + chamfer_h,
                   r2=socket_r, center=true);

      // Clearance behind stop ring: smaller radius, starts after ring, ends before closed end
      clearance_start = ring_ax_h;
      clearance_h = max(eps, socket_depth - clearance_start);
      translate([0, 0, -cap_length_mm/2 + clearance_start + clearance_h/2])
        cylinder(h=clearance_h + overlap_mm, r=ring_r, center=true);
    }
  }
}

// Assembly: ensure ONE connected solid by overlapping pipe into socket
module assembly() {
  union() {
    cap();

    // Cap opening plane is at z = -cap_length_mm/2
    // Place pipe so its top end is inside the socket by (socket_depth - overlap_mm)
    pipe_center_z =
      (-cap_length_mm/2 + (socket_depth - overlap_mm)) - pipe_length_mm/2;

    translate([0, 0, pipe_center_z])
      ht_pipe();
  }
}

assembly();