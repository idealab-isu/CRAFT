// Parameters
nominal_diameter_dn_mm = 110; //[55:220:1]
pipe_od_mm = 110; //[55:220:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
socket_depth_mm = 55; //[28:110:1]
cap_end_thickness_mm = 6; //[3:12:0.5]
cap_outer_wall_mm = 4; //[2:8:0.5]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
rim_radial_extra_mm = 6; //[3:12:0.5]
rim_axial_height_mm = 10; //[5:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]
pipe_stub_length_mm = 120; //[60:240:1]
center = 0; //[0:1:1]

$fn = 128;

// Derived
pipe_r      = pipe_od_mm/2;
pipe_ir     = max(0.01, pipe_r - pipe_wall_mm);

socket_r    = (pipe_od_mm + 2*socket_clearance_mm)/2;
cap_outer_r = socket_r + cap_outer_wall_mm;
rim_outer_r = cap_outer_r + rim_radial_extra_mm;

cap_total_h = socket_depth_mm + cap_end_thickness_mm;

// Build as ONE connected solid (cap + pipe stub fused with overlap)
module ht110_cap_with_stub() {
  // Optional centering
  z0 = center ? -cap_total_h/2 : 0;

  translate([0,0,z0])
  color([0.85, 0.85, 0.8])
  union() {

    // CAP: outer body + rim, with socket cavity removed
    difference() {
      union() {
        // Main cap outer body (closed end at top, open end at bottom)
        cylinder(h=cap_total_h, r=cap_outer_r, center=false);

        // Outer rim at open end (bottom)
        cylinder(h=rim_axial_height_mm, r=rim_outer_r, center=false);
      }

      // Socket void: open at bottom, stops at closed end thickness
      // Start at z=0 (open end), extend up to cap_total_h - cap_end_thickness_mm
      translate([0, 0, 0])
        cylinder(h=socket_depth_mm + overlap_mm, r=socket_r, center=false);
    }

    // PIPE STUB: placed so it overlaps into the socket region (ensures connectivity)
    // Stub outer starts at open end and extends downward; overlap into cap by overlap_mm
    // Outer: z = -pipe_stub_length_mm .. +overlap_mm
    // Inner: same, slightly longer to guarantee clean subtraction
    difference() {
      translate([0, 0, -pipe_stub_length_mm])
        cylinder(h=pipe_stub_length_mm + overlap_mm, r=pipe_r, center=false);

      translate([0, 0, -pipe_stub_length_mm - overlap_mm])
        cylinder(h=pipe_stub_length_mm + 2*overlap_mm, r=pipe_ir, center=false);
    }
  }
}

ht110_cap_with_stub();