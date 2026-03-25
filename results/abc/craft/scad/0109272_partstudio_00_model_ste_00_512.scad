// Dimension-calibrated (target: 0.07 x 0.01 x 0.06 mm)
scale([0.928879, 0.950523, 0.500084])
{
// Thin mounting plate with rounded corners, 4 corner through-holes,
// stepped side notch on one edge, and mirrored engraved text on both faces.
// Units are mm (very small part as provided).

// Parameters
L = 0.07; //[0.035:0.14:0.001]
W = 0.06; //[0.03:0.12:0.001]
T = 0.01; //[0.005:0.02:0.001]

corner_r = 0.006; //[0.003:0.012:0.001]

hole_d = 0.006; //[0.003:0.012:0.001]
hole_edge_offset_x = 0.01; //[0.005:0.02:0.001]
hole_edge_offset_y = 0.01; //[0.005:0.02:0.001]

notch_depth = 0.012; //[0.006:0.024:0.001]
notch_w1 = 0.018; //[0.009:0.036:0.001]
notch_w2 = 0.01;  //[0.005:0.02:0.001]
notch_step = 0.004; //[0.002:0.008:0.001]  // how much deeper the smaller step goes

notch_fillet_r = 0.002; //[0.001:0.004:0.001]

text_str = "Sleepy Pi 2";
text_size = 0.012;      // scaled for tiny model
text_depth = 0.0012;    // engraving depth
text_font = "Liberation Sans:style=Bold";

eps = 0.001; //[0.0005:0.002:0.0005]
$fn = 48;

// Rounded rectangle prism (centered)
module rounded_plate(l, w, h, r) {
  // Ensure sane radii
  rr = min(r, min(l, w)/2 - eps);
  linear_extrude(height=h, center=true)
    offset(r=rr)
      square([l - 2*rr, w - 2*rr], center=true);
}

// Stepped notch cutout on +Y edge (centered in X)
module stepped_notch_cut() {
  // Main shallow notch (w1, depth)
  // Second deeper step (w2, depth+notch_step), centered within w1
  union() {
    translate([0, W/2 - notch_depth/2, 0])
      cube([notch_w1, notch_depth + eps, T + 2*eps], center=true);

    translate([0, W/2 - (notch_depth + notch_step)/2, 0])
      cube([notch_w2, notch_depth + notch_step + eps, T + 2*eps], center=true);

    // Simple fillet relief at the two inner corners of the shallow notch
    // (subtracting cylinders helps avoid jagged artifacts)
    for (sx = [-1, 1]) {
      translate([sx*(notch_w1/2 - notch_fillet_r), W/2 - notch_depth + notch_fillet_r, 0])
        cylinder(r=notch_fillet_r, h=T + 2*eps, center=true);
    }
  }
}

// Corner through-holes
module corner_holes() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*(L/2 - hole_edge_offset_x), sy*(W/2 - hole_edge_offset_y), 0])
      cylinder(r=hole_d/2, h=T + 2*eps, center=true);
  }
}

// Engraved text on both faces (mirrored on opposite face)
module mirrored_engraving() {
  // Keep text within plate
  max_w = L - 2*corner_r - 2*eps;
  max_h = W - 2*corner_r - 2*eps;

  // Top face engraving (cut into top)
  translate([0, 0, T/2 - text_depth/2])
    linear_extrude(height=text_depth + eps, center=true)
      text(text_str, size=text_size, font=text_font, halign="center", valign="center");

  // Bottom face engraving, mirrored (so it reads correctly from bottom)
  mirror([0, 1, 0])
    translate([0, 0, -T/2 + text_depth/2])
      linear_extrude(height=text_depth + eps, center=true)
        text(text_str, size=text_size, font=text_font, halign="center", valign="center");
}

// Complete model: one connected solid
difference() {
  // Base plate
  rounded_plate(L, W, T, corner_r);

  // Features to remove
  corner_holes();
  stepped_notch_cut();
  mirrored_engraving();
}
}
