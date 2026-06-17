$fn = 96;

// =====================
// Parameters (mm)
// =====================
flange_W = 40.0;          // overall flange width (X)
flange_H = 32.0;          // overall flange height (Y)
flange_t = 2.5;           // flange thickness (Z)

body_W   = 28.0;          // rear body width
body_H   = 20.0;          // rear body height
body_D   = 30.0;          // rear body depth (behind flange)

cutout_W = 30.0;          // IEC mouth width (opening)
cutout_H = 22.0;          // IEC mouth height (opening)

corner_r = 1.5;           // rounding radius for flange outline (2D)

mount_hole_d        = 3.2;
mount_hole_pitch_W  = 34.0;
mount_hole_pitch_H  = 26.0;

terminal_block_W = 24.0;
terminal_block_H = 16.0;
terminal_block_D = 12.0;

wire_clearance_D = 15.0;

overlap = 1.2;            // overlap to guarantee connectivity/robust booleans (1–2mm)

// IEC C14-ish front geometry (approx)
bezel_recess_t = 1.2;     // shallow recess on front face
bezel_margin   = 2.0;     // recess larger than opening by this margin
inner_step_t   = 2.0;     // deeper step behind recess
inner_step_m   = 0.8;     // step slightly larger than opening

// IEC "pin" features (simplified) - make it recognizable
pin_w = 4.2;
pin_h = 6.0;
pin_pitch_x = 10.0;
pin_pitch_y = 7.5;
pin_depth = 6.0;          // how far pins protrude into the socket cavity

// Rear terminals (spade tabs) - simplified but recognizable
tab_w = 6.3;
tab_t = 0.8;
tab_L = 10.0;
tab_pitch_x = 10.0;
tab_pitch_y = 8.0;

// Side retention bumps (instead of floating clips)
clip_bump_W = 3.0;
clip_bump_H = 8.0;
clip_bump_L = 8.0;

// Cosmetic screw heads on front
screw_head_d = 6.5;
screw_head_h = 2.0;

// =====================
// Helpers
// =====================
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

module rounded_box(w, h, d, r) {
  linear_extrude(height=d, center=true)
    rounded_rect_2d(w, h, r);
}

// =====================
// Feature modules
// =====================
module flange_solid() {
  rounded_box(flange_W, flange_H, flange_t, corner_r);
}

module body_solid() {
  // Body sits behind flange (positive Z), overlaps into flange by 'overlap'
  translate([0, 0, flange_t/2 + body_D/2 - overlap])
    rounded_box(body_W, body_H, body_D, max(0.6, corner_r*0.6));
}

module terminal_block_solid() {
  // Terminal block behind body, overlaps into body
  translate([0, 0, flange_t/2 + body_D + terminal_block_D/2 - 2*overlap])
    rounded_box(terminal_block_W, terminal_block_H, terminal_block_D, 0.8);
}

module strain_relief_solid() {
  // Clearance envelope behind terminal block, overlaps into terminal block
  translate([0, 0,
    flange_t/2 + body_D + terminal_block_D + wire_clearance_D/2 - 3*overlap
  ])
    rounded_box(terminal_block_W, terminal_block_H, wire_clearance_D, 0.8);
}

module side_clip_bumps_solid() {
  // Small bumps on the sides of the rear body near the flange (connected)
  zc = flange_t/2 + clip_bump_L/2 - overlap;
  xL = -body_W/2 - clip_bump_W/2 + overlap;
  xR =  body_W/2 + clip_bump_W/2 - overlap;

  union() {
    translate([xL, 0, zc]) rounded_box(clip_bump_W, clip_bump_H, clip_bump_L, 0.6);
    translate([xR, 0, zc]) rounded_box(clip_bump_W, clip_bump_H, clip_bump_L, 0.6);
  }
}

module spade_tabs_solid() {
  // Three rear spade tabs, attached to the terminal block rear face
  // Place so their front overlaps into terminal block by 'overlap'
  z_term_center = flange_t/2 + body_D + terminal_block_D/2 - 2*overlap;
  z_term_back   = z_term_center + terminal_block_D/2; // back face plane
  zc = z_term_back + tab_L/2 - overlap;

  module tab_at(x,y){
    translate([x, y, zc])
      cube([tab_w, tab_t, tab_L], center=true);
  }

  union() {
    tab_at( tab_pitch_x/2,  tab_pitch_y/2);
    tab_at(-tab_pitch_x/2,  tab_pitch_y/2);
    tab_at(0,              -tab_pitch_y/2);
  }
}

module screw_heads_solid() {
  // Cosmetic screw heads on front face; overlap into flange
  zc = -flange_t/2 - screw_head_h/2 + overlap;
  union() {
    translate([ mount_hole_pitch_W/2,  mount_hole_pitch_H/2, zc]) cylinder(h=screw_head_h, r=screw_head_d/2, center=true);
    translate([-mount_hole_pitch_W/2,  mount_hole_pitch_H/2, zc]) cylinder(h=screw_head_h, r=screw_head_d/2, center=true);
    translate([ mount_hole_pitch_W/2, -mount_hole_pitch_H/2, zc]) cylinder(h=screw_head_h, r=screw_head_d/2, center=true);
    translate([-mount_hole_pitch_W/2, -mount_hole_pitch_H/2, zc]) cylinder(h=screw_head_h, r=screw_head_d/2, center=true);
  }
}

module mounting_holes_cut() {
  // Through flange (and slightly beyond) for robust subtraction
  h = flange_t + 4*overlap;
  union() {
    translate([ mount_hole_pitch_W/2,  mount_hole_pitch_H/2, 0]) cylinder(h=h, r=mount_hole_d/2, center=true);
    translate([-mount_hole_pitch_W/2,  mount_hole_pitch_H/2, 0]) cylinder(h=h, r=mount_hole_d/2, center=true);
    translate([ mount_hole_pitch_W/2, -mount_hole_pitch_H/2, 0]) cylinder(h=h, r=mount_hole_d/2, center=true);
    translate([-mount_hole_pitch_W/2, -mount_hole_pitch_H/2, 0]) cylinder(h=h, r=mount_hole_d/2, center=true);
  }
}

// ---------------------
// IEC inlet face geometry (recognizable C14-ish)
// ---------------------
module iec_front_recess_cut() {
  // Shallow recess on the front face
  w = cutout_W + 2*bezel_margin;
  h = cutout_H + 2*bezel_margin;
  d = bezel_recess_t + 2*overlap;

  // Center so it opens on the front face (negative Z side)
  zc = -flange_t/2 + bezel_recess_t/2 - overlap;
  translate([0, 0, zc])
    rounded_box(w, h, d, 1.6);
}

module iec_inner_step_cut() {
  // Deeper step behind the recess (within flange thickness and slightly into body)
  w = cutout_W + 2*inner_step_m;
  h = cutout_H + 2*inner_step_m;
  d = inner_step_t + 2*overlap;

  z_front = -flange_t/2 + bezel_recess_t; // start after recess
  zc = z_front + inner_step_t/2 - overlap;
  translate([0, 0, zc])
    rounded_box(w, h, d, 1.2);
}

module socket_opening_cut() {
  // Main through opening into the body (C14-ish mouth)
  cut_depth = flange_t + body_D*0.85;
  zc = -flange_t/2 + cut_depth/2 - overlap;
  translate([0, 0, zc])
    rounded_box(cutout_W, cutout_H, cut_depth + 2*overlap, 1.0);
}

module iec_pins_solid() {
  // Three simplified "pins" inside the socket cavity.
  // FIX: ensure pins are physically connected to the surrounding solid (not floating in the void).
  // We anchor them to the *back wall* of the socket cutout by extending them slightly beyond it.
  cut_depth = flange_t + body_D*0.85;
  z_cut_front = -flange_t/2 - overlap;          // where the cut starts (approx)
  z_cut_back  = z_cut_front + cut_depth + 2*overlap; // where the cut ends (approx)

  // Place pins near the back of the cavity and make them longer so they intersect the body.
  pin_attach = 2.0; // extra length to bite into the body (>= overlap)
  pin_d = pin_depth + pin_attach;

  // Center so the rear of the pin extends into solid beyond the cut's back plane
  zc = (z_cut_back - pin_d/2) + overlap;

  module pin_at(x,y){
    translate([x, y, zc])
      rounded_box(pin_w, pin_h, pin_d, 0.6);
  }

  union() {
    pin_at( pin_pitch_x/2,  pin_pitch_y/2);
    pin_at(-pin_pitch_x/2,  pin_pitch_y/2);
    pin_at(0,              -pin_pitch_y/2);
  }
}

// =====================
// Complete model (ONE connected solid)
// =====================
module complete_model() {
  difference() {
    union() {
      flange_solid();
      body_solid();
      terminal_block_solid();
      strain_relief_solid();
      side_clip_bumps_solid();
      spade_tabs_solid();
      screw_heads_solid();

      // IEC recognizable internal features (now guaranteed to connect to body)
      iec_pins_solid();
    }

    mounting_holes_cut();

    // IEC inlet front geometry
    iec_front_recess_cut();
    iec_inner_step_cut();
    socket_opening_cut();
  }
}

// Final output
complete_model();