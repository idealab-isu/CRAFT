// Peacefair PZEM-021 AC panel meter (approximate geometry)
// One connected solid; no text/labels; all placements derived from dimensions.

$fn = 64;

// Toggles (kept for compatibility; final output is one connected solid regardless)
include_bezel = 1; //[0:1:1]
include_cutout = 0; //[0:1:1]
include_tabs = 1; //[0:1:1]
include_pcb_envelope = 0; //[0:1:1]
include_buttons = 1; //[0:1:1]

// General
general_clearance = 0.2; //[0.1:0.6:0.05]
panel_cutout_offset = 0.2; //[0.0:0.6:0.05]
overlap = 1.0; //[0.5:2.0:0.1]

// Front bezel / body
bezel_w = 85; //[60:170:1]
bezel_h = 45; //[30:90:1]
bezel_t = 3; //[2:6:0.5]

body_w = 79; //[55:158:1]
body_h = 43; //[30:86:1]
body_d = 35; //[20:70:1]
wall_t = 2; //[1:4:0.5]

// Display window (LCD opening)
display_ap_w = 60; //[40:120:1]
display_ap_h = 26; //[16:52:1]
display_window_inset = 0.6; //[0.2:2:0.1]

// Bezel details (typical PZEM-021 look)
bezel_frame_t = 1.2;          // raised frame thickness on front
bezel_frame_margin = 2.2;     // frame width around inner face
lcd_lip_t = 0.8;              // small raised lip around LCD window
lcd_lip_w = 1.2;              // lip width

// Buttons (front)
button_w = 8; //[4:16:1]
button_h = 6; //[3:12:1]
button_t = 1.5; //[0.8:4:0.1]
button_x_offset = 28; //[10:60:1]
button_y_offset = -12; //[-30:30:1]

// Side mounting tabs (panel clips)
tab_w = 10; //[6:20:1]   // depth (z)
tab_h = 18; //[10:36:1]  // height (y)
tab_t = 3; //[2:6:0.5]   // thickness (x)
tab_z_from_front = 10; //[5:25:1]

// Panel cutout (kept but disabled by default to preserve "one connected solid")
panel_t = 3; //[1:10:0.5]
panel_margin = 12; //[6:30:1]

// Rear terminal block (approximate PZEM-021 feature)
term_block_w = 34;
term_block_h = 16;
term_block_d = 12;
term_block_offset_y = -(body_h/2 - term_block_h/2 - 4); // near bottom edge

// Screw bosses on terminal block
boss_r = 2.2;
boss_h = 2.0;

// Wire ports (recessed holes)
port_r = 2.2;
port_depth = 6;

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

module panel_meter_solid() {
  // Coordinate convention:
  // Front face of bezel at z = 0, positive z forward, negative z backward.
  // Bezel spans z in [-bezel_t, 0]
  // Body spans z in [-bezel_t - body_d, -bezel_t]

  // Derived Z positions
  bezel_center_z = -bezel_t/2;
  body_center_z  = -bezel_t - body_d/2 + overlap/2; // overlap into bezel for watertight union

  // Display recess pocket (bezel pocket) and through-window
  recess_w = display_ap_w + 10;
  recess_h = display_ap_h + 10;
  recess_d = min(bezel_t - 0.4, 1.6); // shallow pocket
  window_cut_d = bezel_t + 2*overlap;

  // Rear cavity (hollow body) - open from rear
  cavity_w = body_w - 2*wall_t;
  cavity_h = body_h - 2*wall_t;
  cavity_d = body_d - wall_t; // keep some back thickness

  // Terminal block placement (attached to rear face)
  term_center_z = (-bezel_t - body_d) - term_block_d/2 + overlap/2;

  // Side tabs placement (attached to body sides)
  tab_center_x = body_w/2 + tab_t/2 - overlap/2;
  tab_center_z = -tab_z_from_front;

  // Button placement (on bezel front surface, protruding slightly)
  button_center_z = 0 + button_t/2 - overlap/2;

  // Bezel front frame (raised border) placement
  frame_center_z = 0 - bezel_frame_t/2 + overlap/2;

  // LCD lip (raised around window) placement
  lcd_lip_center_z = 0 - lcd_lip_t/2 + overlap/2;

  // Inner face opening for frame (keeps a border)
  frame_inner_w = bezel_w - 2*bezel_frame_margin;
  frame_inner_h = bezel_h - 2*bezel_frame_margin;

  // LCD lip outer/inner sizes
  lcd_lip_outer_w = display_ap_w + 2*(lcd_lip_w + 0.6);
  lcd_lip_outer_h = display_ap_h + 2*(lcd_lip_w + 0.6);
  lcd_lip_inner_w = display_ap_w + 2*general_clearance;
  lcd_lip_inner_h = display_ap_h + 2*general_clearance;

  union() {
    difference() {
      union() {
        // Bezel (slightly rounded)
        if (include_bezel)
          translate([0,0,bezel_center_z])
            rounded_box([bezel_w, bezel_h, bezel_t], r=1.2, center=true);

        // Raised front frame (typical bezel detail)
        if (include_bezel)
          translate([0,0,frame_center_z])
            difference() {
              rounded_box([bezel_w, bezel_h, bezel_frame_t], r=1.2, center=true);
              // inner opening to create a frame ring; overlap ensures clean subtraction
              translate([0,0,0])
                rounded_box([frame_inner_w, frame_inner_h, bezel_frame_t + 2*overlap], r=0.8, center=true);
            }

        // LCD lip around window (small raised ring)
        if (include_bezel)
          translate([0,0,lcd_lip_center_z])
            difference() {
              rounded_box([lcd_lip_outer_w, lcd_lip_outer_h, lcd_lip_t], r=0.8, center=true);
              rounded_box([lcd_lip_inner_w, lcd_lip_inner_h, lcd_lip_t + 2*overlap], r=0.4, center=true);
            }

        // Body (slightly rounded)
        translate([0,0,body_center_z])
          rounded_box([body_w, body_h, body_d], r=1.0, center=true);

        // Side mounting tabs/clips (two) - connected to body sides
        if (include_tabs) {
          for (sx = [-1, 1]) {
            translate([sx*tab_center_x, 0, tab_center_z])
              rounded_box([tab_t, tab_h, tab_w], r=0.8, center=true);
          }
        }

        // Rear terminal block (attached)
        translate([0, term_block_offset_y, term_center_z])
          rounded_box([term_block_w, term_block_h, term_block_d], r=0.8, center=true);

        // Small screw bosses on terminal block rear face (protrusions)
        for (i = [-1, 1]) {
          translate([i*(term_block_w/2 - 7),
                     term_block_offset_y,
                     (-bezel_t - body_d) - boss_h/2 + overlap/2])
            cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Buttons (two) on front bezel
        if (include_buttons) {
          for (i = [0:1]) {
            translate([button_x_offset - i*(button_w + 3), button_y_offset, button_center_z])
              rounded_box([button_w, button_h, button_t], r=0.6, center=true);
          }
        }

        // Optional internal PCB envelope (kept connected by being inside; no difference)
        if (include_pcb_envelope) {
          pcb_w = body_w - 2*(wall_t + 1);
          pcb_h = body_h - 2*(wall_t + 1);
          pcb_d = 1.6;
          pcb_center_z = -bezel_t - (body_d - wall_t) + pcb_d/2 + 6; // derived: near rear but inside
          translate([0,0,pcb_center_z])
            cube([pcb_w, pcb_h, pcb_d], center=true);
        }
      }

      // Display recess pocket in bezel (not through)
      translate([0,0, -display_window_inset - recess_d/2])
        cube([recess_w, recess_h, recess_d + 2*overlap], center=true);

      // Display window through-cut (LCD opening)
      translate([0,0,bezel_center_z])
        cube([display_ap_w + 2*general_clearance,
              display_ap_h + 2*general_clearance,
              window_cut_d], center=true);

      // Internal cavity (hollow body), open from rear (do not cut through bezel)
      translate([0,0, -bezel_t - (body_d - cavity_d)/2 - cavity_d/2])
        cube([cavity_w, cavity_h, cavity_d + overlap], center=true);

      // Wire ports (recessed holes) on rear terminal block face
      for (i = [-1.5, -0.5, 0.5, 1.5]) {
        translate([i*(term_block_w/5),
                   term_block_offset_y,
                   (-bezel_t - body_d) + port_depth/2 - overlap/2])
          rotate([180,0,0])
            cylinder(r=port_r, h=port_depth + overlap, center=true);
      }

      // Screw holes (shallow) on rear bosses
      for (i = [-1, 1]) {
        translate([i*(term_block_w/2 - 7),
                   term_block_offset_y,
                   (-bezel_t - body_d) + boss_h/2])
          cylinder(r=boss_r*0.55, h=boss_h + 2*overlap, center=true);
      }
    }

    // Optional: panel cutout visualization (DISABLED by default; would be separate solid)
    if (include_cutout) {
      translate([0,0, -(bezel_t + panel_t/2 - overlap)])
        difference() {
          cube([body_w + 2*(panel_margin + panel_cutout_offset),
                body_h + 2*(panel_margin + panel_cutout_offset),
                panel_t], center=true);
          cube([body_w + 2*(panel_cutout_offset + general_clearance),
                body_h + 2*(panel_cutout_offset + general_clearance),
                panel_t + 2*overlap], center=true);
        }
    }
  }
}

panel_meter_solid();