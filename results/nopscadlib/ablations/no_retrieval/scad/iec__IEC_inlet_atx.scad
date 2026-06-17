// IEC C14 inlet module (ATX style) - 40.0mm x 27.0mm panel cutout
// Structural fixes:
// - Make IEC C14 face unmistakable: add trapezoid cavity + 3 pin slots + small key notches
// - Ensure all Z placements are derived from the same front reference plane (z=0 at front face)
// - Recalculate translates so solids overlap slightly and remain one connected object

$fn = 64;

// -------------------- Parameters --------------------
cutout_W = 40.0;                 // panel cutout width
cutout_H = 27.0;                 // panel cutout height

flange_W = 50.0;
flange_H = 32.0;
flange_t = 2.5;

body_depth = 28.0;
body_wall_t = 1.8;
body_clearance = 0.3;

screw_hole_d = 3.2;
screw_hole_spacing_W = 44.0;
screw_hole_offset_Y = 0.0;

terminal_block_W = 22.0;
terminal_block_H = 16.0;
terminal_block_depth = 10.0;

overlap = 1.2;                   // 1-2mm overlap for robust unions

// Side retention "ears"/clips (kept connected)
clip_W = 8.0;
clip_T = 2.0;
clip_L = 10.0;

// Rear spade terminals (kept connected)
spade_W = 6.3;
spade_T = 0.8;
spade_L = 12.0;
spade_spacing_X = 8.0;
spade_spacing_Y = 6.0;

// Edge softening (small; avoid heavy Minkowski on detailed cutouts)
chamfer_r = 0.8;

// -------------------- IEC C14 front details (cutouts) --------------------
// Approximate IEC C14 socket cavity (trapezoid-ish) + 3 pin holes.
iec_cavity_top_W = 26.0;
iec_cavity_bot_W = 22.0;
iec_cavity_H     = 18.0;
iec_cavity_depth = 9.0;          // recess depth into body

pin_hole_W = 6.0;                // rectangular pin slot width
pin_hole_H = 3.2;                // rectangular pin slot height
pin_hole_depth = 12.0;           // deeper than cavity so it clearly cuts through recess

pin_pitch_X = 10.0;              // L-N spacing
pin_row_Y   = 3.8;               // L/N row above center
pin_gnd_Y   = -4.8;              // ground below center

// Small "key" notches near top corners (common visual cue on IEC inlets)
key_notch_W = 2.2;
key_notch_H = 2.2;
key_notch_depth = 2.0;

// -------------------- Derived reference planes --------------------
// Coordinate convention: FRONT FACE of flange is at z=0, positive z goes rearward.
z_flange_center = flange_t/2;
z_body_front    = flange_t - overlap;                 // body starts slightly into flange
z_body_center   = z_body_front + body_depth/2;
z_body_rear     = z_body_front + body_depth;

z_term_center   = (z_body_rear - overlap) + terminal_block_depth/2;
z_term_rear     = (z_body_rear - overlap) + terminal_block_depth;

z_spade_center  = (z_term_rear - overlap) + spade_L/2;

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=1.0, center=true) {
  rr = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
  if (rr <= 0) cube(size, center=center);
  else minkowski() {
    cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=center);
    sphere(r=rr);
  }
}

module screw_hole_cyl(h) {
  cylinder(h=h, r=screw_hole_d/2, center=true);
}

// -------------------- Base solids --------------------
module front_flange_solid() {
  translate([0,0,z_flange_center])
    rounded_box([flange_W, flange_H, flange_t], r=chamfer_r, center=true);
}

module inlet_body_outer() {
  body_W = cutout_W - 2*body_clearance;
  body_H = cutout_H - 2*body_clearance;

  translate([0,0,z_body_center])
    rounded_box([body_W, body_H, body_depth], r=chamfer_r, center=true);
}

module inlet_body_inner_void() {
  // Hollow from the rear, leaving walls and leaving the front face intact
  body_W = cutout_W - 2*body_clearance;
  body_H = cutout_H - 2*body_clearance;

  inner_W = body_W - 2*body_wall_t;
  inner_H = body_H - 2*body_wall_t;
  inner_D = body_depth - body_wall_t;

  // Start the void slightly behind the body front so the front face remains solid
  // (and so the IEC recess/pin cutouts have material around them).
  z_void_center = (z_body_front + body_wall_t) + inner_D/2;

  translate([0,0,z_void_center])
    cube([inner_W, inner_H, inner_D], center=true);
}

module rear_terminal_block() {
  translate([0,0,z_term_center])
    rounded_box([terminal_block_W, terminal_block_H, terminal_block_depth], r=chamfer_r, center=true);
}

module retention_clips() {
  // Side ears connected to body sides
  body_W = cutout_W - 2*body_clearance;

  xL = -(body_W/2 + clip_W/2 - overlap);
  xR = +(body_W/2 + clip_W/2 - overlap);

  // Put clips near the front, overlapping into the body
  zC = z_body_front + clip_L/2;

  union() {
    translate([xL, 0, zC]) cube([clip_W, clip_T, clip_L], center=true);
    translate([xR, 0, zC]) cube([clip_W, clip_T, clip_L], center=true);
  }
}

module terminal_spades() {
  union() {
    translate([-spade_spacing_X/2,  spade_spacing_Y/2, z_spade_center])
      cube([spade_W, spade_T, spade_L], center=true); // L
    translate([ spade_spacing_X/2,  spade_spacing_Y/2, z_spade_center])
      cube([spade_W, spade_T, spade_L], center=true); // N
    translate([ 0,                -spade_spacing_Y/2, z_spade_center])
      cube([spade_W, spade_T, spade_L], center=true); // G
  }
}

// -------------------- Negative geometry (cutouts) --------------------
module panel_cutout_envelope() {
  // Thin gauge at the front, overlapping the flange so it stays connected
  gauge_t = 0.8;
  translate([0,0,gauge_t/2 - overlap/2])
    cube([cutout_W, cutout_H, gauge_t + overlap], center=true);
}

module flange_opening_void() {
  // Through-hole in flange matching panel cutout
  translate([0,0,z_flange_center])
    cube([cutout_W, cutout_H, flange_t + 2*overlap], center=true);
}

module mounting_screw_holes_void() {
  h = flange_t + 2*overlap;
  translate([-screw_hole_spacing_W/2, screw_hole_offset_Y, z_flange_center]) screw_hole_cyl(h);
  translate([ screw_hole_spacing_W/2, screw_hole_offset_Y, z_flange_center]) screw_hole_cyl(h);
}

module front_bezel_recess_void() {
  // Shallow rectangular recess around the cavity to mimic the IEC face bezel
  bezel_W = 32.0;
  bezel_H = 22.0;
  bezel_d = 1.2;

  translate([0,0,bezel_d/2])
    cube([bezel_W, bezel_H, bezel_d], center=true);
}

module iec_front_cavity_void() {
  // Trapezoidal recess cut from the very front (z=0) into the body
  translate([0,0,iec_cavity_depth/2])
    linear_extrude(height=iec_cavity_depth, center=true, convexity=10)
      polygon(points=[
        [-iec_cavity_bot_W/2, -iec_cavity_H/2],
        [ iec_cavity_bot_W/2, -iec_cavity_H/2],
        [ iec_cavity_top_W/2,  iec_cavity_H/2],
        [-iec_cavity_top_W/2,  iec_cavity_H/2]
      ]);
}

module iec_pin_holes_void() {
  // Three rectangular pin slots cut deeper than the cavity
  translate([0,0,pin_hole_depth/2]) union() {
    translate([-pin_pitch_X/2, pin_row_Y, 0])
      cube([pin_hole_W, pin_hole_H, pin_hole_depth], center=true);
    translate([ pin_pitch_X/2, pin_row_Y, 0])
      cube([pin_hole_W, pin_hole_H, pin_hole_depth], center=true);
    translate([0, pin_gnd_Y, 0])
      cube([pin_hole_W, pin_hole_H, pin_hole_depth], center=true);
  }
}

module iec_key_notches_void() {
  // Small square notches near the top corners of the cavity area (visual IEC cue)
  // Positioned relative to the cavity top width and height.
  x_off = iec_cavity_top_W/2 - key_notch_W/2;
  y_off = iec_cavity_H/2 - key_notch_H/2;

  translate([0,0,key_notch_depth/2]) union() {
    translate([ x_off, y_off, 0]) cube([key_notch_W, key_notch_H, key_notch_depth], center=true);
    translate([-x_off, y_off, 0]) cube([key_notch_W, key_notch_H, key_notch_depth], center=true);
  }
}

// -------------------- Assembly --------------------
module main_solid() {
  union() {
    front_flange_solid();
    inlet_body_outer();
    rear_terminal_block();
    retention_clips();
    terminal_spades();

    // Connected gauge for the 40x27 cutout reference
    panel_cutout_envelope();
  }
}

module complete_model() {
  difference() {
    main_solid();

    // Flange opening + screw holes
    flange_opening_void();
    mounting_screw_holes_void();

    // Hollow the body from the rear
    inlet_body_inner_void();

    // IEC C14 recognizable front details
    front_bezel_recess_void();
    iec_front_cavity_void();
    iec_pin_holes_void();
    iec_key_notches_void();
  }
}

// Final Output
complete_model();