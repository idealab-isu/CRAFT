$fn = 128;

// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1500; //[750:3000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_length_mm = 70; //[35:140:1]
socket_wall_extra_mm = 2.0; //[1.0:4.0:0.1]
socket_overlap_mm = 1.0; //[0.5:2.0:0.1]
socket_inner_clearance_mm = 0.6; //[0.2:1.5:0.1]
chamfer_length_mm = 6; //[3:12:1]

// Derived diameters (keep consistent and parametric)
pipe_od_mm   = nominal_diameter_mm;
pipe_id_mm   = pipe_od_mm - 2*wall_thickness_mm;

socket_id_mm = pipe_od_mm + socket_inner_clearance_mm;
socket_od_mm = socket_id_mm + 2*(wall_thickness_mm + socket_wall_extra_mm);

// Small epsilon to avoid coplanar faces in boolean ops
eps = 0.05;

// HT Pipe - one connected solid
module ht_pipe() {
  color([0.85, 0.85, 0.8])  // PVC-like
  union() {
    // Main pipe body: z from 0..length_mm
    difference() {
      cylinder(r=pipe_od_mm/2, h=length_mm, center=false);
      translate([0,0,-eps])
        cylinder(r=pipe_id_mm/2, h=length_mm + 2*eps, center=false);
    }

    // Socket on one end: overlaps into pipe by socket_overlap_mm to ensure connectivity
    // Socket z from -socket_overlap_mm .. (socket_length_mm - socket_overlap_mm)
    translate([0,0,-socket_overlap_mm])
    difference() {
      cylinder(r=socket_od_mm/2, h=socket_length_mm, center=false);

      // Socket bore
      translate([0,0,-eps])
        cylinder(r=socket_id_mm/2, h=socket_length_mm + 2*eps, center=false);

      // Inner lead-in chamfer at socket mouth (z=0 end of socket local coords)
      translate([0,0,-eps])
        cylinder(r1=socket_id_mm/2 + chamfer_length_mm,
                 r2=socket_id_mm/2,
                 h=chamfer_length_mm + eps,
                 center=false);
    }
  }
}

ht_pipe();