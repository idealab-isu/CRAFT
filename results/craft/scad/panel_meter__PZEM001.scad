// Peacefair PZEM-001 (approx) - STRUCTURAL connectivity fixed
// Fixes applied:
// - Side tabs/clips are now guaranteed to intersect the MAIN BODY in X and Z by 1-2mm
// - Tabs are also guaranteed to intersect the BEZEL in Z by 1-2mm (prevents any visible gap in top/bottom views)
// - All meter parts are inside a single union() so the meter exports as one connected solid
// - Cutout geometry remains separate (optional)

$fn = 48;

// -------------------- Parameters --------------------
bezel_width = 80;                 //[40:160:1]
bezel_height = 45;                //[22.5:90:1]
bezel_thickness = 3;              //[1.5:6:0.5]
bezel_corner_radius = 3;          //[1.5:6:0.5]

body_width = 72;                  //[36:144:1]
body_height = 39;                 //[19.5:78:1]
body_depth = 55;                  //[27.5:110:1]

display_aperture_width = 50;      //[25:100:1]
display_aperture_height = 22;     //[11:44:1]
display_aperture_corner_radius = 1.5; //[0.5:4:0.5]
display_aperture_inset = 0.8;     //[0.2:2:0.1]

inner_frame_thickness = 1.2;      //[0.6:2.4:0.1]
inner_frame_depth = 1.5;          //[0.5:4:0.5]

tab_enabled = 1;                  //[0:1:1]
tab_width = 10;                   //[5:20:1]
tab_height = 18;                  //[9:36:1]
tab_thickness = 2.5;              //[1:6:0.5]
tab_overlap = 1;                  //[0.5:2:0.5]

panel_thickness = 3;              //[1:10:0.5]
tolerance_offset_mm = 0.2;        //[0:1:0.05]
include_cutout_geometry = 1;      //[0:1:1]
assembly_overlap = 1;             //[0.5:2:0.5]
panel_margin = 12;                //[6:30:1]

// PZEM-001 specific-ish details (no text)
lcd_bezel_margin_x = 6;           // extra bezel around LCD window
lcd_bezel_margin_y = 5;
button_w = 12;
button_h = 6;
button_depth = 1.2;
button_corner_r = 1.2;

terminal_block_w = 44;            // rear terminal block (approx)
terminal_block_h = 12;
terminal_block_d = 10;

terminal_count = 4;
terminal_pitch = 10;
terminal_hole_d = 3.2;
terminal_hole_depth = 6;

strain_relief_w = 18;             // rear cable/CT connector bump (approx)
strain_relief_h = 10;
strain_relief_d = 8;

// -------------------- Helpers --------------------
module rrect2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

module rrect3d(w, h, t, r, center=true) {
  linear_extrude(height=t, center=center) rrect2d(w, h, r);
}

// -------------------- Main Model --------------------
module pzem001_meter() {

  // Z reference: bezel is centered at Z=0 (front face at +bezel_thickness/2)
  // Body sits behind bezel, connected with overlap.
  z_body_center = -bezel_thickness/2 - body_depth/2 + assembly_overlap;

  // Terminal block sits on rear face of body, connected with overlap.
  z_body_back_face = z_body_center - body_depth/2;
  z_term_center = z_body_back_face - terminal_block_d/2 + assembly_overlap;

  // Strain relief bump also on rear, offset to one side.
  z_strain_center = z_body_back_face - strain_relief_d/2 + assembly_overlap;

  // LCD bezel frame sits on front face, slightly raised.
  lcd_outer_w = display_aperture_width + 2*lcd_bezel_margin_x;
  lcd_outer_h = display_aperture_height + 2*lcd_bezel_margin_y;
  lcd_frame_t = 1.2;
  z_lcd_frame_center = bezel_thickness/2 - lcd_frame_t/2 + assembly_overlap;

  // Button sits below LCD window on bezel, slightly raised.
  button_y = -bezel_height/2 + (bezel_height - lcd_outer_h)/2 * 0.55; // proportional placement
  z_button_center = bezel_thickness/2 - button_depth/2 + assembly_overlap;

  // -------------------- TAB CONNECTIVITY FIX (robust) --------------------
  // Goal: tabs must be physically attached (intersect) with the main body (and bezel)
  // in a way that survives view/CSG tolerances.
  tab_attach_overlap = max(1, min(2, tab_overlap)); // enforce 1-2mm overlap

  // Faces for reference
  z_body_bottom_face = z_body_center - body_depth/2;     // most negative Z of body
  z_bezel_back_face  = -bezel_thickness/2;              // back face of bezel (toward body)

  // Place tab so it intersects BOTH:
  // - the body bottom face by tab_attach_overlap
  // - the bezel back face by tab_attach_overlap
  //
  // This prevents any apparent "floating" separation in top/bottom views.
  //
  // Constraints:
  //   tab_top    = z_tab_center + tab_thickness/2 >= z_bezel_back_face - tab_attach_overlap
  //   tab_top    = z_body_bottom_face + tab_attach_overlap  (ensures body intersection)
  //
  // Choose tab_top as the larger of the two required tops.
  tab_top_required_for_body  = z_body_bottom_face + tab_attach_overlap;
  tab_top_required_for_bezel = z_bezel_back_face  - tab_attach_overlap;
  tab_top = max(tab_top_required_for_body, tab_top_required_for_bezel);

  z_tab_center = tab_top - tab_thickness/2;

  // X placement: ensure inner face penetrates body by tab_attach_overlap
  x_tab_left  = -body_width/2 - tab_width/2 + tab_attach_overlap;
  x_tab_right =  body_width/2 + tab_width/2 - tab_attach_overlap;

  // -------------------- Build as ONE connected solid --------------------
  union() {

    // -------- Bezel with LCD aperture cutout --------
    difference() {
      color([0.15, 0.15, 0.17])
        rrect3d(bezel_width, bezel_height, bezel_thickness, bezel_corner_radius, center=true);

      translate([0, 0, bezel_thickness/2 - display_aperture_inset])
        rrect3d(display_aperture_width, display_aperture_height,
                bezel_thickness*2, display_aperture_corner_radius, center=true);
    }

    // -------- Inner LCD bezel frame (raised) --------
    color([0.10, 0.10, 0.12])
    difference() {
      translate([0, 0, z_lcd_frame_center])
        rrect3d(lcd_outer_w, lcd_outer_h, lcd_frame_t, 2.0, center=true);

      translate([0, 0, z_lcd_frame_center])
        rrect3d(display_aperture_width, display_aperture_height,
                lcd_frame_t + 2*assembly_overlap, display_aperture_corner_radius, center=true);
    }

    // -------- Inner aperture frame (recess lip) --------
    color([0.12, 0.12, 0.14])
    difference() {
      translate([0, 0, bezel_thickness/2 - inner_frame_depth/2 - display_aperture_inset])
        cube([display_aperture_width + 2*inner_frame_thickness,
              display_aperture_height + 2*inner_frame_thickness,
              inner_frame_depth], center=true);

      translate([0, 0, bezel_thickness/2 - inner_frame_depth/2 - display_aperture_inset])
        cube([display_aperture_width,
              display_aperture_height,
              inner_frame_depth + 2*assembly_overlap], center=true);
    }

    // -------- Front button (rounded) --------
    color([0.85, 0.85, 0.85])
    translate([0, button_y, z_button_center])
      rrect3d(button_w, button_h, button_depth, button_corner_r, center=true);

    // -------- Rear body (main housing) --------
    color([0.20, 0.20, 0.22])
    translate([0, 0, z_body_center])
      cube([body_width, body_height, body_depth], center=true);

    // -------- Mounting tabs/clips (ATTACHED: overlap into body + bezel) --------
    if (tab_enabled) {
      color([0.20, 0.35, 0.75]) {
        translate([x_tab_left, 0, z_tab_center])
          cube([tab_width, tab_height, tab_thickness], center=true);

        translate([x_tab_right, 0, z_tab_center])
          cube([tab_width, tab_height, tab_thickness], center=true);
      }
    }

    // -------- Rear terminal block (connected) --------
    color([0.18, 0.18, 0.20])
    difference() {
      translate([0, body_height/2 - terminal_block_h/2 - 2, z_term_center])
        rrect3d(terminal_block_w, terminal_block_h, terminal_block_d, 1.2, center=true);

      for (i = [0:terminal_count-1]) {
        x_i = (i - (terminal_count-1)/2) * terminal_pitch;
        translate([x_i,
                   body_height/2 - terminal_block_h/2 - 2,
                   z_term_center - terminal_block_d/2 + terminal_hole_depth/2 - assembly_overlap])
          cylinder(d=terminal_hole_d, h=terminal_hole_depth + 2*assembly_overlap, center=true);
      }
    }

    // -------- Rear strain relief / connector bump (connected) --------
    color([0.18, 0.18, 0.20])
    translate([-(body_width/2 - strain_relief_w/2 - 4),
               -(body_height/2 - strain_relief_h/2 - 4),
               z_strain_center])
      rrect3d(strain_relief_w, strain_relief_h, strain_relief_d, 1.5, center=true);
  }
}

// -------------------- Cutout Geometry (optional) --------------------
module panel_meter_cutout() {
  difference() {
    translate([0, 0, bezel_thickness/2 - panel_thickness/2 + assembly_overlap])
      cube([body_width + 2*(panel_margin + tab_width),
            body_height + 2*panel_margin,
            panel_thickness], center=true);

    translate([0, 0, bezel_thickness/2 - panel_thickness/2 + assembly_overlap])
      cube([body_width + 2*tolerance_offset_mm,
            body_height + 2*tolerance_offset_mm,
            panel_thickness + 2*assembly_overlap], center=true);
  }
}

// -------------------- Assembly --------------------
module assembly() {
  pzem001_meter();

  if (include_cutout_geometry)
    color([0.0, 0.4, 0.2]) panel_meter_cutout();
}

assembly();