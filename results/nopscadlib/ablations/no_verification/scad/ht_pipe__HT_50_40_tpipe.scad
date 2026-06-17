$fn = 96;

// Parameters
main_nominal_diameter_mm = 50; //[25:100:1]
branch_nominal_diameter_mm = 40; //[20:80:1]
angle_deg = 90; //[45:135:1]
main_od = 56; //[28:112:0.5]
branch_od = 46; //[23:92:0.5]
wall_thickness = 2.8; //[1.4:5.6:0.1]
main_socket_length = 35; //[18:70:1]
branch_socket_length = 30; //[15:60:1]
main_center_body_length = 20; //[10:40:1]
branch_center_body_length = 18; //[9:36:1]
socket_stop_thickness = 2; //[1:4:0.25]
socket_stop_radial = 1.5; //[0.75:3:0.25]
overlap = 0.8; //[0.5:2:0.1]
ht_pipe_stub_length = 60; //[30:120:1]

// Derived
main_r = main_od/2;
branch_r = branch_od/2;
main_ir = max(0.01, main_r - wall_thickness);
branch_ir = max(0.01, branch_r - wall_thickness);

main_total_len = main_center_body_length + 2*main_socket_length;
branch_total_len = branch_center_body_length + branch_socket_length;

// Main axis along X, branch axis along Z
module cylX(r,h,center=true){ rotate([0,90,0]) cylinder(r=r,h=h,center=center); }
module cylZ(r,h,center=true){ cylinder(r=r,h=h,center=center); }

module ringX(r_outer, r_inner, h, center=true){
  difference(){
    cylX(r_outer, h, center=center);
    cylX(r_inner, h + 2*overlap, center=center);
  }
}

module ringZ(r_outer, r_inner, h, center=true){
  difference(){
    cylZ(r_outer, h, center=center);
    cylZ(r_inner, h + 2*overlap, center=center);
  }
}

module ht_t_pipe_50_40() {

  // Ensure the branch actually intersects the main tube (connected solid)
  // Put branch axis through main axis (classic T), with a tiny overlap for robustness.
  branch_axis_z = 0;

  // Outer union (one connected solid)
  module outer_shell(){
    union() {
      // Main run
      cylX(main_r, main_total_len, center=true);

      // Branch (vertical)
      translate([0,0,branch_axis_z])
        cylZ(branch_r, branch_total_len, center=true);

      // Optional stub on +X end (connected by formula)
      translate([ main_total_len/2 + ht_pipe_stub_length/2 - overlap, 0, 0 ])
        cylX(main_r, ht_pipe_stub_length, center=true);
    }
  }

  // Inner bores (subtracted)
  module inner_voids(){
    union() {
      cylX(main_ir, main_total_len + 2*overlap, center=true);

      translate([0,0,branch_axis_z])
        cylZ(branch_ir, branch_total_len + 2*overlap, center=true);

      translate([ main_total_len/2 + ht_pipe_stub_length/2 - overlap, 0, 0 ])
        cylX(main_ir, ht_pipe_stub_length + 2*overlap, center=true);
    }
  }

  // Socket stops as internal rings (added back after hollowing so they remain)
  module socket_stops(){
    union() {
      // Main left stop
      translate([ -(main_center_body_length/2 + main_socket_length) + socket_stop_thickness/2, 0, 0 ])
        ringX(main_ir, max(0.01, main_ir - socket_stop_radial), socket_stop_thickness, center=true);

      // Main right stop
      translate([ +(main_center_body_length/2 + main_socket_length) - socket_stop_thickness/2, 0, 0 ])
        ringX(main_ir, max(0.01, main_ir - socket_stop_radial), socket_stop_thickness, center=true);

      // Branch stop (at far end of branch socket)
      translate([0, 0, branch_axis_z + (branch_center_body_length/2 + branch_socket_length) - socket_stop_thickness/2 ])
        ringZ(branch_ir, max(0.01, branch_ir - socket_stop_radial), socket_stop_thickness, center=true);
    }
  }

  union() {
    difference() {
      outer_shell();
      inner_voids();
    }
    // Add stops back in (they are inside and connected to the wall)
    socket_stops();
  }
}

color([0.85, 0.85, 0.8]) ht_t_pipe_50_40();