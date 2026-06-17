// Ruideng-style panel meter / power supply module (improved resemblance)
// ONE connected solid, no floating parts, all translates are formula-based.
// Adds recognizable features: display window + bezel recess, bottom button strip,
// rotary encoder knob, rear terminal block with screw bumps, rear JST-style header,
// side spring clips, and rear mounting rails.

$fn = 64;

// ---------- Parameters ----------
bezel_W = 48;          //[24:96:1]
bezel_H = 29;          //[15:58:1]
bezel_T = 2.5;         //[1.2:5:0.1]

body_W  = 45;          //[22.5:90:0.5]
body_H  = 26;          //[13:52:0.5]
body_D  = 22;          //[11:44:1]

panel_T  = 3;          //[1.5:6:0.5]
cutout_W = 45.2;       //[22.6:90.4:0.1]
cutout_H = 26.2;       //[13.1:52.4:0.1]

overlap = 1;           //[0.5:2:0.1]
bezel_edge_r = 1.2;    //[0.5:3:0.1]

// Display + recess
display_win_W = 36;    //[18:72:0.5]
display_win_H = 16;    //[8:32:0.5]
screen_recess_margin = 2;   //[1:4:0.5]
screen_recess_depth  = 0.9; //[0.3:2:0.1]

// Bottom control strip (buttons area)
button_area_W = 36;    //[18:72:0.5]
button_area_H = 8;     //[4:16:0.5]
button_recess_depth = 0.9;  //[0.3:2:0.1]

// Front controls
encoder_r = 3.4;       //[2:6:0.1]
encoder_h = 2.0;       //[0.8:3:0.1]
btn_r = 1.6;           //[1:3:0.1]
btn_h = 1.4;           //[0.6:2.5:0.1]
btn_spacing = 8;       //[5:12:0.5]

// Flange lip
flange_extra = 2.0;    //[0.5:5:0.1]
flange_T = 1.2;        //[0.6:3:0.1]

// Side mounting clips (spring tabs)
clip_W = 6;            //[3:12:0.5]
clip_T = 1.5;          //[0.8:3:0.1]
clip_overhang = 1.8;   //[0.5:3:0.1]
clip_z_span = 10;      //[6:16:0.5]

// Rear terminal block (screw terminal)
connector_W = 22;      //[10:40:0.5]
connector_H = 9;       //[4:16:0.5]
connector_D = 8;       //[3:14:0.5]
term_screw_r = 1.4;    //[0.8:2.5:0.1]
term_screw_h = 1.2;    //[0.6:2.5:0.1]
term_pitch = 6.0;      //[4:8:0.1]
term_count = 3;        //[2:6:1]

// Rear JST-style header block
header_W = 12;         //[6:20:0.5]
header_H = 6;          //[3:12:0.5]
header_D = 6;          //[3:12:0.5]
header_pin_r = 0.8;    //[0.5:1.2:0.1]
header_pin_h = 1.2;    //[0.6:2.5:0.1]
header_pin_pitch = 2.54;
header_pin_count = 4;  //[2:8:1]

// Rear rails / ribs (common on modules)
rail_W = 6;            //[3:12:0.5]
rail_H = 3;            //[1.5:6:0.5]
rail_D = 10;           //[6:18:0.5]

// PCB placeholder + standoffs (kept connected)
pcb_W = 40;            //[20:80:0.5]
pcb_H = 22;            //[11:44:0.5]
pcb_T = 1.6;           //[0.8:3.2:0.1]
boss_r = 2.2;          //[1.2:4.4:0.1]
boss_h = 6;            //[3:12:0.5]
boss_inset = 3.5;      //[2:7:0.5]

// ---------- Z references ----------
function z_bezel_center() = 0;
function z_bezel_front()  = z_bezel_center() + bezel_T/2;
function z_bezel_back()   = z_bezel_center() - bezel_T/2;

function z_body_center()  = z_bezel_back() - body_D/2 + overlap; // overlaps into bezel
function z_body_back()    = z_body_center() - body_D/2;
function z_body_front()   = z_body_center() + body_D/2;

// Layout on front face
function y_display_center() = (bezel_H/2 - display_win_H/2 - button_area_H - 1);
function y_button_center()  = -(bezel_H/2 - button_area_H/2 - 1);

// ---------- Helpers ----------
module rounded_box(size=[10,10,2], r=1) {
  // Minkowski rounded edges
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=true);
    sphere(r=r);
  }
}

module chamfered_box(size=[10,10,2], c=0.8) {
  // Simple chamfer-ish look using hull of inset cubes (lighter than minkowski)
  hull() {
    cube([size[0], size[1], size[2]-2*c], center=true);
    translate([0,0,(size[2]-2*c)/2]) cube([size[0]-2*c, size[1]-2*c, 0.01], center=true);
    translate([0,0,-(size[2]-2*c)/2]) cube([size[0]-2*c, size[1]-2*c, 0.01], center=true);
  }
}

// ---------- Front bezel + flange ----------
module front_bezel() {
  rounded_box([bezel_W, bezel_H, bezel_T], r=bezel_edge_r);
}

module front_flange() {
  translate([0,0, z_bezel_back() - flange_T/2 + overlap])
    rounded_box([bezel_W + 2*flange_extra, bezel_H + 2*flange_extra, flange_T], r=bezel_edge_r);
}

// ---------- Rear body ----------
module rear_body() {
  translate([0, 0, z_body_center()])
    chamfered_box([body_W, body_H, body_D], c=0.8);
}

// ---------- Cuts (openings/recesses) ----------
module display_window_cut() {
  translate([0, y_display_center(), z_bezel_center()])
    cube([display_win_W, display_win_H, bezel_T + 6*overlap], center=true);
}

module screen_recess_cut() {
  translate([0, y_display_center(),
             z_bezel_front() - screen_recess_depth/2 + overlap/2])
    cube([display_win_W + 2*screen_recess_margin,
          display_win_H + 2*screen_recess_margin,
          screen_recess_depth + overlap], center=true);
}

module button_recess_cut() {
  translate([0, y_button_center(),
             z_bezel_front() - button_recess_depth/2 + overlap/2])
    cube([button_area_W, button_area_H, button_recess_depth + overlap], center=true);
}

// ---------- Front positive features ----------
module front_controls_positive() {
  // Encoder knob centered in button strip + two small buttons
  z_knob = z_bezel_front() + encoder_h/2 - overlap/2;
  z_btn  = z_bezel_front() + btn_h/2     - overlap/2;

  // Knob
  translate([0, y_button_center(), z_knob])
    cylinder(r=encoder_r, h=encoder_h, center=true);

  // Two buttons
  translate([-btn_spacing/2, y_button_center(), z_btn])
    cylinder(r=btn_r, h=btn_h, center=true);
  translate([ btn_spacing/2, y_button_center(), z_btn])
    cylinder(r=btn_r, h=btn_h, center=true);
}

// ---------- Side mounting clips (spring tabs) ----------
module mounting_clip(side=1) {
  // side = -1 left, +1 right
  // Clip is attached to body side and extends outward to catch panel.
  clip_len_x = clip_overhang + clip_T;
  x_center = side * (body_W/2 + clip_len_x/2 - overlap);

  // Place clips around mid-height, spanning a region behind bezel (panel area)
  z_center = z_bezel_back() - (clip_z_span/2) + overlap;

  translate([x_center, 0, z_center])
    cube([clip_len_x, clip_W, clip_z_span], center=true);
}

// ---------- Rear terminal block + screw bumps ----------
module rear_terminal_block() {
  // Attached to rear body back face with overlap.
  y_center = -(body_H/2 - connector_H/2 - overlap);
  z_center = z_body_back() - connector_D/2 + overlap;

  union() {
    translate([0, y_center, z_center])
      chamfered_box([connector_W, connector_H, connector_D], c=0.6);

    // Screw bumps on the back face of the terminal block
    // Place along X with pitch, centered.
    x0 = -((term_count-1)*term_pitch)/2;
    z_screw = (z_center - connector_D/2) - term_screw_h/2 + overlap; // protrude further back
    for (i=[0:term_count-1]) {
      translate([x0 + i*term_pitch, y_center, z_screw])
        cylinder(r=term_screw_r, h=term_screw_h, center=true);
    }
  }
}

// ---------- Rear header block + pins ----------
module rear_header_block() {
  // Place above terminal block, centered, attached to rear body back face.
  y_center = (body_H/2 - header_H/2 - overlap);
  z_center = z_body_back() - header_D/2 + overlap;

  union() {
    translate([0, y_center, z_center])
      chamfered_box([header_W, header_H, header_D], c=0.5);

    // Pin bumps on back face
    x0 = -((header_pin_count-1)*header_pin_pitch)/2;
    z_pin = (z_center - header_D/2) - header_pin_h/2 + overlap;
    for (i=[0:header_pin_count-1]) {
      translate([x0 + i*header_pin_pitch, y_center, z_pin])
        cylinder(r=header_pin_r, h=header_pin_h, center=true);
    }
  }
}

// ---------- Rear rails / ribs ----------
module rear_rails() {
  // Two ribs on rear body, left/right, attached to back face.
  x_off = (body_W/2 - rail_W/2 - overlap);
  z_center = z_body_back() - rail_D/2 + overlap;

  union() {
    translate([-x_off, 0, z_center])
      cube([rail_W, body_H - 2*overlap, rail_D], center=true);
    translate([ x_off, 0, z_center])
      cube([rail_W, body_H - 2*overlap, rail_D], center=true);
  }
}

// ---------- PCB + standoffs (connected) ----------
module pcb_and_standoffs() {
  // PCB inside body; connected via standoffs to body.
  z_pcb_center = z_bezel_back() - 2 - pcb_T/2;

  x_off = min(pcb_W/2 - boss_inset, body_W/2 - boss_inset);
  y_off = min(pcb_H/2 - boss_inset, body_H/2 - boss_inset);

  // Standoff top meets PCB with overlap; bottom embedded in body.
  z_standoff_center = z_pcb_center + pcb_T/2 - boss_h/2 + overlap;

  union() {
    translate([0, 0, z_pcb_center])
      cube([pcb_W, pcb_H, pcb_T], center=true);

    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*x_off, sy*y_off, z_standoff_center])
        cylinder(r=boss_r, h=boss_h, center=true);
    }
  }
}

// ---------- Panel cutout interface slab (kept connected) ----------
module panel_cutout_interface() {
  translate([0, 0, z_bezel_back() - panel_T/2 + overlap])
    cube([cutout_W, cutout_H, panel_T], center=true);
}

// ---------- Bezel with openings ----------
module front_bezel_with_openings() {
  difference() {
    union() {
      front_bezel();
      front_flange();
    }
    display_window_cut();
    screen_recess_cut();
    button_recess_cut();
  }
}

// ---------- Assembly ----------
module module_solid() {
  union() {
    // Front bezel + openings
    front_bezel_with_openings();

    // Rear body
    rear_body();

    // Front raised controls
    front_controls_positive();

    // Side mounting clips
    mounting_clip(-1);
    mounting_clip( 1);

    // Rear connectors
    rear_terminal_block();
    rear_header_block();

    // Rear ribs
    rear_rails();

    // Internal PCB + standoffs (connected)
    pcb_and_standoffs();

    // Panel interface slab (connected)
    panel_cutout_interface();
  }
}

// ---------- Final Output ----------
module_solid();