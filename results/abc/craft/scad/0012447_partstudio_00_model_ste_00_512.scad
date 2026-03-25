// Dimension-calibrated (target: 0.22 x 0.08 x 0.01 mm)
scale([1.115103, 0.962661, 15.000000])
{
// Flat key-like plate: rectangular shank + circular bow with concentric circular hole
// + bit with stepped rectangular notches and ONE triangular tooth.
// Bounding box target: 0.2 x 0.1 x ~0 mm (use very thin T).

$fn = 128;

// --- Parameters (mm) ---
L = 0.20;          // overall length (X)
W = 0.10;          // overall max width (Y) (kept as an upper bound)
T = 0.001;         // near-zero thickness (Z)

shank_L = 0.12;
shank_W = 0.03;

bow_OD = 0.08;
bow_ID = 0.04;

bit_L = 0.04;
bit_W = 0.04;

// Notches (cut from top edge of bit)
notch1_L = 0.012;
notch1_depth = 0.010;

notch2_L = 0.010;
notch2_depth = 0.016;

// Single triangular tooth (adds below bottom edge of bit)
tooth_L = 0.012;
tooth_H = 0.012;
tooth_offset_from_tip = 0.010;

eps = 0.0005;      // small overlap for robust booleans

// --- Derived placement (all formula-based) ---
bow_cx = -L/2 + bow_OD/2;          // bow centered so its leftmost touches -L/2
bit_tip_x =  L/2;                  // rightmost tip at +L/2
bit_cx = bit_tip_x - bit_L/2;      // bit centered so it ends at +L/2

// Shank spans from bow rightmost to bit leftmost
shank_left_x  = bow_cx + bow_OD/2;
shank_right_x = bit_cx - bit_L/2;
shank_L_eff   = shank_right_x - shank_left_x;
shank_cx      = (shank_left_x + shank_right_x)/2;

// --- 2D profiles ---
module bow_2d() {
  difference() {
    circle(d = bow_OD);
    circle(d = bow_ID);
  }
}

module shank_2d() {
  square([shank_L_eff, shank_W], center=true);
}

module bit_base_2d() {
  square([bit_L, bit_W], center=true);
}

module tooth_2d() {
  // Right triangle protruding downward from the bit's bottom edge
  // Base along X, height along -Y.
  polygon(points=[
    [0, 0],
    [tooth_L, 0],
    [0, -tooth_H]
  ]);
}

module key_2d() {
  difference() {
    union() {
      // Bow ring
      translate([bow_cx, 0]) bow_2d();

      // Shank (connected between bow and bit)
      translate([shank_cx, 0]) shank_2d();

      // Bit base
      translate([bit_cx, 0]) bit_base_2d();

      // Single triangular tooth on bottom edge of bit
      // Place so its top edge sits on bit bottom (y = -bit_W/2)
      // and its right end is offset from the tip.
      translate([
        bit_tip_x - tooth_offset_from_tip - tooth_L,
        -bit_W/2
      ]) tooth_2d();
    }

    // Stepped notches cut from the TOP edge of the bit (y = +bit_W/2)
    // Notch 1 at the tip
    translate([
      bit_tip_x - notch1_L/2,
      bit_W/2 - notch1_depth/2
    ])
      square([notch1_L, notch1_depth], center=true);

    // Notch 2 just behind notch 1
    translate([
      bit_tip_x - notch1_L - notch2_L/2,
      bit_W/2 - notch2_depth/2
    ])
      square([notch2_L, notch2_depth], center=true);
  }
}

// --- 3D (thin plate) ---
linear_extrude(height=T, center=true, convexity=10)
  key_2d();
}
