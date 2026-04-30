// Parametric seven-segment LED display module (render-safe, simplified)

// =====================
// Parameters (mm)
// =====================
primary_dimension = 12.7; //[6.35:25.4:0.1]
body_width = 12.7; //[6.35:25.4:0.1]
body_height = 19.0; //[9.5:38.0:0.1]
body_thickness = 8.2; //[4.1:16.4:0.1]

digit_width = 7.2; //[3.6:14.4:0.1]
digit_height = 12.7; //[6.35:25.4:0.1]
segment_width = 1.2; //[0.6:2.4:0.05]
segment_gap = 0.3; //[0.15:0.6:0.05]
segment_depth = 0.6; //[0.3:1.2:0.05]

front_bezel_radius = 0.5; //[0.0:1.0:0.05]
front_recess_depth = 0.5; //[0.25:1.0:0.05]

pin_rows = 2; //[2:2:1]
pin_cols = 5; //[5:5:1]
pin_pitch_x = 2.54; //[1.27:5.08:0.01]
pin_pitch_y = 2.54; //[1.27:5.08:0.01]
pin_diameter = 0.5; //[0.25:1.0:0.01]
pin_length = 3.0; //[1.5:6.0:0.1]
pin_standoff_from_body = 0.0; //[0.0:2.0:0.1]
pin_array_centered = 1; //[0:1:1]

digit_center_offset_x = 0.0; //[-3.0:3.0:0.1]
digit_center_offset_y = 0.0; //[-3.0:3.0:0.1]

overlap = 0.6; //[0.2:2.0:0.1]

// Render quality (kept modest for speed)
$fn = 20;

// =====================
// Helpers (fast)
// =====================
module rounded_box_xy(size=[10,10,5], r=0.5, center=true) {
  // Fast rounded rectangle prism using linear_extrude of 2D offset square
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = max(0, min(r, min(sx,sy)/2));

  translate(center ? [0,0,-sz/2] : [sx/2, sy/2, 0])
    linear_extrude(height=sz, convexity=4)
      offset(r=rr)
        square([max(0.01,sx-2*rr), max(0.01,sy-2*rr)], center=true);
}

function clamp(x, a, b) = min(max(x,a),b);

module seg_hole_h(pos=[0,0,0]) {
  translate(pos)
    cube([
      max(0.1, digit_width - 2*(segment_gap + segment_width/2)),
      max(0.1, segment_width),
      segment_depth + overlap
    ], center=true);
}

module seg_hole_v(pos=[0,0,0]) {
  vlen = max(0.1, (digit_height - 3*segment_width - 4*segment_gap)/2);
  translate(pos)
    cube([
      max(0.1, segment_width),
      max(0.1, vlen),
      segment_depth + overlap
    ], center=true);
}

module seven_segment_apertures() {
  zpos = body_thickness/2 - segment_depth/2;

  // a (top)
  seg_hole_h([
    digit_center_offset_x,
    digit_center_offset_y + digit_height/2 - segment_gap - segment_width/2,
    zpos
  ]);

  // d (bottom)
  seg_hole_h([
    digit_center_offset_x,
    digit_center_offset_y - digit_height/2 + segment_gap + segment_width/2,
    zpos
  ]);

  // g (middle)
  seg_hole_h([
    digit_center_offset_x,
    digit_center_offset_y,
    zpos
  ]);

  vlen = max(0.1, (digit_height - 3*segment_width - 4*segment_gap)/2);
  y_top_center = digit_center_offset_y + (digit_height/2 - segment_gap - segment_width) - (vlen/2);
  y_bot_center = digit_center_offset_y - (digit_height/2 - segment_gap - segment_width) + (vlen/2);

  x_left  = digit_center_offset_x - digit_width/2 + segment_gap + segment_width/2;
  x_right = digit_center_offset_x + digit_width/2 - segment_gap - segment_width/2;

  // f (upper-left), b (upper-right), e (lower-left), c (lower-right)
  seg_hole_v([x_left,  y_top_center, zpos]);
  seg_hole_v([x_right, y_top_center, zpos]);
  seg_hole_v([x_left,  y_bot_center, zpos]);
  seg_hole_v([x_right, y_bot_center, zpos]);
}

module digit_recess_cut() {
  translate([
    digit_center_offset_x,
    digit_center_offset_y,
    body_thickness/2 - front_recess_depth/2
  ])
    cube([digit_width, digit_height, front_recess_depth + overlap], center=true);
}

// =====================
// Components
// =====================
module display() {
  color([0.08, 0.08, 0.09])
  difference() {
    rounded_box_xy([body_width, body_height, body_thickness], r=front_bezel_radius, center=true);
    digit_recess_cut();
    seven_segment_apertures();
  }

  // Front "window" tint plate (thin, inside recess)
  color([0.25, 0.05, 0.05, 0.55])
  translate([
    digit_center_offset_x,
    digit_center_offset_y,
    body_thickness/2 - front_recess_depth + 0.15
  ])
    cube([max(0.1,digit_width-0.4), max(0.1,digit_height-0.4), 0.3], center=true);
}

module led() {
  color([0.85, 0.05, 0.05, 0.85]) {
    z_led = body_thickness/2 - segment_depth - 0.35;

    module seg_solid_h(pos=[0,0,0]) {
      translate(pos)
        cube([
          max(0.1, digit_width - 2*(segment_gap + segment_width/2) - 0.25),
          max(0.2, segment_width - 0.25),
          max(0.4, segment_depth)
        ], center=true);
    }
    module seg_solid_v(pos=[0,0,0]) {
      vlen = max(0.1, (digit_height - 3*segment_width - 4*segment_gap)/2);
      translate(pos)
        cube([
          max(0.2, segment_width - 0.25),
          max(0.2, vlen - 0.25),
          max(0.4, segment_depth)
        ], center=true);
    }

    // a, d, g
    seg_solid_h([
      digit_center_offset_x,
      digit_center_offset_y + digit_height/2 - segment_gap - segment_width/2,
      z_led
    ]);
    seg_solid_h([
      digit_center_offset_x,
      digit_center_offset_y - digit_height/2 + segment_gap + segment_width/2,
      z_led
    ]);
    seg_solid_h([
      digit_center_offset_x,
      digit_center_offset_y,
      z_led
    ]);

    vlen = max(0.1, (digit_height - 3*segment_width - 4*segment_gap)/2);
    y_top_center = digit_center_offset_y + (digit_height/2 - segment_gap - segment_width) - (vlen/2);
    y_bot_center = digit_center_offset_y - (digit_height/2 - segment_gap - segment_width) + (vlen/2);

    x_left  = digit_center_offset_x - digit_width/2 + segment_gap + segment_width/2;
    x_right = digit_center_offset_x + digit_width/2 - segment_gap - segment_width/2;

    // f, b, e, c
    seg_solid_v([x_left,  y_top_center, z_led]);
    seg_solid_v([x_right, y_top_center, z_led]);
    seg_solid_v([x_left,  y_bot_center, z_led]);
    seg_solid_v([x_right, y_bot_center, z_led]);
  }
}

module pins() {
  pin_span_x = (pin_cols-1)*pin_pitch_x;
  pin_span_y = (pin_rows-1)*pin_pitch_y;

  x0 = 0;
  y0 = 0;

  // Plastic spacer strip
  color([0.12, 0.12, 0.14])
  translate([x0, y0, -body_thickness/2 - 0.35])
    rounded_box_xy([pin_span_x + 2.2, pin_span_y + 2.2, 0.7], r=0.25, center=true);

  // Pins (reduced detail: single cylinder per pin)
  color([0.75, 0.75, 0.77])
  for (cx = [0:pin_cols-1])
    for (ry = [0:pin_rows-1]) {
      px = x0 + (cx - (pin_cols-1)/2)*pin_pitch_x;
      py = y0 + (ry - (pin_rows-1)/2)*pin_pitch_y;

      zc = -body_thickness/2 - pin_standoff_from_body - pin_length/2 + overlap/2;

      translate([px, py, zc])
        cylinder(d=pin_diameter, h=pin_length + overlap, center=true);
    }
}

module mod() {
  union() {
    display();
    led();
    pins();
  }
}

// =====================
// Assembly
// =====================
mod();