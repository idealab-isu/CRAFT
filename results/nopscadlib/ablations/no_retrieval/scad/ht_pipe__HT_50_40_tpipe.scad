// HT 50/40 T-pipe (three-port tee): main run DN50, branch DN40
// One connected solid, no stray geometry, all placements derived from dimensions.

$fn = 96;

// Parameters
main_od_dn50      = 50;   //[25:100:1]
branch_od_dn40    = 40;   //[20:80:1]
wall_t            = 2.0;  //[1.0:4.0:0.1]

main_run_len      = 120;  //[60:240:1]   // overall length along main axis
branch_len        = 70;   //[35:140:1]   // overall length along branch axis

socket_len_dn50   = 35;   //[18:70:1]
socket_len_dn40   = 30;   //[15:60:1]
socket_od_extra   = 6;    //[3:12:1]

branch_angle_deg  = 90;   //[45:90:1]    // 90 = true tee
junction_blend_r  = 8;    //[4:16:1]

overlap           = 1.0;  //[0.5:2.0:0.1]
chamfer_len       = 2.0;  //[1.0:5.0:0.1]

seal_groove_w     = 4.0;  //[2.0:8.0:0.1]
seal_groove_d     = 1.2;  //[0.6:2.4:0.1]
socket_wall_extra = 1.0;  //[0.5:2.0:0.1]

// Derived radii
main_r_outer   = main_od_dn50/2;
branch_r_outer = branch_od_dn40/2;

main_r_inner   = main_r_outer   - wall_t;
branch_r_inner = branch_r_outer - wall_t;

// Socket radii (outer bulge + slightly larger inner bore)
main_socket_r_outer   = (main_od_dn50   + socket_od_extra)/2;
branch_socket_r_outer = (branch_od_dn40 + socket_od_extra)/2;

main_socket_r_inner   = main_r_inner   - socket_wall_extra;
branch_socket_r_inner = branch_r_inner - socket_wall_extra;

// Ensure valid radii
assert(main_r_inner > 0 && branch_r_inner > 0, "wall_t too large");
assert(main_socket_r_inner > 0 && branch_socket_r_inner > 0, "socket_wall_extra too large");

// Length splits
main_mid_len   = main_run_len - 2*socket_len_dn50;
branch_mid_len = branch_len   - socket_len_dn40;

// Axis conventions:
// - Main run along X
// - Branch along +Y (rotated by branch_angle_deg around Z from +X to +Y when 90deg)
module cyl_x(r, h, center=true) { rotate([0,90,0]) cylinder(r=r, h=h, center=center); }
module cyl_y(r, h, center=true) { rotate([-90,0,0]) cylinder(r=r, h=h, center=center); }

// Outer geometry
module outer_main_mid() {
  cyl_x(main_r_outer, main_mid_len, center=true);
}

module outer_main_socket_left() {
  translate([-(main_run_len/2 - socket_len_dn50/2) + overlap, 0, 0])
    cyl_x(main_socket_r_outer, socket_len_dn50, center=true);
}

module outer_main_socket_right() {
  translate([(main_run_len/2 - socket_len_dn50/2) - overlap, 0, 0])
    cyl_x(main_socket_r_outer, socket_len_dn50, center=true);
}

module outer_branch_mid() {
  // Branch starts at junction (y=0) and extends to +Y
  translate([0, (branch_mid_len/2) - overlap, 0])
    cyl_y(branch_r_outer, branch_mid_len, center=true);
}

module outer_branch_socket() {
  translate([0, (branch_len - socket_len_dn40/2) - overlap, 0])
    cyl_y(branch_socket_r_outer, socket_len_dn40, center=true);
}

module outer_junction_blend() {
  // Smoothly connect main and branch with a hull of two spheres at the intersection
  hull() {
    sphere(r=main_r_outer + junction_blend_r);
    translate([0, main_r_outer - overlap, 0])
      sphere(r=branch_r_outer + junction_blend_r);
  }
}

module outer_shell() {
  union() {
    outer_main_mid();
    outer_main_socket_left();
    outer_main_socket_right();
    rotate([0,0,branch_angle_deg-90]) { // keep default 90 as +Y; allow other angles
      outer_branch_mid();
      outer_branch_socket();
      outer_junction_blend();
    }
  }
}

// Inner flow (void)
module inner_main_bore() {
  // Full-length bore through main run
  cyl_x(main_r_inner, main_run_len + 2*overlap, center=true);
}

module inner_branch_bore() {
  // Full-length bore through branch
  translate([0, branch_len/2 - overlap, 0])
    cyl_y(branch_r_inner, branch_len + 2*overlap, center=true);
}

module inner_main_socket_left() {
  translate([-(main_run_len/2 - socket_len_dn50/2) + overlap, 0, 0])
    cyl_x(main_socket_r_inner, socket_len_dn50 + 2*overlap, center=true);
}

module inner_main_socket_right() {
  translate([(main_run_len/2 - socket_len_dn50/2) - overlap, 0, 0])
    cyl_x(main_socket_r_inner, socket_len_dn50 + 2*overlap, center=true);
}

module inner_branch_socket() {
  translate([0, (branch_len - socket_len_dn40/2) - overlap, 0])
    cyl_y(branch_socket_r_inner, socket_len_dn40 + 2*overlap, center=true);
}

module inner_void() {
  union() {
    inner_main_bore();
    inner_main_socket_left();
    inner_main_socket_right();
    rotate([0,0,branch_angle_deg-90]) {
      inner_branch_bore();
      inner_branch_socket();
    }
  }
}

// Lead-in chamfers (cutters)
module chamfer_main_left() {
  // Cone at left end, aligned with X
  translate([-(main_run_len/2) + chamfer_len/2, 0, 0])
    rotate([0,90,0])
      cylinder(r1=main_socket_r_inner, r2=0, h=chamfer_len, center=true);
}

module chamfer_main_right() {
  translate([(main_run_len/2) - chamfer_len/2, 0, 0])
    rotate([0,-90,0])
      cylinder(r1=main_socket_r_inner, r2=0, h=chamfer_len, center=true);
}

module chamfer_branch_end() {
  translate([0, branch_len - chamfer_len/2, 0])
    rotate([-90,0,0])
      cylinder(r1=branch_socket_r_inner, r2=0, h=chamfer_len, center=true);
}

module chamfers_all() {
  union() {
    chamfer_main_left();
    chamfer_main_right();
    rotate([0,0,branch_angle_deg-90]) chamfer_branch_end();
  }
}

// Seal grooves (cutters) near socket mouths
module groove_main_left() {
  // Place groove just inside left socket mouth
  translate([-(main_run_len/2 - chamfer_len - seal_groove_w/2) + overlap, 0, 0])
    cyl_x(main_socket_r_inner + seal_groove_d, seal_groove_w, center=true);
}

module groove_main_right() {
  translate([(main_run_len/2 - chamfer_len - seal_groove_w/2) - overlap, 0, 0])
    cyl_x(main_socket_r_inner + seal_groove_d, seal_groove_w, center=true);
}

module groove_branch() {
  translate([0, (branch_len - chamfer_len - seal_groove_w/2) - overlap, 0])
    cyl_y(branch_socket_r_inner + seal_groove_d, seal_groove_w, center=true);
}

module grooves_all() {
  union() {
    groove_main_left();
    groove_main_right();
    rotate([0,0,branch_angle_deg-90]) groove_branch();
  }
}

// Final solid
difference() {
  difference() {
    outer_shell();
    inner_void();
  }
  chamfers_all();
  grooves_all();
}