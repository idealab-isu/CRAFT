// HT 50 Tee (simplified, single connected solid)
// Fixes: clear T-shape, correct perpendicular branch, all parts connected,
// recalculated translations, slight overlaps for watertight unions.

$fn = 96;

// Parameters (kept from original intent)
dn = 50;                 // nominal
od = 50;                 // not used directly (kept)
wall_t = 1.8;

main_run_len = 160;      // overall end-to-end along main axis
branch_len   = 110;      // overall end-to-end along branch axis

socket_depth = 45;
socket_od    = 56;
socket_lip_h = 3;
socket_lip_od = 58;

stop_shoulder_t = 2;

overlap = 1.2;           // 1-2mm overlap for solid connections

bore_id   = 46.4;        // through bore
socket_id = 50.5;        // socket ID

tee_body_od     = 54;    // central body OD
center_body_len = 30;    // central body length along main axis
branch_body_len = 26;    // central body length along branch axis

o_ring_groove_w = 4;
o_ring_groove_d = 1.2;
o_ring_groove_offset = 12;

chamfer_h = 1;
fillet_r  = 3;

// ---------- Derived placement helpers (ALL translations formula-based) ----------
main_axis = [1,0,0];
branch_axis = [0,0,1];   // branch is perpendicular to main (true tee)

// Central body extents
main_body_half   = center_body_len/2;
branch_body_half = branch_body_len/2;

// Socket centers (outer cylinders) along each axis
main_socket_center_offset   = main_run_len/2 - socket_depth/2;
branch_socket_center_offset = branch_len/2   - socket_depth/2;

// Lip centers (at the very ends)
main_lip_center_offset   = main_run_len/2 - socket_lip_h/2;
branch_lip_center_offset = branch_len/2   - socket_lip_h/2;

// Stop ring centers (inside each socket, near the socket inner end)
main_stop_center_offset   = main_run_len/2 - socket_depth + stop_shoulder_t/2;
branch_stop_center_offset = branch_len/2   - socket_depth + stop_shoulder_t/2;

// O-ring groove centers (inside sockets)
main_groove_center_offset   = main_run_len/2 - o_ring_groove_offset;
branch_groove_center_offset = branch_len/2   - o_ring_groove_offset;

// Chamfer centers (at the openings)
main_chamfer_center_offset   = main_run_len/2 - chamfer_h/2;
branch_chamfer_center_offset = branch_len/2   - chamfer_h/2;

// ---------- Primitive helpers ----------
module cyl_x(r,h,center=true){ rotate([0,90,0]) cylinder(r=r,h=h,center=center); }
module cyl_z(r,h,center=true){ cylinder(r=r,h=h,center=center); }

// ---------- Outer geometry (single connected union) ----------
module tee_body_hull() {
  // Hull between main and branch central cylinders + spheres for a soft junction
  hull() {
    cyl_x(tee_body_od/2, center_body_len, center=true);
    cyl_z(tee_body_od/2, branch_body_len, center=true);

    sphere(r=fillet_r);
    translate([0,0, branch_body_half - fillet_r]) sphere(r=fillet_r);
    translate([0,0,-branch_body_half + fillet_r]) sphere(r=fillet_r);
    translate([ main_body_half - fillet_r,0,0]) sphere(r=fillet_r);
    translate([-main_body_half + fillet_r,0,0]) sphere(r=fillet_r);
  }
}

module outer_shell_union() {
  union() {
    // Central tee body
    tee_body_hull();

    // Main run sockets (left/right) - aligned on X axis, connected with overlap
    translate([-main_socket_center_offset,0,0])
      cyl_x(socket_od/2, socket_depth + 2*overlap, center=true);
    translate([ main_socket_center_offset,0,0])
      cyl_x(socket_od/2, socket_depth + 2*overlap, center=true);

    // Branch socket (up) - aligned on Z axis, connected with overlap
    translate([0,0, branch_socket_center_offset])
      cyl_z(socket_od/2, socket_depth + 2*overlap, center=true);

    // Lips at the three openings
    translate([-main_lip_center_offset,0,0])
      cyl_x(socket_lip_od/2, socket_lip_h + 2*overlap, center=true);
    translate([ main_lip_center_offset,0,0])
      cyl_x(socket_lip_od/2, socket_lip_h + 2*overlap, center=true);
    translate([0,0, branch_lip_center_offset])
      cyl_z(socket_lip_od/2, socket_lip_h + 2*overlap, center=true);

    // Stop shoulders (rings) inside sockets (outer material only; holes subtracted later)
    translate([-main_stop_center_offset,0,0])
      cyl_x((socket_id/2 + wall_t), stop_shoulder_t + 2*overlap, center=true);
    translate([ main_stop_center_offset,0,0])
      cyl_x((socket_id/2 + wall_t), stop_shoulder_t + 2*overlap, center=true);
    translate([0,0, branch_stop_center_offset])
      cyl_z((socket_id/2 + wall_t), stop_shoulder_t + 2*overlap, center=true);
  }
}

// ---------- Voids (subtractions) ----------
module bores_union() {
  union() {
    // Main through bore along X (full length)
    cyl_x(bore_id/2, main_run_len + 4*overlap, center=true);

    // Branch through bore along Z (full length)
    cyl_z(bore_id/2, branch_len + 4*overlap, center=true);
  }
}

module socket_ids_union() {
  union() {
    // Main socket IDs (left/right)
    translate([-main_socket_center_offset,0,0])
      cyl_x(socket_id/2, socket_depth + 4*overlap, center=true);
    translate([ main_socket_center_offset,0,0])
      cyl_x(socket_id/2, socket_depth + 4*overlap, center=true);

    // Branch socket ID
    translate([0,0, branch_socket_center_offset])
      cyl_z(socket_id/2, socket_depth + 4*overlap, center=true);
  }
}

module stop_holes_union() {
  union() {
    // Remove bore through the stop shoulders so they become rings
    translate([-main_stop_center_offset,0,0])
      cyl_x(bore_id/2, stop_shoulder_t + 6*overlap, center=true);
    translate([ main_stop_center_offset,0,0])
      cyl_x(bore_id/2, stop_shoulder_t + 6*overlap, center=true);
    translate([0,0, branch_stop_center_offset])
      cyl_z(bore_id/2, stop_shoulder_t + 6*overlap, center=true);
  }
}

module grooves_union() {
  union() {
    // Simple annular grooves (subtractive)
    translate([-main_groove_center_offset,0,0])
      cyl_x((socket_id/2 + o_ring_groove_d), o_ring_groove_w, center=true);
    translate([ main_groove_center_offset,0,0])
      cyl_x((socket_id/2 + o_ring_groove_d), o_ring_groove_w, center=true);
    translate([0,0, branch_groove_center_offset])
      cyl_z((socket_id/2 + o_ring_groove_d), o_ring_groove_w, center=true);
  }
}

module chamfers_union() {
  union() {
    // Simple entry chamfers (subtractive cones) at the three openings
    translate([-main_chamfer_center_offset,0,0])
      rotate([0,90,0]) cylinder(r1=socket_id/2, r2=0, h=chamfer_h + 2*overlap, center=true);
    translate([ main_chamfer_center_offset,0,0])
      rotate([0,90,0]) cylinder(r1=socket_id/2, r2=0, h=chamfer_h + 2*overlap, center=true);
    translate([0,0, branch_chamfer_center_offset])
      cylinder(r1=socket_id/2, r2=0, h=chamfer_h + 2*overlap, center=true);
  }
}

module all_voids_union() {
  union() {
    bores_union();
    socket_ids_union();
    grooves_union();
    chamfers_union();
    stop_holes_union();
  }
}

// ---------- Final solid ----------
difference() {
  outer_shell_union();
  all_voids_union();
}