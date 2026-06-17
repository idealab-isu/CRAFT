// Parameters
body_W = 12.7; //[6.35:25.4:0.1]
body_H = 19.0; //[9.5:38.0:0.1]
body_D = 8.2; //[4.1:16.4:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
bezel_thk = 1.2; //[0.6:2.4:0.1]
bezel_margin = 1.0; //[0.5:2.0:0.1]
window_thk = 0.8; //[0.4:1.6:0.1]
seg_win_W = 8.0; //[4.0:10.0:0.1]
seg_win_H = 1.6; //[0.8:3.2:0.1]
seg_gap = 1.2; //[0.6:2.4:0.1]
dp_radius = 1.0; //[0.5:2.0:0.1]
rear_cavity_wall = 1.2; //[0.6:2.4:0.1]
rear_cavity_depth = 4.5; //[2.0:7.0:0.1]
pin_radius = 0.6; //[0.3:1.2:0.1]
pin_length = 3.0; //[1.5:6.0:0.1]
pin_inset_X = 2.0; //[1.0:4.0:0.1]
pin_inset_Y = 2.5; //[1.0:5.0:0.1]

// Main Body
module main_body() {
  color("DimGray")
  cube([body_W, body_H, body_D], center=true);
}

// Front Bezel
module front_bezel() {
  difference() {
    color("Black")
    translate([0, 0, body_D/2 - bezel_thk/2 + overlap/2])
      cube([body_W, body_H, bezel_thk], center=true);
    translate([0, 0, body_D/2 - bezel_thk/2 + overlap/2])
      cube([body_W - 2*bezel_margin, body_H - 2*bezel_margin, bezel_thk + 2*overlap], center=true);
  }
}

// Segment Windows
module segment_led_windows() {
  color("White")
  union() {
    translate([0, body_H/2 - bezel_margin - seg_win_H/2 - seg_gap, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_W, seg_win_H, window_thk + 2*overlap], center=true);
    translate([0, 0, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_W, seg_win_H, window_thk + 2*overlap], center=true);
    translate([0, -(body_H/2 - bezel_margin - seg_win_H/2 - seg_gap), body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_W, seg_win_H, window_thk + 2*overlap], center=true);
    translate([-(seg_win_W/2 - seg_win_H/2), body_H/4, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_H, body_H/2 - 2*bezel_margin - 2*seg_gap, window_thk + 2*overlap], center=true);
    translate([-(seg_win_W/2 - seg_win_H/2), -body_H/4, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_H, body_H/2 - 2*bezel_margin - 2*seg_gap, window_thk + 2*overlap], center=true);
    translate([seg_win_W/2 - seg_win_H/2, body_H/4, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_H, body_H/2 - 2*bezel_margin - 2*seg_gap, window_thk + 2*overlap], center=true);
    translate([seg_win_W/2 - seg_win_H/2, -body_H/4, body_D/2 - window_thk/2 + overlap/2])
      cube([seg_win_H, body_H/2 - 2*bezel_margin - 2*seg_gap, window_thk + 2*overlap], center=true);
  }
}

// Decimal Point
module decimal_point() {
  color("White")
  translate([body_W/2 - bezel_margin - dp_radius - seg_gap, -(body_H/2 - bezel_margin - dp_radius - seg_gap), body_D/2 - window_thk/2 + overlap/2])
    rotate([90, 0, 0])
    cylinder(r=dp_radius, h=window_thk + 2*overlap, center=true);
}

// Rear Cavity
module rear_cavity() {
  translate([0, 0, -(body_D/2 - rear_cavity_depth/2) - overlap/2])
    cube([body_W - 2*rear_cavity_wall, body_H - 2*rear_cavity_wall, rear_cavity_depth + 2*overlap], center=true);
}

// Mounting Pins
module mounting_pin(x, y) {
  translate([x, y, -(body_D/2 + pin_length/2 - overlap)])
    cylinder(r=pin_radius, h=pin_length, center=true);
}

module mounting_pins() {
  color("Silver")
  mounting_pin(-(body_W/2 - pin_inset_X), -(body_H/2 - pin_inset_Y));
  mounting_pin(body_W/2 - pin_inset_X, -(body_H/2 - pin_inset_Y));
  mounting_pin(-(body_W/2 - pin_inset_X), body_H/2 - pin_inset_Y);
  mounting_pin(body_W/2 - pin_inset_X, body_H/2 - pin_inset_Y);
}

// Segment Cutouts
module segment_cutouts() {
  translate([0, 0, body_D/2 - (body_D/2)/2])
    cube([seg_win_W + 2*seg_gap, body_H - 2*bezel_margin, body_D/2], center=true);
}

// Final Assembly
difference() {
  union() {
    main_body();
    front_bezel();
    mounting_pins();
  }
  rear_cavity();
  segment_led_windows();
  decimal_point();
  segment_cutouts();
}