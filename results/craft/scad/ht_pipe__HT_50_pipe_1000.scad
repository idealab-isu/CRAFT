// HT 50 pipe 1000 mm (with optional socket end)
// All dimensions in mm

$fn = 128;

// Parameters
length_mm = 1000; //[500:2000:10]
ht50_outer_diameter_mm = 50; //[40:100:1]
ht50_wall_thickness_mm = 1.8; //[1:4:0.1]
include_socket_end = 1; //[0:1:1]
socket_length_mm = 45; //[25:90:1]
socket_wall_extra_mm = 2.2; //[1:6:0.1]
socket_clearance_mm = 0.4; //[0.1:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Derived
outer_r = ht50_outer_diameter_mm/2;
inner_r = outer_r - ht50_wall_thickness_mm;
socket_outer_r = outer_r + socket_wall_extra_mm;
socket_inner_r = outer_r + socket_clearance_mm;

// Safety
inner_r_safe = max(0.01, inner_r);
socket_inner_r_safe = max(0.01, socket_inner_r);

// Main pipe (hollow)
module ht_pipe() {
  difference() {
    cylinder(h=length_mm, r=outer_r, center=false);
    translate([0, 0, -overlap_mm])
      cylinder(h=length_mm + 2*overlap_mm, r=inner_r_safe, center=false);
  }
}

// Socket end (hollow sleeve) connected to pipe end with overlap
module socket_end_fitting() {
  // Place socket so it starts slightly before pipe end to guarantee connection
  socket_z0 = length_mm - overlap_mm; // start position (z) of socket outer
  difference() {
    translate([0, 0, socket_z0])
      cylinder(h=socket_length_mm + overlap_mm, r=socket_outer_r, center=false);
    translate([0, 0, socket_z0 - overlap_mm])
      cylinder(h=socket_length_mm + 3*overlap_mm, r=socket_inner_r_safe, center=false);
  }
}

// Assembly: one connected solid
color([0.85, 0.85, 0.8])
union() {
  ht_pipe();
  if (include_socket_end) socket_end_fitting();
}