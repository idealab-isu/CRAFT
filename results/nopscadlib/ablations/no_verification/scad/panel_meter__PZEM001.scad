// Peacefair PZEM-001 style panel meter (single connected solid, no text)
// Fixes:
// - Non-empty render with clear front/back differences
// - Visible bezel step + display window recess + button
// - Rear terminal block with wire ports (holes along Z, not rotated wrong)
// - All parts connected using dimension-based placement (no arbitrary floats)

$fn = 64;

// -------------------- Parameters --------------------
tolerance = 0.2; //[0.05:0.6:0.05]
overlap   = 1;   //[0.5:2:0.1]

// Overall
bezel_width     = 80; //[40:160:1]
bezel_height    = 40; //[20:80:1]
bezel_thickness = 3;  //[1.5:8:0.5]
corner_radius   = 2;  //[0.5:6:0.5]

body_width  = 76; //[38:152:1]
body_height = 36; //[18:72:1]
body_depth  = 60; //[30:120:1]

// Front details
display_aperture_width    = 60; //[30:120:1]
display_aperture_height   = 22; //[11:44:1]
display_aperture_offset_x = 0;  //[-10:10:0.5]
display_aperture_offset_y = 2;  //[-10:10:0.5]

// Bezel styling
bezel_lip_inset   = 2.0; //[0.5:6:0.5]   // inner step inset
bezel_lip_depth   = 1.2; //[0.5:3:0.1]   // depth of inner step
bezel_frame_raise = 0.6; //[0.2:2:0.1]   // slight raised outer frame

// Mounting tabs (side ears)
tab_width    = 10; //[5:25:0.5]
tab_height   = 18; //[8:40:1]
tab_depth    = 3;  //[1.5:8:0.5]
tab_offset_z = 10; //[0:30:1]

// Button
button_count    = 1;   //[0:3:1]
button_width    = 10;  //[6:20:0.5]
button_height   = 6;   //[3:15:0.5]
button_depth    = 1.5; //[0.8:5:0.1]
button_offset_x = 0;   //[-20:20:0.5]
button_offset_y = -12; //[-20:20:0.5]
button_corner_r = 1.2; //[0.5:3:0.1]

// Rear terminal block / connector
terminal_block_w = 44; //[20:70:1]
terminal_block_h = 14; //[8:25:1]
terminal_block_d = 12; //[6:25:1]
terminal_offset_y = -6; //[-12:12:0.5]

wire_port_count = 4; //[2:6:1]
wire_port_r     = 2.2; //[1.2:4:0.1]
wire_port_pitch = 9.5; //[6:14:0.1]
wire_port_inset = 2.5; //[1:6:0.1]

// Rear strain relief / small boss
rear_boss_w = 22; //[10:40:1]
rear_boss_h = 10; //[6:20:1]
rear_boss_d = 6;  //[3:15:0.5]
rear_boss_offset_y = 10; //[-12:12:0.5]

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rounded_box(w, h, d, r, center=true) {
  linear_extrude(height=d, center=center)
    rounded_rect_2d(w, h, r);
}

module pill_box(w, h, d, r, center=true) {
  rounded_box(w, h, d, min(r, min(w,h)/2), center);
}

// -------------------- Model --------------------
module pzem001_panel_meter_solid() {

  // Coordinate convention:
  // Z+ is front (bezel face), Z- is rear (terminals).
  z_front =  bezel_thickness/2;
  z_back  = -bezel_thickness/2 - body_depth;

  // Main body: overlaps into bezel so union is connected
  z_body_center = -(bezel_thickness/2 + body_depth/2 - overlap);

  // Side tabs: attached to body sides, slightly behind bezel
  z_tab_center = -(bezel_thickness/2 + tab_offset_z);
  x_tab = body_width/2 + tab_width/2 - overlap;

  // Terminal block: attached to rear face of body (overlap into body)
  z_terminal_center = z_back - terminal_block_d/2 + overlap;
  y_terminal = terminal_offset_y;

  // Rear boss: attached to rear face too
  z_boss_center = z_back - rear_boss_d/2 + overlap;
  y_boss = rear_boss_offset_y;

  // Button: protrudes from bezel front with slight overlap into bezel
  z_button_center = z_front + button_depth/2 - overlap;

  // Bezel: solid with recessed display window + inner step
  module bezel_solid() {
    union() {
      // Base bezel slab (centered at z=bezel_thickness/2)
      translate([0,0,bezel_thickness/2])
        rounded_box(bezel_width, bezel_height, bezel_thickness, corner_radius, center=true);

      // Raised outer frame (adds recognizable bezel styling)
      translate([0,0,bezel_thickness + bezel_frame_raise/2 - overlap])
        rounded_box(bezel_width - 1.2, bezel_height - 1.2, bezel_frame_raise,
                    max(0.5, corner_radius-0.5), center=true);
    }
  }

  module bezel_with_recesses() {
    difference() {
      bezel_solid();

      // Display aperture cut-through (window)
      translate([display_aperture_offset_x, display_aperture_offset_y, bezel_thickness/2])
        cube([display_aperture_width + 2*tolerance,
              display_aperture_height + 2*tolerance,
              bezel_thickness + bezel_frame_raise + 4*overlap], center=true);

      // Inner bezel step recess (shallow pocket around display)
      translate([0,0,bezel_thickness - bezel_lip_depth/2 + overlap])
        rounded_box(bezel_width - 2*bezel_lip_inset,
                    bezel_height - 2*bezel_lip_inset,
                    bezel_lip_depth + 2*overlap,
                    max(0.5, corner_radius-0.8),
                    center=true);
    }
  }

  module body_solid() {
    translate([0,0,z_body_center])
      rounded_box(body_width, body_height, body_depth, max(0.8, corner_radius-0.6), center=true);
  }

  module side_tabs_solid() {
    union() {
      translate([-x_tab, 0, z_tab_center])
        rounded_box(tab_width, tab_height, tab_depth, 1.0, center=true);
      translate([ x_tab, 0, z_tab_center])
        rounded_box(tab_width, tab_height, tab_depth, 1.0, center=true);
    }
  }

  module button_solid() {
    for (i = [0:max(0,button_count-1)]) {
      x_i = button_offset_x + (i - (button_count-1)/2) * (button_width + 2);
      translate([x_i, button_offset_y, z_button_center])
        pill_box(button_width, button_height, button_depth, button_corner_r, center=true);
    }
  }

  module terminal_block_solid() {
    translate([0, y_terminal, z_terminal_center])
      rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2, center=true);
  }

  module rear_boss_solid() {
    translate([0, y_boss, z_boss_center])
      rounded_box(rear_boss_w, rear_boss_h, rear_boss_d, 1.2, center=true);
  }

  // Build one connected solid, then subtract connector holes/details
  difference() {
    union() {
      bezel_with_recesses();
      body_solid();
      side_tabs_solid();
      if (button_count > 0) button_solid();
      terminal_block_solid();
      rear_boss_solid();
    }

    // Wire ports: cylindrical holes along Z (rear-to-front), located in terminal block
    port_span = (wire_port_count-1) * wire_port_pitch;
    for (i = [0:wire_port_count-1]) {
      x_port = (i * wire_port_pitch) - port_span/2;

      // Clamp to keep inside terminal width (formula-based)
      x_port2 = max(-(terminal_block_w/2 - wire_port_r - 1),
                    min( (terminal_block_w/2 - wire_port_r - 1), x_port));

      // Hole center: near rear face of terminal block, inset forward by wire_port_inset
      z_port_abs = z_terminal_center + (-terminal_block_d/2 + wire_port_inset);

      translate([x_port2, y_terminal, z_port_abs])
        cylinder(h=terminal_block_d + 4*overlap, r=wire_port_r, center=true); // along Z by default
    }

    // Screwdriver access slot on terminal top (subtle detail)
    slot_w = terminal_block_w - 6;
    slot_h = 3.2;
    slot_d = terminal_block_d - 3;

    translate([0,
               y_terminal + terminal_block_h/2 - slot_h/2 - 1.2,
               z_terminal_center])
      cube([slot_w, slot_h, slot_d + 2*overlap], center=true);

    // Add a shallow rear face relief on the body to emphasize front/back difference
    // (still keeps one connected solid; this is a subtraction only)
    relief_w = body_width - 10;
    relief_h = body_height - 10;
    relief_d = 1.2;

    translate([0, 0, z_back + relief_d/2 + overlap])
      rounded_box(relief_w, relief_h, relief_d + 2*overlap, max(0.6, corner_radius-1.0), center=true);
  }
}

// Render
color("Black") pzem001_panel_meter_solid();