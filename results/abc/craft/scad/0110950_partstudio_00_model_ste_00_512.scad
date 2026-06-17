// Dimension-calibrated (target: 0.06 x 0.04 x 0.05 mm)
scale([0.842105, 1.000000, 1.060000])
{
// Wedge-ended rectangular block with integrated U-shaped clevis/handle
// Units: mm (very small part as given)

$fn = 64;

// Parameters
L = 0.06;
W = 0.04;
H = 0.05;

wedge_L = 0.018;
body_L  = 0.042;

clevis_L = 0.016;
arm_t    = 0.008;
gap_W    = 0.016;
arm_H    = 0.04;

cutout_r = 0.009;
cutout_z = 0.025;

overlap  = 0.001;

// Derived
x0 = -L/2;                 // overall min X
x1 =  L/2;                 // overall max X
x_clevis0 = x0;
x_clevis1 = x0 + clevis_L;
x_body0   = x_clevis1;
x_body1   = x_body0 + body_L;
x_wedge0  = x_body1;
x_wedge1  = x_wedge0 + wedge_L;

// Main prismatic body (rectangular block)
module main_body() {
  translate([(x_body0 + x_body1)/2, 0, 0])
    cube([body_L, W, H], center=true);
}

// Wedge tip as a prism (triangular in top view), extruded in Z
module wedge_tip() {
  // 2D triangle in XY, extruded along Z
  translate([x_wedge0, 0, 0])
    linear_extrude(height=H, center=true)
      polygon(points=[
        [0,   -W/2],
        [0,    W/2],
        [wedge_L, 0]
      ]);
}

// Clevis: two fork arms connected to the body at the clevis end
module clevis_arms() {
  // Ensure arms overlap slightly into the body so the whole model is one connected solid
  arm_len = clevis_L + overlap;

  // Place arms so their outer face starts at x0 and they extend toward +X
  translate([x0 + arm_len/2, 0, 0]) {
    translate([0, -(gap_W/2 + arm_t/2), 0])
      cube([arm_len, arm_t, arm_H], center=true);
    translate([0,  (gap_W/2 + arm_t/2), 0])
      cube([arm_len, arm_t, arm_H], center=true);
  }
}

// Subtractive U-channel between arms
module clevis_channel_cut() {
  // Cut only within clevis length; keep a tiny overlap to avoid coplanar artifacts
  cut_len = clevis_L + 2*overlap;
  translate([x0 + clevis_L/2, 0, 0])
    cube([cut_len, gap_W, arm_H + 2*overlap], center=true);
}

// Subtractive through-hole across the clevis loop (along Y)
module clevis_through_cutout() {
  // Position in Z relative to the main body center (z=0)
  translate([x0 + clevis_L/2, 0, cutout_z - H/2])
    rotate([90, 0, 0])
      cylinder(r=cutout_r, h=W + 2*overlap, center=true);
}

// Final connected solid
module model() {
  difference() {
    union() {
      main_body();
      wedge_tip();
      clevis_arms();
    }
    clevis_channel_cut();
    clevis_through_cutout();
  }
}

model();
}
