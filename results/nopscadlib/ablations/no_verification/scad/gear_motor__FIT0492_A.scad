// Parameters (kept; type_v* provided by prompt)
type_v0 = 6;   //[3:12:0.1]
type_v1 = 5.5; //[2.75:11:0.1]
type_v2 = 14.7;//[7.35:29.4:0.1]
type_v3 = 12;  //[6:24:0.1]

alpha = 1; //[0.1:1:0.05]
eps = 0.8; //[0.2:2:0.1]

// Core dimensions
shaft_d = 3; //[1.5:6:0.1]
shaft_len = 10; //[5:20:0.1]
shaft_boss_d = 8; //[4:16:0.1]
shaft_boss_h = 3; //[1.5:6:0.1]

gearbox_w = 18; //[9:36:0.1]
gearbox_d = 14; //[7:28:0.1]
gearbox_h = 10; //[5:20:0.1]

motor_d = 12; //[6:24:0.1]
motor_len = 24; //[12:48:0.1]
motor_offset_x = 6; //[0:12:0.1]

hub_d = 6; //[3:12:0.1]
hub_h = 2; //[1:4:0.1]

screw_hole_d = 2.2; //[1.2:4.4:0.1]
screw_boss_d = 5.5; //[3:11:0.1]
screw_boss_extra_h = 2; //[1:4:0.1]
screw_spacing_x = 12; //[6:24:0.1]
screw_spacing_y = 8; //[4:16:0.1]

tag_w = 4; //[2:8:0.1]
tag_h = 6; //[3:12:0.1]
tag_t = 1; //[0.5:2:0.1]
tag_spacing = 6; //[3:12:0.1]

$fn = 64;

// Gear Motor - ONE connected solid
module gear_motor() {
  ov = max(0.25, eps*0.25);

  // Place motor axis along +Y (matches reference: motor "down" in left/right views)
  // Motor is attached to gearbox on its +Y face, centered in X.
  motor_cy = gearbox_d/2 - ov + motor_len/2;
  motor_cx = 0;
  motor_cz = -gearbox_h/2 - motor_d/2 + ov; // slightly below gearbox

  // Hub at motor far end (+Y), overlapping into motor
  hub_cy = motor_cy + motor_len/2 - hub_h/2 + ov;

  // Top shaft and boss on gearbox top (+Z)
  shaft_cz = gearbox_h/2 + shaft_len/2 - ov;
  boss_cz  = gearbox_h/2 + shaft_boss_h/2 - ov;

  // Screw bosses: two posts on one face (as in reference), on -Y face of gearbox
  // Ensure they connect by overlapping into gearbox by ov.
  boss_h = gearbox_h; // posts run full height for a solid, connected look
  screw_post_cy = -gearbox_d/2 + ov + screw_boss_d/2; // tangent to -Y face with overlap
  screw_post_cz = 0;

  // Electrical tags: small tabs on motor can near gearbox end, on +X side
  tag_cy = motor_cy - motor_len/2 + tag_w/2; // near gearbox end of motor
  tag_cx = motor_d/2 - ov + tag_t/2;         // attached to motor side
  tag_cz = motor_cz;

  difference() {
    union() {
      // Gearbox body
      cube([gearbox_w, gearbox_d, gearbox_h], center=true);

      // Motor can (axis along Y)
      translate([motor_cx, motor_cy, motor_cz])
        rotate([90, 0, 0])
          cylinder(r=motor_d/2, h=motor_len, center=true);

      // Motor hub (small cylinder at far end)
      translate([motor_cx, hub_cy, motor_cz])
        rotate([90, 0, 0])
          cylinder(r=hub_d/2, h=hub_h, center=true);

      // Output shaft (top)
      translate([0, 0, shaft_cz])
        cylinder(r=shaft_d/2, h=shaft_len, center=true);

      // Shaft boss (top)
      translate([0, 0, boss_cz])
        cylinder(r=shaft_boss_d/2, h=shaft_boss_h, center=true);

      // Two screw posts on -Y face (top/bottom in Z)
      for (z = [-screw_spacing_y/2, screw_spacing_y/2])
        translate([0, screw_post_cy, z])
          cylinder(r=screw_boss_d/2, h=boss_h, center=true);

      // Electrical tags (two)
      for (sz = [-tag_spacing/2, tag_spacing/2])
        translate([tag_cx, tag_cy, tag_cz + sz])
          cube([tag_t, tag_w, tag_h], center=true);
    }

    // Shallow dimples on the two posts (do not cut through gearbox)
    dimple_h = screw_boss_d; // shallow
    for (z = [-screw_spacing_y/2, screw_spacing_y/2])
      translate([0, screw_post_cy, z])
        cylinder(r=screw_hole_d/2, h=dimple_h, center=true);
  }
}

gear_motor();