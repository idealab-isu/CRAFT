// Dimension-calibrated (target: 19.59 x 12.45 x 12.45 mm)
scale([0.670857, 1.037167, 1.555750])
{
// Bracket-like part: lug with through-hole + arm + angled end pad + U-notch
// Connectivity + recognizable U-notch fix: make arm/pad share the lug's Z center,
// and add a small "neck" web between lug and arm so they are one manifold solid.

$fn = 48;

// Parameters
bbox_L = 19.59; //[9.8:39.2:0.01]
bbox_W = 12.45; //[6.2:24.9:0.01]
bbox_H = 12.45; //[6.2:24.9:0.01]
lug_od = 12.0; //[6.0:12.45:0.01]
lug_thk = 8.0; //[4.0:12.45:0.01]
hole_d = 4.0; //[2.0:8.0:0.01]
arm_thk = 3.0; //[1.5:6.0:0.01]
arm_W = 8.0; //[4.0:12.45:0.01]
arm_L = 13.5; //[6.0:19.59:0.01]
pad_L = 5.0; //[2.5:10.0:0.01]
pad_W = 9.0; //[4.5:12.45:0.01]
pad_thk = 3.5; //[1.5:8.0:0.01]
pad_angle_deg = 20.0; //[0.0:45.0:0.1]
notch_R = 3.0; //[1.5:5.0:0.01]
notch_W = 7.0; //[3.0:10.0:0.01]
notch_depth = 6.0; //[2.0:12.0:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
step_h = 0.6; //[0.3:1.5:0.01]
step_L = 1.8; //[0.8:4.0:0.01]

// Derived placement (X axis is length)
lug_cx = (-bbox_L/2) + (lug_od/2);
lug_right_x = lug_cx + lug_od/2;

arm_cx = lug_right_x - overlap + arm_L/2;
arm_right_x = arm_cx + arm_L/2;

pad_pivot_x = arm_right_x - overlap;

// Put arm/pad centered in Z with lug so they intersect (prevents "floating" in Z)
z_arm = 0;

// Base Shapes
module lug_boss() {
  translate([lug_cx, 0, 0])
    cylinder(r=lug_od/2, h=lug_thk, center=true);
}

module lug_through_hole_round() {
  translate([lug_cx, 0, 0])
    cylinder(r=hole_d/2, h=bbox_H + 6*overlap, center=true);
}

module main_arm_base() {
  translate([arm_cx, 0, z_arm])
    cube([arm_L, arm_W, arm_thk], center=true);
}

// Neck/web between lug and arm to guarantee manifold connection even after notch subtraction
module lug_to_arm_neck() {
  neck_L = 2*overlap;
  neck_x = lug_right_x - overlap; // straddles lug/arm interface
  translate([neck_x, 0, z_arm])
    cube([neck_L, arm_W, arm_thk], center=true);
}

// Angled end pad, rotated about its INNER FACE so it stays attached
module end_pad_rotated_connected() {
  translate([pad_pivot_x, 0, z_arm])
    rotate([0, pad_angle_deg, 0])
      translate([pad_L/2, 0, 0])
        cube([pad_L, pad_W, pad_thk], center=true);
}

// Small overlap "web" at the pivot to guarantee manifold connection
module pad_connection_web() {
  translate([pad_pivot_x, 0, z_arm])
    cube([2*overlap, max(arm_W, pad_W), max(arm_thk, pad_thk)], center=true);
}

// U-shaped relief/notch (subtractive), cut through arm thickness
module u_shaped_relief_notch() {
  notch_x0 = lug_right_x - overlap; // arm start plane

  // Rect portion
  translate([notch_x0 + (notch_depth - notch_R)/2, 0, z_arm])
    cube([notch_depth - notch_R, notch_W, arm_thk + 6*overlap], center=true);

  // Rounded end (cylinder axis along Y)
  translate([notch_x0 + (notch_depth - notch_R), 0, z_arm])
    rotate([90, 0, 0])
      cylinder(r=notch_R, h=notch_W + 6*overlap, center=true);
}

module small_alignment_steps() {
  translate([lug_right_x - overlap + arm_L*0.55, 0,
             z_arm - (arm_thk/2) + (step_h/2) - overlap])
    cube([step_L, arm_W*0.6, step_h], center=true);
}

// Main solid (connected)
module arm_lug_pad_solid() {
  union() {
    lug_boss();
    main_arm_base();
    lug_to_arm_neck();
    end_pad_rotated_connected();
    pad_connection_web();
    small_alignment_steps();
  }
}

// Final part
difference() {
  arm_lug_pad_solid();
  u_shaped_relief_notch();
  lug_through_hole_round();
}
}
