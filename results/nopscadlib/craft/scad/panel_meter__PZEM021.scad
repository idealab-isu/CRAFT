// Peacefair PZEM-021 AC panel meter (approximate, recognizable features)
// ONE connected solid: bezel + face recesses + buttons + rear housing + terminal block + mounting ears.
// No text/labels. All placements are formula-based (no arbitrary floating).

$fn = 64;

// ---------- Parameters ----------
overall_width  = 48;
overall_height = 29;
overall_depth  = 24;

bezel_width        = 48;
bezel_height       = 29;
bezel_thickness    = 3;
bezel_corner_r     = 2.2;
bezel_step_inset   = 1.0;   // inner step inset from bezel edge
bezel_step_depth   = 0.9;   // shallow face step depth

rear_body_width  = 45;
rear_body_height = 26;
rear_body_depth  = 21;
rear_corner_r    = 1.4;

mount_ear_w = 8;
mount_ear_h = 12;
mount_ear_t = 2.5;

display_w = 34;
display_h = 14;
display_r = 1.2;
display_y = 0.12; // fraction of bezel_height (positive = up)
display_recess_depth = 1.2;

lcd_aperture_inset = 1.6;  // smaller inner "glass" recess
lcd_aperture_depth = 0.6;

button_count = 2;
button_w = 6;
button_h = 4;
button_depth = 1.2;
button_y = -0.28; // fraction of bezel_height (negative = down)
button_r = 0.9;

terminal_w = 28;
terminal_h = 10;
terminal_d = 8;
terminal_r = 1.0;
terminal_y = -0.18; // fraction of rear_body_height
terminal_lip = 1.2;

screw_r = 1.25;
screw_depth = 3.5;

rear_pocket_w_frac = 0.78;
rear_pocket_h_frac = 0.58;
rear_pocket_depth  = 2.0;

overlap = 1.0;
clearance = 0.2;

// ---------- Helpers ----------
module rrect2d(w, h, r) {
  rr = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - rr), sy*(h/2 - rr)]) circle(r=rr);
  }
}

module rrect3d(w, h, t, r) {
  linear_extrude(height=t, center=true) rrect2d(w, h, r);
}

// ---------- Main ----------
module pzem021_meter() {

  // Coordinate convention:
  // +Z = front, -Z = rear.

  bezel_zc      = 0;
  bezel_front_z = bezel_zc + bezel_thickness/2;
  bezel_back_z  = bezel_zc - bezel_thickness/2;

  rear_zc       = bezel_back_z - rear_body_depth/2 + overlap; // connected
  rear_back_z   = rear_zc - rear_body_depth/2;

  // Mount ears: centered on rear body, but slightly toward bezel so they read as panel clips
  ear_x = rear_body_width/2 + mount_ear_w/2 - overlap;
  ear_zc = rear_zc + rear_body_depth*0.10; // formula-based, still connected

  // Display recess positions
  disp_yc = bezel_height * display_y;
  disp_recess_zc = bezel_front_z - display_recess_depth/2 + overlap*0.2;

  // Inner "glass" recess (smaller, deeper into face)
  glass_w = max(1, display_w - 2*lcd_aperture_inset);
  glass_h = max(1, display_h - 2*lcd_aperture_inset);
  glass_zc = bezel_front_z - (display_recess_depth + lcd_aperture_depth)/2 + overlap*0.2;

  // Buttons
  btn_yc = bezel_height * button_y;
  btn_zc = bezel_front_z + button_depth/2 - overlap; // protrude, but overlap into bezel

  // Terminal block
  term_yc = rear_body_height * terminal_y;
  term_zc = rear_back_z - terminal_d/2 + overlap; // protrude rearward, connected

  // Screw dimples on terminal rear face
  screw_zc = (term_zc - terminal_d/2) + screw_depth/2 - overlap*0.2;

  difference() {
    union() {
      // --- Bezel ---
      translate([0, 0, bezel_zc])
        rrect3d(bezel_width, bezel_height, bezel_thickness, bezel_corner_r);

      // --- Rear body ---
      translate([0, 0, rear_zc])
        rrect3d(rear_body_width, rear_body_height, rear_body_depth, rear_corner_r);

      // --- Mounting ears (left/right) ---
      for (sx = [-1, 1]) {
        translate([sx*ear_x, 0, ear_zc])
          cube([mount_ear_w, mount_ear_h, mount_ear_t], center=true);
      }

      // --- Terminal block (rear protrusion) ---
      translate([0, term_yc, term_zc])
        rrect3d(terminal_w, terminal_h, terminal_d, terminal_r);

      // Terminal lip ridge (still connected)
      translate([0, term_yc, term_zc - terminal_d/2 + terminal_lip/2 - overlap])
        cube([terminal_w*0.92, terminal_h*0.85, terminal_lip], center=true);

      // --- Buttons (front protrusions) ---
      if (button_count > 0) {
        xspan = display_w * 0.55; // spacing derived from display width
        for (i = [0:button_count-1]) {
          bx = (i - (button_count-1)/2) * xspan;
          translate([bx, btn_yc, btn_zc])
            rrect3d(button_w, button_h, button_depth, button_r);
        }
      }

      // --- Small rear "strain relief" boss under terminal (common silhouette cue) ---
      boss_w = terminal_w*0.55;
      boss_h = terminal_h*0.55;
      boss_d = terminal_d*0.55;
      boss_zc = term_zc + terminal_d*0.15; // overlaps into terminal block
      translate([0, term_yc - terminal_h*0.55, boss_zc])
        rrect3d(boss_w, boss_h, boss_d, 0.8);
    }

    // ---------- Face details ----------
    // Inner bezel step (perimeter recess)
    step_w = bezel_width  - 2*bezel_step_inset;
    step_h = bezel_height - 2*bezel_step_inset;
    step_zc = bezel_front_z - bezel_step_depth/2 + overlap*0.2;
    translate([0, 0, step_zc])
      rrect3d(step_w, step_h, bezel_step_depth + 2*overlap, max(0.6, bezel_corner_r-0.7));

    // Display recess (outer)
    translate([0, disp_yc, disp_recess_zc])
      rrect3d(display_w, display_h, display_recess_depth + 2*overlap, display_r);

    // Inner "glass" recess (smaller)
    translate([0, disp_yc, glass_zc])
      rrect3d(glass_w, glass_h, (display_recess_depth + lcd_aperture_depth) + 2*overlap, max(0.6, display_r-0.4));

    // Small indicator notch under display (subtle cue)
    notch_w = display_w*0.22;
    notch_h = display_h*0.18;
    notch_d = 0.6;
    notch_yc = disp_yc - display_h*0.55;
    notch_zc = bezel_front_z - notch_d/2 + overlap*0.2;
    translate([0, notch_yc, notch_zc])
      rrect3d(notch_w, notch_h, notch_d + 2*overlap, 0.6);

    // ---------- Terminal details ----------
    // Screw dimples (rear face)
    for (sx = [-1, 1]) {
      translate([sx*terminal_w*0.22, term_yc, screw_zc])
        rotate([90, 0, 0])
          cylinder(h=terminal_h*0.92, r=screw_r, center=true);
    }

    // Wire entry slots (two shallow rectangular pockets on terminal rear face)
    slot_w = terminal_w*0.22;
    slot_h = terminal_h*0.35;
    slot_d = min(2.2, terminal_d*0.45);
    slot_zc = (term_zc - terminal_d/2) + slot_d/2 - overlap*0.2;
    for (sx = [-1, 1]) {
      translate([sx*terminal_w*0.22, term_yc - terminal_h*0.18, slot_zc])
        cube([slot_w, slot_h, slot_d + 2*overlap], center=true);
    }

    // ---------- Rear housing pocket (shallow) ----------
    pocket_w = rear_body_width  * rear_pocket_w_frac;
    pocket_h = rear_body_height * rear_pocket_h_frac;
    pocket_d = min(rear_pocket_depth, rear_body_depth*0.28);
    pocket_zc = rear_back_z + pocket_d/2 + overlap*0.2;
    translate([0, rear_body_height*0.10, pocket_zc])
      rrect3d(pocket_w, pocket_h, pocket_d + 2*overlap, 1.2);

    // Side grooves (two shallow vertical grooves on each side of rear body)
    groove_w = 1.2;
    groove_h = rear_body_height*0.70;
    groove_d = rear_body_depth*0.55;
    groove_zc = rear_zc - rear_body_depth*0.05;
    for (sx = [-1, 1]) {
      translate([sx*(rear_body_width/2 - groove_w/2 + overlap*0.2), 0, groove_zc])
        cube([groove_w + 2*overlap, groove_h, groove_d], center=true);
    }
  }
}

pzem021_meter();