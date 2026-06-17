// Peacefair PZEM-001 style AC panel meter (approximate)
// One connected solid, no text. All placements derived from dimensions.

$fn = 64;

// ---------- Parameters ----------
bezel_W = 80; //[40:160:1]
bezel_H = 43; //[22:86:1]
bezel_T = 3;  //[2:6:1]

housing_W = 76; //[38:152:1]
housing_H = 39; //[20:78:1]
housing_D = 72; //[36:144:1]

panel_cutout_W = 76; //[38:152:1]
panel_cutout_H = 39; //[20:78:1]

window_W = 60; //[30:120:1]
window_H = 26; //[13:52:1]
window_offset_Z = 2; //[-10:10:1]  // vertical offset on face (Z)

face_recess_depth = 1.2; //[0.6:2.4:0.1]
recess_margin = 3; //[1:8:1]

clip_count_per_side = 1; //[1:3:1]
clip_W = 12; //[5:20:1]
clip_H = 7;  //[3:12:1]
clip_T = 2.2;  //[1:4:0.1]
clip_offset_from_front = 18; //[8:36:1]

terminal_block_W = 44; //[20:80:1]
terminal_block_H = 18; //[9:36:1]
terminal_block_D = 16; //[8:32:1]
terminal_block_offset_from_back = 0; //[0:10:1]

vent_slot_W = 3; //[1:6:0.5]
vent_slot_H = 10; //[5:20:1]
vent_slot_T = 2; //[1:4:0.5]
vent_slot_count = 5; //[3:9:1]

lcd_plate_T = 0.9; //[0.4:2:0.1]
lcd_plate_margin = 2; //[1:5:0.5]
lcd_segment_T = 0.6; //[0.3:1.5:0.1]
lcd_segment_W = 6; //[3:12:0.5]
lcd_segment_H = 12; //[6:24:1]

screw_head_r = 2.5; //[1.5:5:0.5]
screw_head_h = 1.5; //[0.8:3:0.1]

overlap = 1; //[0.5:2:0.5]

// Extra PZEM-001 recognizable features (no text)
bezel_corner_r = 2.2;
bezel_lip = 2.0;          // bezel overhang around housing
bezel_step = 1.2;         // bezel "frame" thickness around recessed face
bezel_step_r = 1.6;

window_corner_r = 1.2;

button_W = 10;
button_H = 6;
button_depth = 0.9;
button_gap = 3;

led_r = 1.2;
led_depth = 0.8;

mount_ear_W = 6.5;        // small front bezel ears (top/bottom corners)
mount_ear_H = 4.0;
mount_ear_T = 1.6;

term_rib_W = 6;           // small ribs on terminal block top
term_rib_H = 2.2;
term_rib_D = 2.0;
term_rib_count = 4;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// ---------- Derived ----------
bezel_inner_W = housing_W + 2*bezel_lip;
bezel_inner_H = housing_H + 2*bezel_lip;

buttons_total_W = 3*button_W + 2*button_gap;
buttons_z_offset = -(window_H/2 + button_H/2 + 3); // below window (negative Z)
buttons_z_offset_clamped =
    clamp(buttons_z_offset,
          -(bezel_H/2 - recess_margin - button_H/2),
           (bezel_H/2 - recess_margin - button_H/2));

// Coordinate convention:
// X = left/right, Y = front/back (front positive), Z = up/down
bezel_yc = 0;
housing_yc = -(bezel_T/2 + housing_D/2 - overlap);
housing_zc = 0;

panel_if_T = bezel_T + overlap;
panel_if_yc = -(bezel_T/2 + panel_if_T/2 - overlap);

// Clips: on left/right sides, slightly behind bezel
clip_yc = -(bezel_T/2 + clip_offset_from_front);
clip_x_left  = -(housing_W/2 + clip_W/2 - overlap);
clip_x_right =  (housing_W/2 + clip_W/2 - overlap);

// Terminal block: attached to rear-bottom of housing
term_yc = housing_yc - housing_D/2 + terminal_block_D/2 + terminal_block_offset_from_back + overlap;
term_zc = housing_zc - housing_H/2 + terminal_block_H/2 + overlap;

// LCD plate: inside front recess (slightly behind front face)
lcd_yc = (bezel_T/2 - face_recess_depth) - lcd_plate_T/2 + overlap;

// LCD segments: slightly behind plate
seg_yc = (bezel_T/2 - face_recess_depth) - lcd_plate_T - lcd_segment_T/2 + overlap;

// Screw heads: on terminal block rear face, near top corners
screw_yc = term_yc - terminal_block_D/2 + screw_head_h/2 - overlap; // rear-most face (more negative Y)
screw_zc = term_zc + terminal_block_H/2 - screw_head_r - overlap;
screw_x_left  = -terminal_block_W/2 + screw_head_r + overlap;
screw_x_right =  terminal_block_W/2 - screw_head_r - overlap;

// Bezel ears: at top/bottom corners, protruding slightly
ear_yc = bezel_yc + bezel_T/2 - mount_ear_T/2 + overlap;
ear_x = bezel_W/2 - mount_ear_W/2;
ear_z = bezel_H/2 - mount_ear_H/2;

// LED indicators: small recessed circles above window
led_z = window_offset_Z + window_H/2 + 4;
led_z_clamped = clamp(led_z, -bezel_H/2 + recess_margin + led_r, bezel_H/2 - recess_margin - led_r);
led_x_span = window_W*0.35;
led_yc = bezel_yc + bezel_T/2 - (led_depth/2) - overlap;

// ---------- Primitives ----------
module rrect_xy(size=[10,10,2], r=1, center=true) {
  w = size[0]; d = size[1]; h = size[2];
  translate(center ? [0,0,-h/2] : [0,0,0])
    linear_extrude(height=h)
      offset(r=r)
        square([max(0.01,w-2*r), max(0.01,d-2*r)], center=true);
}

module rrect_xz(size=[10,2,10], r=1, center=true) {
  // Rounded rectangle in XZ, extruded along Y (thickness is size[1])
  w = size[0]; t = size[1]; h = size[2];
  translate(center ? [0,-t/2,0] : [0,0,0])
    rotate([90,0,0])
      linear_extrude(height=t)
        offset(r=r)
          square([max(0.01,w-2*r), max(0.01,h-2*r)], center=true);
}

module front_bezel_outer() {
  rrect_xz([bezel_W, bezel_T, bezel_H], r=bezel_corner_r, center=true);
}

module front_bezel_step_cut() {
  // Creates a "frame" step: remove a larger shallow area, leaving a raised rim
  rrect_xz([bezel_W - 2*bezel_step, face_recess_depth + 2*overlap, bezel_H - 2*bezel_step],
           r=max(0.8, bezel_step_r), center=true);
}

module front_face_recess_cut() {
  // Inner recess area (slightly smaller than step cut) for LCD/button region
  rrect_xz([bezel_W - 2*recess_margin, face_recess_depth + 2*overlap, bezel_H - 2*recess_margin],
           r=max(0.8, bezel_corner_r-0.8), center=true);
}

module display_window_opening_cut() {
  rrect_xz([window_W, bezel_T + 4*overlap, window_H], r=window_corner_r, center=true);
}

module button_recess_cut(xc) {
  translate([xc, 0, window_offset_Z + buttons_z_offset_clamped])
    rrect_xz([button_W, button_depth + 2*overlap, button_H], r=0.8, center=true);
}

module led_recess_cut(xc) {
  translate([xc, led_yc, led_z_clamped])
    rotate([90,0,0])
      cylinder(r=led_r, h=led_depth + 2*overlap, center=true);
}

module rear_housing_block() {
  rrect_xy([housing_W, housing_D, housing_H], r=1.2, center=true);
}

module panel_cutout_interface_block() {
  rrect_xy([panel_cutout_W, panel_if_T, panel_cutout_H], r=0.8, center=true);
}

module clip_block() {
  rrect_xy([clip_W, clip_T, clip_H], r=0.6, center=true);
}

module rear_terminal_block_envelope() {
  rrect_xy([terminal_block_W, terminal_block_D, terminal_block_H], r=1.0, center=true);
}

module terminal_rib() {
  rrect_xy([term_rib_W, term_rib_D, term_rib_H], r=0.6, center=true);
}

module lcd_plate() {
  rrect_xz([window_W + 2*lcd_plate_margin, lcd_plate_T, window_H + 2*lcd_plate_margin], r=1.0, center=true);
}

module lcd_segment() {
  rrect_xz([lcd_segment_W, lcd_segment_T, lcd_segment_H], r=0.6, center=true);
}

module screw_head() {
  cylinder(r=screw_head_r, h=screw_head_h, center=true);
}

module bezel_ear() {
  rrect_xz([mount_ear_W, mount_ear_T, mount_ear_H], r=0.8, center=true);
}

module rear_vent_slot_cut(i) {
  x_pos = -(housing_W/2) + (housing_W/(vent_slot_count+1))*i;
  // rear face of housing (more negative Y), near top (positive Z)
  translate([x_pos,
             housing_yc - housing_D/2 + (vent_slot_T/2),
             housing_zc + housing_H/2 - vent_slot_H/2 - overlap])
    cube([vent_slot_W, vent_slot_T + 2*overlap, vent_slot_H], center=true);
}

// ---------- Operations ----------
module front_bezel_with_details() {
  difference() {
    union() {
      front_bezel_outer();

      // Small bezel ears (top-left, top-right, bottom-left, bottom-right)
      translate([ ear_x, ear_yc,  ear_z]) bezel_ear();
      translate([-ear_x, ear_yc,  ear_z]) bezel_ear();
      translate([ ear_x, ear_yc, -ear_z]) bezel_ear();
      translate([-ear_x, ear_yc, -ear_z]) bezel_ear();
    }

    // Step cut (frame)
    translate([0, bezel_yc + bezel_T/2 - (face_recess_depth + 2*overlap)/2, 0])
      front_bezel_step_cut();

    // Inner recess (LCD/button region)
    translate([0, bezel_yc + bezel_T/2 - (face_recess_depth + 2*overlap)/2, 0])
      front_face_recess_cut();

    // Window opening
    translate([0, bezel_yc, window_offset_Z])
      display_window_opening_cut();

    // Button recesses (3)
    button_recess_cut(-(buttons_total_W/2) + button_W/2);
    button_recess_cut(0);
    button_recess_cut((buttons_total_W/2) - button_W/2);

    // LED recesses (2)
    led_recess_cut(-led_x_span/2);
    led_recess_cut( led_x_span/2);
  }
}

module rear_housing_with_vents() {
  difference() {
    translate([0, housing_yc, housing_zc])
      rear_housing_block();

    for (i = [1:vent_slot_count])
      rear_vent_slot_cut(i);
  }
}

module terminal_block_with_ribs() {
  union() {
    translate([0, term_yc, term_zc])
      rear_terminal_block_envelope();

    // Ribs on top of terminal block (connected)
    rib_yc = term_yc + (terminal_block_D/2 - term_rib_D/2) - overlap;
    rib_zc = term_zc + (terminal_block_H/2 + term_rib_H/2) - overlap;
    for (k = [1:term_rib_count]) {
      xk = -(terminal_block_W/2) + (terminal_block_W/(term_rib_count+1))*k;
      translate([xk, rib_yc, rib_zc])
        terminal_rib();
    }
  }
}

module meter_body_union() {
  union() {
    // Front bezel
    translate([0, bezel_yc, 0])
      front_bezel_with_details();

    // Rear housing (connected with overlap)
    rear_housing_with_vents();

    // Panel cutout interface (neck)
    translate([0, panel_if_yc, 0])
      panel_cutout_interface_block();

    // Side clips (connected to housing)
    translate([clip_x_left, clip_yc, 0])
      clip_block();
    translate([clip_x_right, clip_yc, 0])
      clip_block();

    // Rear terminal block + ribs (connected to housing)
    terminal_block_with_ribs();

    // LCD plate (solid detail inside recess)
    translate([0, lcd_yc, window_offset_Z])
      lcd_plate();

    // LCD segments (solid detail)
    translate([-(window_W/2) + lcd_plate_margin + lcd_segment_W/2, seg_yc, window_offset_Z])
      lcd_segment();
    translate([0, seg_yc, window_offset_Z])
      lcd_segment();
    translate([(window_W/2) - lcd_plate_margin - lcd_segment_W/2, seg_yc, window_offset_Z])
      lcd_segment();

    // Terminal screws (solid bumps) on rear face of terminal block
    translate([screw_x_left, screw_yc, screw_zc])
      rotate([90, 0, 0]) screw_head();
    translate([screw_x_right, screw_yc, screw_zc])
      rotate([90, 0, 0]) screw_head();
  }
}

// ---------- Final Output ----------
meter_body_union();