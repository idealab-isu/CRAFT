// Parameters
led_type = 0; //[0:2:1]
colour = 0; //[0:5:1]
lead = 5; //[2.5:10:0.5]
right_angle = 0; //[0:12:1]
overlap = 0.8; //[0.5:2:0.1]
d_round_5 = 5; //[2.5:10:0.1]
h_round_5 = 8.5; //[4:17:0.1]
rim_d_round_5 = 5.8; //[3:12:0.1]
rim_t_round_5 = 1.2; //[0.6:2.4:0.1]
pitch_round_5 = 2.54; //[1.5:5:0.01]
d_round_3 = 3; //[1.5:6:0.1]
h_round_3 = 5.2; //[2.5:10.4:0.1]
rim_d_round_3 = 3.6; //[2:7.2:0.1]
rim_t_round_3 = 0.9; //[0.5:1.8:0.1]
pitch_round_3 = 2; //[1:4:0.01]
rect_w = 5; //[2.5:10:0.1]
rect_d = 2; //[1:4:0.1]
rect_h = 7; //[3.5:14:0.1]
rect_rim_w = 5.6; //[2.8:11.2:0.1]
rect_rim_d = 2.6; //[1.3:5.2:0.1]
rect_rim_t = 1; //[0.5:2:0.1]
pitch_rect = 2.54; //[1.5:5:0.01]
lead_t = 0.6; //[0.3:1.2:0.05]
bend_radius = 0.9; //[0.5:2:0.1]

$fn = 64;

// Helpers: choose dimensions based on led_type
function body_h() = (led_type==0) ? h_round_5 : (led_type==1) ? h_round_3 : rect_h;
function body_d() = (led_type==0) ? d_round_5 : (led_type==1) ? d_round_3 : max(rect_w, rect_d);
function rim_t()  = (led_type==0) ? rim_t_round_5 : (led_type==1) ? rim_t_round_3 : rect_rim_t;
function pitch()  = (led_type==0) ? pitch_round_5 : (led_type==1) ? pitch_round_3 : pitch_rect;

// LED Module (base at z=0, extends upward)
module led_body() {
  if (led_type == 0) {
    union() {
      // Main body
      translate([0, 0, body_h()/2])
        cylinder(r=d_round_5/2, h=h_round_5, center=true);
      // Rim at base, overlapping into body
      translate([0, 0, rim_t()/2])
        cylinder(r=rim_d_round_5/2, h=rim_t_round_5, center=true);
    }
  } else if (led_type == 1) {
    union() {
      translate([0, 0, body_h()/2])
        cylinder(r=d_round_3/2, h=h_round_3, center=true);
      translate([0, 0, rim_t()/2])
        cylinder(r=rim_d_round_3/2, h=rim_t_round_3, center=true);
    }
  } else {
    union() {
      translate([0, 0, body_h()/2])
        cube([rect_w, rect_d, rect_h], center=true);
      translate([0, 0, rim_t()/2])
        cube([rect_rim_w, rect_rim_d, rect_rim_t], center=true);
    }
  }
}

// Leads Module (connected to rim/base with overlap)
module leads_geom() {
  p = pitch();
  // Ensure some penetration into LED base for a single connected solid
  z0 = -lead/2;                 // center of straight lead segment (extends from -lead..0)
  z_attach = lead_t/2 - overlap; // small overlap into z>0 region

  if (right_angle <= 0) {
    union() {
      // Straight leads: extend from z=-lead to z=+overlap (into LED)
      translate([-p/2, 0, (-lead + overlap)/2])
        cube([lead_t, lead_t, lead + overlap], center=true);
      translate([ p/2, 0, (-lead + overlap)/2])
        cube([lead_t, lead_t, lead + overlap], center=true);
    }
  } else {
    // Bent leads: vertical down, then horizontal back (negative Y)
    vlen = max(0.01, lead - right_angle);
    hlen = max(0.01, right_angle);

    union() {
      for (sx = [-1, 1]) {
        x = sx * p/2;

        // Vertical segment: from z=-vlen to z=+overlap
        translate([x, 0, (-vlen + overlap)/2])
          cube([lead_t, lead_t, vlen + overlap], center=true);

        // Horizontal segment: starts at z=0 (with overlap into LED), goes to -Y
        translate([x, -(hlen)/2, z_attach])
          cube([lead_t, hlen + overlap, lead_t], center=true);

        // Simple bend fillet (quarter torus) positioned to touch both segments
        // Place its center at the corner (x, -bend_radius, 0) and overlap slightly into LED
        translate([x, -bend_radius, -bend_radius + overlap/2])
          rotate([90, 0, 0])
            rotate_extrude(angle=90)
              translate([bend_radius, 0, 0])
                circle(r=lead_t/2);
      }
    }
  }
}

// Final Assembly: single connected solid (union of all geometry)
union() {
  color("red") led_body();
  color("Silver") leads_geom();
}