// RAVISTAT 1F-1 style variac (single connected solid, no text)
// Simplified for fast rendering (no minkowski, reduced $fn, fewer heavy booleans)

$fn = 48;

// -------------------- Parameters --------------------
enclosure_W = 220; //[110:440:1]
enclosure_D = 180; //[90:360:1]
enclosure_H = 160; //[80:320:1]
wall_t = 2.5; //[1.2:5:0.1]
front_panel_t = 3; //[1.5:6:0.1]
rear_panel_t = 2.5; //[1.2:5:0.1]

knob_d = 90; //[45:180:1]
knob_h = 28; //[14:56:1]

meter_W = 90; //[45:180:1]
meter_H = 70; //[35:140:1]
meter_bezel_t = 2; //[1:6:0.1]

feet_d = 18; //[9:36:1]
feet_h = 6; //[3:15:1]

vent_slot_W = 30; //[15:60:1]
vent_slot_H = 4; //[2:10:0.5]
vent_slot_pitch = 8; //[5:16:0.5]

terminal_d = 8; //[4:16:0.5]
terminal_spacing = 25; //[12:60:1]

overlap = 1; //[0.5:2:0.1]
panel_margin = 12; //[6:30:1]

screw_d = 4; //[2:8:0.5]
screw_h = 2; //[1:5:0.5]

handle_rod_d = 10; //[6:18:1]
handle_span = 140; //[70:280:1]
handle_rise = 35; //[15:70:1]

switch_W = 18; //[10:35:1]
switch_H = 12; //[6:25:1]
switch_depth = 10; //[5:25:1]

fuse_d = 14; //[8:25:1]
fuse_depth = 12; //[6:25:1]

// Variac-specific
toroid_OD = min(enclosure_W, enclosure_D) * 0.82;   // prominent
toroid_ID = toroid_OD * 0.52;
toroid_th = enclosure_H * 0.46;
toroid_front_bias = enclosure_D * 0.12;             // toward front

// Exposed winding band (raised ring around toroid)
winding_band_w = toroid_OD * 0.12;                 // radial width of band
winding_band_h = max(6, toroid_th * 0.22);          // vertical height of band

// Brush arm (typical variac feature)
brush_arm_len = toroid_OD * 0.42;
brush_arm_w   = max(10, toroid_OD * 0.06);
brush_arm_h   = max(8,  toroid_th * 0.18);
brush_pivot_d = max(14, toroid_OD * 0.08);
brush_pivot_h = max(10, brush_arm_h * 0.9);

// Top dial + knob (large, centered)
top_dial_d = knob_d * 1.05;
top_dial_h = max(7, knob_h * 0.35);
top_knob_d = knob_d * 0.45;
top_knob_h = max(14, knob_h * 0.65);

// Side cord strain relief
side_cord_d = 10;
side_cord_len = 55;

// Rear terminals (3 posts typical)
rear_term_count = 3;
rear_term_spacing = terminal_spacing;
rear_term_len = rear_panel_t + terminal_d*1.2;

// -------------------- Core solids --------------------
module enclosure_outer() {
  cube([enclosure_W, enclosure_D, enclosure_H], center=true);
}

module enclosure_inner() {
  translate([0, 0, wall_t])
    cube([enclosure_W - 2*wall_t, enclosure_D - 2*wall_t, enclosure_H - 2*wall_t], center=true);
}

module enclosure_shell() {
  difference() {
    enclosure_outer();
    enclosure_inner();
  }
}

module front_panel_plate() {
  translate([0,
             -enclosure_D/2 + wall_t + front_panel_t/2 - overlap,
             wall_t])
    cube([enclosure_W - 2*wall_t, front_panel_t, enclosure_H - 2*wall_t], center=true);
}

module rear_panel_plate() {
  translate([0,
             enclosure_D/2 - wall_t - rear_panel_t/2 + overlap,
             wall_t])
    cube([enclosure_W - 2*wall_t, rear_panel_t, enclosure_H - 2*wall_t], center=true);
}

// -------------------- Variac toroid + winding band --------------------
module toroid_body() {
  tor_z = -enclosure_H/2 + wall_t + toroid_th/2; // sits on bottom inside
  tor_y = -toroid_front_bias;

  translate([0, tor_y, tor_z])
    difference() {
      cylinder(h=toroid_th, r=toroid_OD/2, center=true);
      cylinder(h=toroid_th + 2*overlap, r=toroid_ID/2, center=true);
    }
}

// Raised winding band around the outer circumference (exposed winding look)
module toroid_winding_band() {
  tor_z = -enclosure_H/2 + wall_t + toroid_th/2;
  tor_y = -toroid_front_bias;

  band_r_outer = toroid_OD/2 + winding_band_w/2; // slightly proud
  band_r_inner = toroid_OD/2 - winding_band_w/2;

  translate([0, tor_y, tor_z])
    difference() {
      cylinder(h=winding_band_h, r=band_r_outer, center=true);
      cylinder(h=winding_band_h + 2*overlap, r=band_r_inner, center=true);
    }
}

// Brush pivot boss + arm that reaches the winding band (connected to toroid)
module brush_assembly() {
  tor_z = -enclosure_H/2 + wall_t + toroid_th/2;
  tor_y = -toroid_front_bias;

  pivot_z = tor_z + toroid_th/2 - brush_pivot_h/2;
  pivot_x = toroid_OD*0.18;
  pivot_y = tor_y;

  arm_z = pivot_z;
  arm_x = pivot_x + brush_arm_len/2 - overlap;
  arm_y = pivot_y;

  union() {
    translate([pivot_x, pivot_y, pivot_z - overlap/2])
      cylinder(h=brush_pivot_h + overlap, r=brush_pivot_d/2, center=true);

    translate([arm_x, arm_y, arm_z])
      cube([brush_arm_len, brush_arm_w, brush_arm_h], center=true);

    brush_block_len = brush_arm_w*1.2;
    brush_block_w   = brush_arm_w*1.1;
    brush_block_h   = brush_arm_h*1.1;

    end_x = pivot_x + brush_arm_len - brush_block_len/2;
    translate([end_x, arm_y, arm_z])
      cube([brush_block_len, brush_block_w, brush_block_h], center=true);
  }
}

// -------------------- Top dial + knob (prominent) --------------------
module top_dial_plate() {
  dial_z = enclosure_H/2 + top_dial_h/2 - overlap;
  translate([0, 0, dial_z])
    cylinder(h=top_dial_h, r=top_dial_d/2, center=true);
}

module top_knob() {
  knob_z = enclosure_H/2 + top_dial_h - overlap + top_knob_h/2;
  translate([0, 0, knob_z])
    cylinder(h=top_knob_h, r=top_knob_d/2, center=true);
}

// Simplified dial rim (no difference boolean)
module top_dial_rim() {
  rim_h = max(4, top_dial_h*0.55);
  rim_t = max(3, top_dial_d*0.06);
  rim_z = enclosure_H/2 + top_dial_h - rim_h/2 - overlap;

  translate([0, 0, rim_z])
    cylinder(h=rim_h, r=top_dial_d/2 + rim_t, center=true);
}

// -------------------- Front panel features --------------------
module front_knob_main() {
  x = -enclosure_W/2 + wall_t + panel_margin + knob_d/2;
  y = -enclosure_D/2 - knob_h/2 + overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.48;

  translate([x, y, z])
    rotate([90, 0, 0])
      cylinder(r=knob_d/2, h=knob_h, center=true);
}

module front_knob_pointer() {
  x = -enclosure_W/2 + wall_t + panel_margin + knob_d/2 + knob_d*0.22 - overlap;
  y = -enclosure_D/2 - knob_h/2 + overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.48 + knob_d*0.10;

  translate([x, y, z])
    cube([knob_d*0.42, knob_h*0.22, knob_d*0.12], center=true);
}

module meter_bezel_block() {
  x = enclosure_W/2 - wall_t - panel_margin - meter_W/2;
  y = -enclosure_D/2 + wall_t + front_panel_t + meter_bezel_t/2 - overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.72;

  translate([x, y, z])
    cube([meter_W + 2*meter_bezel_t, meter_bezel_t, meter_H + 2*meter_bezel_t], center=true);
}

// Simplified: raised "window" block instead of cutout
module meter_window_relief() {
  x = enclosure_W/2 - wall_t - panel_margin - meter_W/2;
  y = -enclosure_D/2 + wall_t + front_panel_t/2 - overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.72;

  translate([x, y, z])
    cube([meter_W*0.92, front_panel_t*0.7, meter_H*0.92], center=true);
}

module terminal_posts_front() {
  x0 = enclosure_W/2 - wall_t - panel_margin;
  y = -enclosure_D/2 - (front_panel_t + terminal_d*0.9)/2 + overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.22;

  for (sx = [-terminal_spacing/2, terminal_spacing/2]) {
    translate([x0 + sx, y, z])
      rotate([90, 0, 0])
        cylinder(r=terminal_d/2, h=front_panel_t + terminal_d*0.9, center=true);
  }
}

module power_switch_body() {
  x = -enclosure_W/2 + wall_t + panel_margin + switch_W/2;
  y = -enclosure_D/2 - switch_depth/2 + overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.22;

  translate([x, y, z])
    cube([switch_W, switch_depth, switch_H], center=true);
}

module fuse_holder_cap() {
  x = -enclosure_W/2 + wall_t + panel_margin + fuse_d/2;
  y = -enclosure_D/2 - fuse_depth/2 + overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.34;

  translate([x, y, z])
    rotate([90, 0, 0])
      cylinder(r=fuse_d/2, h=fuse_depth, center=true);
}

module screws_front() {
  y = -enclosure_D/2 - screw_h/2 + overlap;
  z_top = wall_t + (enclosure_H - 2*wall_t) - panel_margin;
  z_bot = wall_t + panel_margin;
  xL = -(enclosure_W - 2*wall_t)/2 + panel_margin;
  xR =  (enclosure_W - 2*wall_t)/2 - panel_margin;

  for (x = [xL, xR], z = [z_top, z_bot]) {
    translate([x, y, z])
      rotate([90, 0, 0])
        cylinder(r=screw_d/2, h=screw_h, center=true);
  }
}

// -------------------- Rear terminals + vents --------------------
module rear_terminal_posts() {
  y = enclosure_D/2 + rear_term_len/2 - overlap;
  z = wall_t + (enclosure_H - 2*wall_t)*0.62;
  x_center = enclosure_W/2 - wall_t - panel_margin - rear_term_spacing;

  for (i = [0:rear_term_count-1]) {
    x = x_center + (i - (rear_term_count-1)/2) * rear_term_spacing;
    translate([x, y, z])
      rotate([90, 0, 0])
        cylinder(r=terminal_d/2, h=rear_term_len, center=true);
  }
}

module rear_vent_ribs() {
  rib_t = wall_t;
  rib_w = vent_slot_W * 1.6;
  rib_h = vent_slot_H;

  y = enclosure_D/2 + rib_t/2 - overlap;
  z0 = wall_t + (enclosure_H - 2*wall_t)*0.30;

  for (i = [-2, -1, 0, 1, 2]) {
    translate([0, y, z0 + i*vent_slot_pitch])
      cube([rib_w, rib_t, rib_h], center=true);
  }
}

// -------------------- Side cord relief --------------------
module side_cord_relief() {
  x = enclosure_W/2 + side_cord_len/2 - overlap;
  y = enclosure_D*0.12;
  z = -enclosure_H*0.08;

  translate([x, y, z])
    rotate([0, 90, 0])
      cylinder(r=side_cord_d/2, h=side_cord_len, center=true);
}

// -------------------- Feet --------------------
module feet() {
  z = -enclosure_H/2 - feet_h/2 + overlap;
  xL = -enclosure_W/2 + feet_d/2 + wall_t;
  xR =  enclosure_W/2 - feet_d/2 - wall_t;
  yF = -enclosure_D/2 + feet_d/2 + wall_t;
  yR =  enclosure_D/2 - feet_d/2 - wall_t;

  for (x = [xL, xR], y = [yF, yR])
    translate([x, y, z])
      cylinder(r=feet_d/2, h=feet_h, center=true);
}

// -------------------- Carry handle --------------------
module carry_handle() {
  mount_w = handle_rod_d*1.8;
  mount_d = handle_rod_d*1.3;
  mount_h = handle_rod_d*1.6;

  mount_z = enclosure_H/2 - wall_t + mount_h/2 - overlap;

  post_h = handle_rise + handle_rod_d;
  post_z = enclosure_H/2 + post_h/2 - overlap;

  span = min(handle_span, enclosure_W - 2*(wall_t + mount_w/2 + panel_margin));
  span = max(span, mount_w*2 + 10);

  translate([-span/2, 0, mount_z]) cube([mount_w, mount_d, mount_h], center=true);
  translate([ span/2, 0, mount_z]) cube([mount_w, mount_d, mount_h], center=true);

  translate([-span/2, 0, post_z]) cylinder(r=handle_rod_d/2, h=post_h, center=true);
  translate([ span/2, 0, post_z]) cylinder(r=handle_rod_d/2, h=post_h, center=true);

  bar_z = enclosure_H/2 + handle_rise + handle_rod_d/2 - overlap;
  translate([0, 0, bar_z])
    rotate([0, 90, 0])
      cylinder(r=handle_rod_d/2, h=span + mount_w - 2*overlap, center=true);
}

// -------------------- Assembly --------------------
module complete_model() {
  union() {
    // Main enclosure + panels (connected)
    enclosure_shell();
    front_panel_plate();
    rear_panel_plate();

    // Variac internals (still a single connected solid via overlap into shell)
    toroid_body();
    toroid_winding_band();
    brush_assembly();

    // Top dial/knob
    top_dial_plate();
    top_dial_rim();
    top_knob();

    // Front features
    front_knob_main();
    front_knob_pointer();
    meter_bezel_block();
    meter_window_relief();
    terminal_posts_front();
    power_switch_body();
    fuse_holder_cap();
    screws_front();

    // Rear features
    rear_terminal_posts();
    rear_vent_ribs();

    // Side + bottom features
    side_cord_relief();
    feet();

    // Handle
    carry_handle();
  }
}

complete_model();