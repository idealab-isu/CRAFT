$fn = 64;

// Peacefair PZEM-001 (approximate) — ONE connected solid, no text.
// Coordinate convention:
//  - Front face points toward +Z
//  - Bezel centered at z=0 (thickness spans [-t/2, +t/2])
//  - Body extends toward -Z

// -------------------- Parameters (mm) --------------------
overall_width_mm   = 48;   // body width (X)
overall_height_mm  = 29;   // body height (Y)
overall_depth_mm   = 22;   // body depth behind bezel (Z)

bezel_width_mm     = 50;   // bezel width (X)
bezel_height_mm    = 31;   // bezel height (Y)
bezel_thickness_mm = 3;    // bezel thickness (Z)

bezel_corner_r_mm  = 2.0;

// Front features
display_window_width_mm   = 36;
display_window_height_mm  = 16;
display_window_r_mm       = 1.2;

button_count       = 2;
button_diameter_mm = 4;
button_height_mm   = 1.2;
button_spacing_mm  = 10;
button_row_offset_y_mm = 9;

// Back features (approximate)
terminal_block_w_mm = 22;
terminal_block_h_mm = 12;
terminal_block_d_mm = 9;

connector_w_mm = 14;
connector_h_mm = 7;
connector_d_mm = 6;

// Side clips/ears
clip_w_mm = 6;
clip_h_mm = 12;
clip_d_mm = 3;
clip_y_offset_mm = 0;

// Detailing
overlap_mm = 1; // ensures unions are watertight/connected

// -------------------- Helpers --------------------
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

// Simple "step" bezel lip (adds recognizable bezel detail)
module bezel_lip(w, h, t, lip_w, lip_h, lip_t, r_outer, r_inner) {
  // Outer bezel slab + inner raised lip ring (both connected)
  union() {
    rrect3d(w, h, t, r_outer);
    // Raised ring on front face
    translate([0, 0, t/2 + lip_t/2 - overlap_mm])
      difference() {
        rrect3d(w - 2*lip_w, h - 2*lip_h, lip_t, r_inner);
        // Hollow center of ring
        rrect3d(w - 2*(lip_w + 2), h - 2*(lip_h + 2), lip_t + 2*overlap_mm, max(0.5, r_inner-0.6));
      }
  }
}

// -------------------- Main solid model --------------------
module pzem001_solid() {

  // Derived placements (FORMULAS only)
  body_center_z = -bezel_thickness_mm/2 - overall_depth_mm/2 + overlap_mm; // overlaps into bezel
  body_back_z   = body_center_z - overall_depth_mm/2;

  // Back attachments: sit behind body and overlap into it
  terminal_center_z  = body_back_z - terminal_block_d_mm/2 + overlap_mm;
  connector_center_z = body_back_z - connector_d_mm/2 + overlap_mm;

  // Side clips: touch body sides and overlap into body
  clip_left_x  = -overall_width_mm/2 - clip_w_mm/2 + overlap_mm;
  clip_right_x =  overall_width_mm/2 + clip_w_mm/2 - overlap_mm;

  // Put clips roughly mid-depth of body (not floating)
  clip_center_z = body_center_z; // centered with body so they intersect

  // Front display window: recessed pocket (not through)
  window_recess_depth = min(1.4, bezel_thickness_mm - 0.6);
  window_center_z = bezel_thickness_mm/2 - window_recess_depth/2; // pocket starts at front face
  window_y_offset = -bezel_height_mm * 0.10;

  // Add a shallow "screen bezel" frame around the window (raised ring)
  screen_frame_t = 0.8;
  screen_frame_w = 1.6;

  // Buttons on front face (protruding)
  button_center_z = bezel_thickness_mm/2 + button_height_mm/2 - overlap_mm;

  // Small "indicator" bump (common on these meters) near top-left of window area
  indicator_d = 2.2;
  indicator_h = 0.6;
  indicator_center_z = bezel_thickness_mm/2 + indicator_h/2 - overlap_mm;
  indicator_x = -display_window_width_mm/2 + indicator_d*1.2;
  indicator_y = window_y_offset + display_window_height_mm/2 + indicator_d*0.9;

  difference() {
    union() {
      // Bezel with lip detail (more recognizable than a plain slab)
      bezel_lip(
        bezel_width_mm, bezel_height_mm, bezel_thickness_mm,
        lip_w=0.8, lip_h=0.8, lip_t=0.9,
        r_outer=bezel_corner_r_mm, r_inner=1.6
      );

      // Main body (behind bezel)
      translate([0, 0, body_center_z])
        rrect3d(overall_width_mm, overall_height_mm, overall_depth_mm, 1.2);

      // Side mounting clips/ears (left/right), connected
      translate([clip_left_x, clip_y_offset_mm, clip_center_z])
        rrect3d(clip_w_mm, clip_h_mm, clip_d_mm, 0.8);

      translate([clip_right_x, clip_y_offset_mm, clip_center_z])
        rrect3d(clip_w_mm, clip_h_mm, clip_d_mm, 0.8);

      // Back terminal block (connected)
      translate([0, -overall_height_mm*0.18, terminal_center_z])
        rrect3d(terminal_block_w_mm, terminal_block_h_mm, terminal_block_d_mm, 0.8);

      // Back connector (connected)
      translate([0, overall_height_mm*0.22, connector_center_z])
        rrect3d(connector_w_mm, connector_h_mm, connector_d_mm, 0.8);

      // Raised screen frame ring on front (connected to bezel)
      translate([0, window_y_offset, bezel_thickness_mm/2 + screen_frame_t/2 - overlap_mm])
        difference() {
          rrect3d(display_window_width_mm + 2*screen_frame_w,
                  display_window_height_mm + 2*screen_frame_w,
                  screen_frame_t, 1.2);
          rrect3d(display_window_width_mm,
                  display_window_height_mm,
                  screen_frame_t + 2*overlap_mm, 1.0);
        }

      // Buttons (two), connected to bezel front
      for (i = [0:button_count-1]) {
        bx = i*button_spacing_mm - (button_count-1)*button_spacing_mm/2;
        translate([bx, button_row_offset_y_mm, button_center_z])
          cylinder(h=button_height_mm, r=button_diameter_mm/2, center=true);
      }

      // Small indicator bump (connected)
      translate([indicator_x, indicator_y, indicator_center_z])
        cylinder(h=indicator_h, r=indicator_d/2, center=true);
    }

    // Display window recess pocket (recognizable screen cutout)
    translate([0, window_y_offset, window_center_z])
      rrect3d(display_window_width_mm, display_window_height_mm,
              window_recess_depth + 2*overlap_mm, display_window_r_mm);

    // Subtle front-face relief to avoid "blank block" look (kept shallow)
    // Creates a shallow inset panel area around the screen/buttons.
    inset_t = 0.6;
    translate([0, 0, bezel_thickness_mm/2 - inset_t/2])
      rrect3d(bezel_width_mm - 2.0, bezel_height_mm - 2.0,
              inset_t + 2*overlap_mm, 1.6);
  }
}

// Render
pzem001_solid();