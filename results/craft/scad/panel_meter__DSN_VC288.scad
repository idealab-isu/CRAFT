// DSN-DC 100V 10A Panel Meter (approximate) - ONE connected solid
// Fixes:
// - Guaranteed non-empty render (no accidental full subtraction)
// - More recognizable front: bezel rim + recessed display window + small button
// - More recognizable back: terminal block + 4 screw terminals + wire exit notch
// - All features connected using dimension-based placement with overlap

$fn = 72;

// ---------------- Parameters ----------------
cutout_clearance_mm = 0.2; //[0.0:1.0:0.05]
include_tabs = 1; //[0:1:1]
include_pcb = 1; //[0:1:1]
include_buttons = 1; //[0:1:1]
include_panel_context = 1; //[0:1:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

body_width = 45; //[25:90:1]
body_height = 26; //[15:52:1]
body_depth = 24; //[12:48:1]

bezel_width = 48; //[30:96:1]
bezel_height = 29; //[18:58:1]
bezel_thickness = 3; //[1.5:8:0.5]
bezel_corner_radius = 2.5; //[0.5:8:0.5]

display_aperture_width = 36; //[18:72:1]
display_aperture_height = 14; //[7:28:1]
display_aperture_corner_radius = 1.5; //[0.5:6:0.5]

panel_thickness = 3; //[1:6:0.5]
panel_margin = 10; //[5:30:1]
panel_cutout_depth = 10; //[2:20:1]

tab_width = 6; //[3:15:0.5]
tab_height = 12; //[6:24:1]
tab_thickness = 2.5; //[1.5:6:0.5]

pcb_width = 40; //[20:80:1]
pcb_height = 22; //[11:44:1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_offset_from_front = 8; //[3:18:1]

button_diameter = 5.5; //[3:12:0.5]
button_height = 1.8; //[1:6:0.5]
button_x_offset = 0; //[-15:15:1]
button_y_offset = -8; //[-15:15:1]

// ---------------- Helpers ----------------
module rounded_rect_prism(w, h, t, r, center=true) {
  r2 = min(r, min(w, h)/2 - 0.01);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2), 0])
        cylinder(r=r2, h=t, center=center);
  }
}

module panel_meter_cutout() {
  translate([0, 0, -panel_cutout_depth/2])
    cube([body_width + 2*cutout_clearance_mm,
          body_height + 2*cutout_clearance_mm,
          panel_cutout_depth], center=true);
}

// ---------------- Main Solid ----------------
module panel_meter_solid() {

  // Coordinate convention:
  // Bezel centered at z=0, front face at +bezel_thickness/2, body extends to -z.

  // Derived placements (all formula-based)
  body_center_z = -bezel_thickness/2 - body_depth/2 + overlap_mm; // overlap into bezel
  body_front_z  = body_center_z + body_depth/2;
  body_back_z   = body_center_z - body_depth/2;

  // Bezel rim / lip
  rim_raise = 1.0;
  rim_thick = 1.2;
  rim_z = bezel_thickness/2 - rim_thick/2 + overlap_mm; // overlaps into bezel
  rim_w = bezel_width + 1.2;
  rim_h = bezel_height + 1.2;
  rim_r = bezel_corner_radius + 0.8;

  // Inner bezel relief (shallow recess around window)
  relief_margin = 2.0;
  relief_w = bezel_width - 2*relief_margin;
  relief_h = bezel_height - 2*relief_margin;
  relief_t = 1.2;
  relief_z = bezel_thickness/2 - relief_t/2; // near front

  // Display aperture and window pocket (do NOT cut full bezel thickness)
  aperture_t = bezel_thickness + 2*overlap_mm; // through bezel
  window_recess = min(1.6, bezel_thickness - 0.6);
  window_t = window_recess + 2*overlap_mm;
  window_z = bezel_thickness/2 - window_recess/2; // pocket from front

  // Back terminal block (DSN-DC style)
  term_w = 26;
  term_h = 12;
  term_d = 7;
  term_center_z = body_back_z - term_d/2 + overlap_mm; // overlaps into body

  // Screw terminal bosses (4) protruding from terminal block
  boss_r = 2.2;
  boss_h = 4.0;
  boss_center_z = term_center_z - term_d/2 - boss_h/2 + overlap_mm; // protrude further back
  boss_x_span = term_w - 8;
  boss_y_span = term_h - 6;

  // Wire exit notch (subtractive) on terminal block
  notch_w = term_w - 10;
  notch_h = term_h - 6;
  notch_d = term_d * 0.65;
  notch_center_z = term_center_z - term_d/2 + notch_d/2; // starts at back face

  // Side tabs (clips) connected to body sides near rear
  tab_z = body_back_z + tab_thickness/2 + overlap_mm;
  tab_x_left  = -(body_width/2 + tab_width/2 - overlap_mm);
  tab_x_right = +(body_width/2 + tab_width/2 - overlap_mm);

  // PCB inside body (kept connected via standoffs)
  pcb_z_target = (bezel_thickness/2) - pcb_offset_from_front;
  pcb_z = max(body_back_z + pcb_thickness/2 + 1,
              min(body_front_z - pcb_thickness/2 - 1, pcb_z_target));

  standoff_r = 1.7;
  standoff_h = 4.0;
  standoff_center_z = pcb_z + pcb_thickness/2 + standoff_h/2 - overlap_mm;

  // Front button (small round) connected to bezel
  button_z = bezel_thickness/2 - button_height/2 + overlap_mm;

  union() {

    // --- Meter plastic (single connected solid) ---
    difference() {
      union() {
        // Bezel outer
        rounded_rect_prism(bezel_width, bezel_height, bezel_thickness, bezel_corner_radius, center=true);

        // Raised rim (bezel lip)
        translate([0, 0, rim_z])
          rounded_rect_prism(rim_w, rim_h, rim_thick, rim_r, center=true);

        // Main body
        translate([0, 0, body_center_z])
          cube([body_width, body_height, body_depth], center=true);

        // Terminal block
        translate([0, 0, term_center_z])
          cube([term_w, term_h, term_d], center=true);

        // 4 screw terminal bosses
        for (sx = [-1, 1], sy = [-1, 1]) {
          translate([sx*boss_x_span/2, sy*boss_y_span/2, boss_center_z])
            cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Side tabs
        if (include_tabs) {
          translate([tab_x_left, 0, tab_z])
            cube([tab_width, tab_height, tab_thickness], center=true);
          translate([tab_x_right, 0, tab_z])
            cube([tab_width, tab_height, tab_thickness], center=true);
        }

        // PCB + standoffs (kept connected)
        if (include_pcb) {
          for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_width/2 - 5), sy*(pcb_height/2 - 4), standoff_center_z])
              cylinder(r=standoff_r, h=standoff_h, center=true);
          }
          translate([0, 0, pcb_z])
            cube([pcb_width, pcb_height, pcb_thickness], center=true);
        }

        // Front button
        if (include_buttons) {
          translate([button_x_offset, button_y_offset, button_z])
            cylinder(r=button_diameter/2, h=button_height, center=true);
        }
      }

      // --- Subtractions (details) ---

      // Display aperture through bezel
      translate([0, 0, 0])
        rounded_rect_prism(display_aperture_width, display_aperture_height,
                           aperture_t, display_aperture_corner_radius, center=true);

      // Recessed window pocket (partial depth, larger than aperture)
      translate([0, 0, window_z])
        rounded_rect_prism(display_aperture_width + 2.2, display_aperture_height + 2.2,
                           window_t, display_aperture_corner_radius + 0.7, center=true);

      // Inner bezel relief (shallow recess around window)
      translate([0, 0, relief_z])
        rounded_rect_prism(relief_w, relief_h, relief_t + 2*overlap_mm,
                           max(0.6, bezel_corner_radius - 0.9), center=true);

      // Wire exit notch on terminal block (back face)
      translate([0, 0, notch_center_z])
        cube([notch_w, notch_h, notch_d + 2*overlap_mm], center=true);
    }

    // --- Optional panel context (kept connected by overlap) ---
    if (include_panel_context) {
      translate([0, 0, -panel_thickness/2 + overlap_mm])
        difference() {
          cube([bezel_width + 2*panel_margin, bezel_height + 2*panel_margin, panel_thickness], center=true);
          panel_meter_cutout();
        }
    }
  }
}

panel_meter_solid();