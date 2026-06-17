$fn = 64;

// =====================
// Parameters (mm)
// =====================
overall_width_mm  = 36.0;   // flange width (X)
overall_height_mm = 27.0;   // flange height (Y)

panel_thickness_mm = 2.0;

cutout_width_mm  = 27.5;
cutout_height_mm = 20.0;

corner_radius_mm = 1.0;

mount_hole_diameter_mm = 3.2;
mount_hole_pitch_x_mm  = 30.0;
mount_hole_pitch_y_mm  = 0.0;

inlet_depth_mm = 30.0;

fuse_drawer_projection_mm = 12.0;

tolerance_mm = 0.2;

bezel_thickness_mm = 3.0;

body_width_mm  = 28.0;
body_height_mm = 22.0;

panel_margin_mm = 12.0;
overlap_mm = 1.0;

fuse_clear_width_mm  = 18.0;
fuse_clear_height_mm = 10.0;

// Extra detail parameters (approximate IEC fused inlet "old" look)
front_face_frame_mm = 1.6;     // thickness of the front "lip" around C14 opening
front_face_depth_mm = 4.0;     // depth of the front face block (part of body)
terminal_block_depth_mm = 10.0;
terminal_block_w_mm = 22.0;
terminal_block_h_mm = 16.0;

spade_w_mm = 6.3;
spade_t_mm = 0.8;
spade_len_mm = 10.0;
spade_pitch_x_mm = 10.0;
spade_pitch_y_mm = 5.5;

// =====================
// Helpers
// =====================
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

module rounded_box(w, h, t, r) {
  linear_extrude(height=t, center=true)
    rounded_rect_2d(w, h, r);
}

module slot_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  intersection() {
    hull() {
      translate([ w/2 - r2, 0]) circle(r=r2);
      translate([-w/2 + r2, 0]) circle(r=r2);
    }
    square([w, h], center=true);
  }
}

module slot_cut(w, h, depth, r) {
  linear_extrude(height=depth, center=true)
    slot_2d(w, h, r);
}

// =====================
// IEC fused inlet module (single connected solid)
// Coordinate system:
// - Panel lies in XY plane, thickness along Z
// - Front face is +Z, rear is -Z
// =====================
module iec_fused_inlet_module() {

  // Derived placements (no arbitrary numbers)
  flange_z = panel_thickness_mm/2 + bezel_thickness_mm/2 - overlap_mm;

  // Main body centered behind panel
  body_z   = -panel_thickness_mm/2 - inlet_depth_mm/2 + overlap_mm;

  // Front face block (part of body, but slightly proud to create recognizable inlet face)
  face_z = panel_thickness_mm/2 + front_face_depth_mm/2 - overlap_mm;

  // Fuse drawer sits on front face, protruding +Z
  fuse_z   = panel_thickness_mm/2 + fuse_drawer_projection_mm/2 - overlap_mm;

  // Terminal block at rear (inside body, but protruding slightly for recognizable depth)
  terminal_z = -panel_thickness_mm/2 - inlet_depth_mm - terminal_block_depth_mm/2 + overlap_mm;

  // C14 opening size (approx)
  c14_w = 22.0;
  c14_h = 16.0;
  c14_r = 2.0;

  // Front recess pocket slightly larger (gives "inlet mouth" look)
  pocket_w = c14_w + 2*front_face_frame_mm;
  pocket_h = c14_h + 2*front_face_frame_mm;
  pocket_r = c14_r + 0.8;
  pocket_depth = front_face_depth_mm + 2*overlap_mm;

  // Pin holes (approx IEC C14)
  pin_w = 4.2;
  pin_h = 6.2;
  pin_r = 1.2;
  pin_pitch_x = spade_pitch_x_mm;
  pin_pitch_y = spade_pitch_y_mm;

  // Fuse drawer outer block (front)
  fuse_outer_w = fuse_clear_width_mm + 6.0;
  fuse_outer_h = fuse_clear_height_mm + 6.0;

  // Fuse drawer cavity (opening)
  fuse_cavity_w = fuse_clear_width_mm + 2*tolerance_mm;
  fuse_cavity_h = fuse_clear_height_mm + 2*tolerance_mm;
  fuse_cavity_depth = fuse_drawer_projection_mm + 2*overlap_mm;

  // Fuse drawer placement (top-ish on flange)
  fuse_y = (overall_height_mm/2 - fuse_outer_h/2 - 2.0);

  // Panel block (context) - kept connected by overlap with flange
  panel_w = overall_width_mm + 2*panel_margin_mm;
  panel_h = overall_height_mm + 2*panel_margin_mm;

  // Through depths for cuts
  through_depth_all = inlet_depth_mm + bezel_thickness_mm + fuse_drawer_projection_mm + terminal_block_depth_mm + 8*overlap_mm;
  through_z_all = -panel_thickness_mm/2 - inlet_depth_mm/2; // roughly centered through body

  // Spade terminals (rear protrusions) placement
  spade_z = -panel_thickness_mm/2 - inlet_depth_mm - spade_len_mm/2 + overlap_mm;
  spade_block_z = -panel_thickness_mm/2 - inlet_depth_mm - terminal_block_depth_mm/2 + overlap_mm;

  difference() {
    // --------- SOLID UNION (single connected solid) ----------
    union() {
      // Panel (context)
      cube([panel_w, panel_h, panel_thickness_mm], center=true);

      // Flange / bezel
      translate([0, 0, flange_z])
        rounded_box(overall_width_mm, overall_height_mm, bezel_thickness_mm, corner_radius_mm);

      // Main body (rear housing)
      translate([0, 0, body_z])
        rounded_box(body_width_mm, body_height_mm, inlet_depth_mm, 1.2);

      // Front face block to create recognizable inlet "mouth" area (connected to flange/body)
      translate([0, 0, face_z])
        rounded_box(body_width_mm - 2.0, body_height_mm - 2.0, front_face_depth_mm, 1.6);

      // Fuse drawer housing (front protrusion) - connected to flange via overlap
      translate([0, fuse_y, fuse_z])
        rounded_box(fuse_outer_w, fuse_outer_h, fuse_drawer_projection_mm, 1.0);

      // Rear terminal block (connected to body)
      translate([0, 0, spade_block_z])
        rounded_box(terminal_block_w_mm, terminal_block_h_mm, terminal_block_depth_mm, 1.0);

      // Three spade terminals (rear protrusions), connected to terminal block
      // Two lower pins
      for (sx = [-1, 1]) {
        translate([sx*pin_pitch_x/2, -pin_pitch_y/2, spade_z])
          cube([spade_w_mm, spade_t_mm, spade_len_mm], center=true);
      }
      // Earth pin (upper center)
      translate([0, pin_pitch_y/2, spade_z])
        cube([spade_w_mm, spade_t_mm, spade_len_mm], center=true);
    }

    // --------- CUTOUTS / DETAILS ----------
    // Panel cutout opening (through panel only)
    rounded_box(cutout_width_mm + 2*tolerance_mm,
                cutout_height_mm + 2*tolerance_mm,
                panel_thickness_mm + 2*overlap_mm,
                0.8);

    // Mounting holes (through panel only)
    translate([ mount_hole_pitch_x_mm/2,  mount_hole_pitch_y_mm/2, 0])
      cylinder(d=(mount_hole_diameter_mm + 2*tolerance_mm),
               h=panel_thickness_mm + 2*overlap_mm, center=true);
    translate([-mount_hole_pitch_x_mm/2, -mount_hole_pitch_y_mm/2, 0])
      cylinder(d=(mount_hole_diameter_mm + 2*tolerance_mm),
               h=panel_thickness_mm + 2*overlap_mm, center=true);

    // Front recess pocket around C14 opening (in front face area)
    translate([0, 0, face_z])
      rounded_box(pocket_w, pocket_h, pocket_depth, pocket_r);

    // Main C14 opening through the body (gives recognizable inlet contour)
    translate([0, 0, through_z_all])
      rounded_box(c14_w, c14_h, through_depth_all, c14_r);

    // Pin holes (3 slots) through body (visible from front)
    pin_depth = inlet_depth_mm + front_face_depth_mm + 4*overlap_mm;
    pin_z = -panel_thickness_mm/2 - inlet_depth_mm/2; // centered in body
    for (sx = [-1, 1]) {
      translate([sx*pin_pitch_x/2, -pin_pitch_y/2, pin_z])
        slot_cut(pin_w, pin_h, pin_depth, pin_r);
    }
    translate([0, pin_pitch_y/2, pin_z])
      slot_cut(pin_w, pin_h, pin_depth, pin_r);

    // Fuse drawer cavity (front opening)
    translate([0, fuse_y, fuse_z])
      rounded_box(fuse_cavity_w, fuse_cavity_h, fuse_cavity_depth, 0.8);

    // Small finger notch on fuse drawer (front edge)
    notch_r = 3.0;
    notch_depth = fuse_drawer_projection_mm + 2*overlap_mm;
    notch_y = fuse_y + fuse_outer_h/2 - 2.0;
    notch_z = fuse_z;
    translate([0, notch_y, notch_z])
      rotate([90, 0, 0])
        cylinder(r=notch_r, h=notch_depth, center=true);
  }
}

iec_fused_inlet_module();