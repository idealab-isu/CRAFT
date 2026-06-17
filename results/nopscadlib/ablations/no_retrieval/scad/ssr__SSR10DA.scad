// Parameters
body_L = 58.0; //[29.0:116.0:0.5]
body_W = 45.0; //[22.5:90.0:0.5]
body_H = 33.0; //[16.5:66.0:0.5]
hole_d = 4.0; //[2.0:8.0:0.25]
hole_edge_offset_L = 6.0; //[3.0:12.0:0.5]
hole_edge_offset_W = 6.0; //[3.0:12.0:0.5]
terminal_L = 58.0; //[29.0:116.0:0.5]
terminal_W = 14.0; //[7.0:28.0:0.5]
terminal_H = 10.0; //[5.0:20.0:0.5]
flange_thk = 3.0; //[1.5:6.0:0.25]
flange_overhang_L = 4.0; //[2.0:8.0:0.5]
flange_overhang_W = 3.0; //[1.5:6.0:0.5]
label_recess_depth = 0.8; //[0.4:2.0:0.1]
label_margin_L = 6.0; //[3.0:12.0:0.5]
label_margin_W = 6.0; //[3.0:12.0:0.5]
led_win_L = 8.0; //[4.0:16.0:0.5]
led_win_W = 3.0; //[1.5:8.0:0.25]
led_win_depth = 1.2; //[0.6:3.0:0.1]
screw_boss_d = 6.0; //[3.0:12.0:0.25]
screw_boss_h = 4.0; //[2.0:10.0:0.25]
screw_hole_d = 3.0; //[1.5:6.0:0.25]
screw_count = 4.0; //[2.0:6.0:1.0]
edge_chamfer = 1.0; //[0.5:3.0:0.25]
connect_overlap = 1.0; //[0.5:2.0:0.25]

// Main Body with Chamfer
module main_body_chamfered() {
  minkowski() {
    translate([0, 0, 0])
      cube([body_L, body_W, body_H], center=true);
    sphere(r=edge_chamfer, center=true);
  }
}

// Base Flange
module base_flange() {
  translate([0, 0, -body_H/2 + flange_thk/2 - connect_overlap])
    cube([body_L + 2*flange_overhang_L, body_W + 2*flange_overhang_W, flange_thk], center=true);
}

// Terminal Block
module terminal_block_top() {
  translate([0, body_W/2 - terminal_W/2 + connect_overlap, body_H/2 + terminal_H/2 - connect_overlap])
    cube([terminal_L, terminal_W, terminal_H], center=true);
}

// Screw Boss
module screw_boss(x_offset) {
  translate([x_offset, body_W/2 - terminal_W/2 + connect_overlap, body_H/2 + terminal_H - connect_overlap + screw_boss_h/2])
    cylinder(r=screw_boss_d/2, h=screw_boss_h, center=true);
}

// Screw Hole
module screw_hole(x_offset) {
  translate([x_offset, body_W/2 - terminal_W/2 + connect_overlap, body_H/2 + terminal_H - connect_overlap + screw_boss_h/2])
    cylinder(r=screw_hole_d/2, h=screw_boss_h + terminal_H + 2*connect_overlap, center=true);
}

// Mounting Hole
module mount_hole(x_offset, y_offset) {
  translate([x_offset, y_offset, 0])
    cylinder(r=hole_d/2, h=flange_thk + body_H + 2*terminal_H, center=true);
}

// Label Recess
module label_recess_cut() {
  translate([0, 0, body_H/2 - label_recess_depth/2 + connect_overlap])
    cube([body_L - 2*label_margin_L, body_W - 2*label_margin_W, label_recess_depth], center=true);
}

// LED Window
module indicator_led_window_cut() {
  translate([body_L/2 - label_margin_L - led_win_L/2, 0, body_H/2 - led_win_depth/2 + connect_overlap])
    cube([led_win_L, led_win_W, led_win_depth], center=true);
}

// SSR Complete Model
module ssr_complete_model() {
  difference() {
    union() {
      main_body_chamfered();
      base_flange();
      terminal_block_top();
      screw_boss(-terminal_L/2 + terminal_L/5);
      screw_boss(-terminal_L/2 + 2*terminal_L/5);
      screw_boss(-terminal_L/2 + 3*terminal_L/5);
      screw_boss(-terminal_L/2 + 4*terminal_L/5);
    }
    union() {
      label_recess_cut();
      indicator_led_window_cut();
      mount_hole((-body_L/2 - flange_overhang_L) + hole_edge_offset_L, (-body_W/2 - flange_overhang_W) + hole_edge_offset_W);
      mount_hole((body_L/2 + flange_overhang_L) - hole_edge_offset_L, (-body_W/2 - flange_overhang_W) + hole_edge_offset_W);
      mount_hole((-body_L/2 - flange_overhang_L) + hole_edge_offset_L, (body_W/2 + flange_overhang_W) - hole_edge_offset_W);
      mount_hole((body_L/2 + flange_overhang_L) - hole_edge_offset_L, (body_W/2 + flange_overhang_W) - hole_edge_offset_W);
      screw_hole(-terminal_L/2 + terminal_L/5);
      screw_hole(-terminal_L/2 + 2*terminal_L/5);
      screw_hole(-terminal_L/2 + 3*terminal_L/5);
      screw_hole(-terminal_L/2 + 4*terminal_L/5);
    }
  }
}

// Render the SSR Model
color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
ssr_complete_model();