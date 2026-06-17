// IEC switched fused inlet module (approx) 40.0mm x 27.0mm
// One connected solid, with recognizable front IEC C14 opening, fuse drawer, and rocker switch.
// Front face of bezel at z = 0, body extends to negative z.

$fn = 64;

// ---------------- Parameters ----------------
flange_width_mm  = 40.0;
flange_height_mm = 27.0;

bezel_lip_mm        = 1.2;
bezel_thickness_mm  = 1.6;
flange_thickness_mm = 2.0;

bezel_radius_mm = 2.0;

body_depth_mm  = 30.0;
body_width_mm  = 30.0;
body_height_mm = 22.0;

overlap_mm = 1.5; // ensure 1-2mm overlap for all attachments

// Mounting
screw_hole_diameter_mm = 3.2;
screw_hole_pitch_x_mm  = 32.0;
screw_hole_pitch_y_mm  = 19.0;

// IEC C14 opening (front)
iec_c14_w_mm     = 27.5;
iec_c14_h_mm     = 20.0;
iec_c14_depth_mm = 12.0;
iec_key_w_mm     = 10.0;
iec_key_h_mm     = 4.0;

// Switch + fuse (front features)
rocker_opening_width_mm  = 19.0;
rocker_opening_height_mm = 13.0;
rocker_opening_offset_y_mm = 6.0;
switch_recess_depth_mm   = 3.2;

fuse_opening_width_mm   = 16.0;
fuse_opening_height_mm  = 10.0;
fuse_opening_offset_y_mm = -6.5;

fuse_drawer_depth_mm    = 12.0;
fuse_drawer_protrude_mm = 2.0;
fuse_drawer_wall_mm     = 1.2;

// Rear terminals
terminal_spade_width_mm     = 6.3;
terminal_spade_thickness_mm = 0.8;
spade_length_mm             = 12.0;
spade_spacing_x_mm          = 10.0;

// Panel cutout relief (rear of flange)
panel_cutout_clearance_mm = 0.2;
panel_cutout_width_mm  = 30.0;
panel_cutout_height_mm = 22.0;

// Rear terminal block (the "blue" protruding block) - MUST be attached
terminal_block_w_mm = 18.0;
terminal_block_h_mm = 12.0;
terminal_block_d_mm = 8.0;

// Teal collar/connector between body and terminal block (to eliminate any visible gap)
collar_d_mm = 4.0; // axial thickness of collar
collar_r_mm = 5.0; // radius of collar cylinder

// ---------------- Helpers ----------------
module rounded_box(size=[10,10,10], r=1, center=true) {
  rr = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
  if (rr <= 0.01) cube(size, center=center);
  else minkowski() {
    cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=center);
    sphere(r=rr);
  }
}

// ---------------- Model ----------------
module iec_switched_fused_inlet_40x27() {

  // Z layout (front at z=0)
  z_bezel_center  = -bezel_thickness_mm/2;
  z_flange_center = -(bezel_thickness_mm + flange_thickness_mm/2);

  // Body overlaps into flange to guarantee connectivity
  body_front_overlap_mm = overlap_mm;
  z_body_center = -(bezel_thickness_mm + flange_thickness_mm + body_depth_mm/2 - body_front_overlap_mm);
  z_body_rear_face = z_body_center - body_depth_mm/2;

  // Fuse drawer block protrudes out of front, but overlaps into bezel
  fuse_block_h = fuse_drawer_depth_mm + fuse_drawer_protrude_mm + overlap_mm;
  z_fuse_block_center = fuse_drawer_protrude_mm/2 - fuse_drawer_depth_mm/2; // spans from +protrude to -depth

  // Switch recess cut depth
  z_switch_cut_center = -switch_recess_depth_mm/2 + overlap_mm*0.25;

  // IEC cut depth (goes into body)
  iec_cut_depth = max(iec_c14_depth_mm, bezel_thickness_mm + flange_thickness_mm + 6);
  z_iec_cut_center = -iec_cut_depth/2 + overlap_mm*0.25;

  // --- Rear attachment stack (body -> collar -> terminal block) ---
  // Collar is centered just behind the body rear face, overlapping into the body by overlap_mm.
  collar_z_center = (z_body_rear_face - overlap_mm) - collar_d_mm/2;

  // Terminal block is centered behind the collar, overlapping into the collar by overlap_mm.
  collar_rear_face = collar_z_center - collar_d_mm/2;
  terminal_block_z_center = (collar_rear_face + overlap_mm) - terminal_block_d_mm/2;

  // Terminal block rear face (for spade placement)
  terminal_block_rear_face = terminal_block_z_center - terminal_block_d_mm/2;

  difference() {
    union() {
      // Bezel (outer frame)
      translate([0,0,z_bezel_center])
        rounded_box(
          [flange_width_mm + 2*bezel_lip_mm,
           flange_height_mm + 2*bezel_lip_mm,
           bezel_thickness_mm],
          r=bezel_radius_mm,
          center=true
        );

      // Flange plate (behind bezel) with overlap into bezel
      translate([0,0,z_flange_center + overlap_mm/2])
        rounded_box(
          [flange_width_mm,
           flange_height_mm,
           flange_thickness_mm + overlap_mm],
          r=max(0.6, bezel_radius_mm*0.6),
          center=true
        );

      // Main body (behind flange) with overlap into flange
      translate([0,0,z_body_center])
        rounded_box(
          [body_width_mm,
           body_height_mm,
           body_depth_mm + overlap_mm],
          r=1.2,
          center=true
        );

      // Fuse drawer protrusion block (front feature), connected by overlap into bezel
      translate([0, fuse_opening_offset_y_mm, z_fuse_block_center])
        rounded_box(
          [fuse_opening_width_mm + 2*fuse_drawer_wall_mm,
           fuse_opening_height_mm + 2*fuse_drawer_wall_mm,
           fuse_block_h],
          r=1.0,
          center=true
        );

      // Teal collar/connector (ensures no gap between body and terminal block)
      // Overlaps into body by overlap_mm and into terminal block by overlap_mm.
      translate([0, 0, collar_z_center])
        cylinder(r=collar_r_mm, h=collar_d_mm, center=true);

      // Rear terminal block - attached to collar (and thus to body) with overlap
      translate([0, 0, terminal_block_z_center])
        rounded_box(
          [terminal_block_w_mm, terminal_block_h_mm, terminal_block_d_mm],
          r=1.0,
          center=true
        );

      // Rear terminal spades (3: L, N, E) - overlap into terminal block by overlap_mm
      // Place spades so their FRONT face is inside the terminal block by overlap_mm.
      spade_z_center = (terminal_block_rear_face) - spade_length_mm/2 + overlap_mm;
      for (x = [-spade_spacing_x_mm/2, 0, spade_spacing_x_mm/2])
        translate([x, 0, spade_z_center])
          cube([terminal_spade_width_mm, terminal_spade_thickness_mm, spade_length_mm], center=true);

      // Small rear bump (strain relief / molding detail), connected (overlap into body)
      bump_r = 6;
      bump_h = 6;
      translate([0, -body_height_mm*0.15, z_body_rear_face - bump_h/2 + overlap_mm])
        cylinder(r=bump_r, h=bump_h, center=true);
    }

    // -------- Subtractions --------

    // Panel cutout relief on rear side of flange (visual cue)
    translate([0,0,z_flange_center])
      cube([panel_cutout_width_mm + 2*panel_cutout_clearance_mm,
            panel_cutout_height_mm + 2*panel_cutout_clearance_mm,
            flange_thickness_mm + 2*overlap_mm],
           center=true);

    // IEC C14 inlet opening (front) - cut through bezel+flange and into body
    translate([0, 0, z_iec_cut_center])
      cube([iec_c14_w_mm, iec_c14_h_mm, iec_cut_depth + overlap_mm], center=true);

    // Key notch (top center) to suggest C14 profile
    translate([0, iec_c14_h_mm/2 - iec_key_h_mm/2, z_iec_cut_center])
      cube([iec_key_w_mm, iec_key_h_mm, iec_cut_depth + overlap_mm], center=true);

    // Rocker switch recess (front, above IEC)
    translate([0, rocker_opening_offset_y_mm, z_switch_cut_center])
      cube([rocker_opening_width_mm, rocker_opening_height_mm, switch_recess_depth_mm + overlap_mm], center=true);

    // Fuse drawer opening (front) - cut into the protruding fuse block
    z_fuse_cut_center = fuse_drawer_protrude_mm/2 - fuse_drawer_depth_mm/2;
    translate([0, fuse_opening_offset_y_mm, z_fuse_cut_center])
      cube([fuse_opening_width_mm, fuse_opening_height_mm, fuse_drawer_depth_mm + overlap_mm], center=true);

    // Mounting screw holes (through bezel+flange)
    hole_h = bezel_thickness_mm + flange_thickness_mm + 2*overlap_mm;
    z_hole_center = -(bezel_thickness_mm + flange_thickness_mm/2);
    for (x = [-screw_hole_pitch_x_mm/2, screw_hole_pitch_x_mm/2])
      for (y = [-screw_hole_pitch_y_mm/2, screw_hole_pitch_y_mm/2])
        translate([x, y, z_hole_center])
          cylinder(r=screw_hole_diameter_mm/2, h=hole_h, center=true);

    // Side reliefs on body (shallow, do not disconnect)
    relief_w = 4;
    relief_h = 8;
    relief_d = body_depth_mm*0.35;
    z_relief_center = z_body_center - body_depth_mm*0.10;
    for (sx = [-1, 1])
      translate([sx*(body_width_mm/2 - relief_w/2 + 0.01), 0, z_relief_center])
        cube([relief_w, relief_h, relief_d], center=true);
  }
}

iec_switched_fused_inlet_40x27();