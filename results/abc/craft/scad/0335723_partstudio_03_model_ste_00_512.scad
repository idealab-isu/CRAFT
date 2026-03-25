// Dimension-calibrated (target: 0.02 x 0.01 x 0.02 mm)
scale([1.299243, 1.700286, 0.807723])
{
// Parameters (meters; OpenSCAD default units are arbitrary)
bbox_X = 0.02; //[0.01:0.04:0.001]
bbox_Y = 0.01; //[0.005:0.02:0.001]
bbox_Z = 0.02; //[0.01:0.04:0.001]
shaft_d = 0.01; //[0.005:0.02:0.0005]
shaft_L = 0.02; //[0.01:0.04:0.001]
collar_AF = 0.01; //[0.005:0.02:0.0005]
collar_thk = 0.006; //[0.003:0.012:0.0005]
chamfer = 0.0005; //[0.0002:0.001:0.0001]
overlap = 0.0005; //[0.0002:0.001:0.0001]
engrave_depth = 0.0003; //[0.0001:0.0008:0.0001]
engrave_w = 0.0006; //[0.0003:0.0012:0.0001]
engrave_L = 0.004; //[0.002:0.008:0.0005]

$fn = 96;

// Derived
shaft_r = shaft_d/2;
hex_R   = collar_AF / sqrt(3);          // circumradius for across-flats = collar_AF
total_L = shaft_L + collar_thk;         // overall length

// Base solids
module shaft_cylinder() {
  // Clean cylinder spanning full length; collar will be unioned around midsection
  cylinder(h=total_L, r=shaft_r, center=true);
}

module hex_collar() {
  // True 6-flat hex prism (wrenching surface)
  cylinder(h=collar_thk, r=hex_R, $fn=6, center=true);
}

// Engraving cuts (kept shallow; placed on opposite flats)
module engraving_mark_cut_pos() {
  translate([0, collar_AF/2 - engrave_depth/2, 0])
    cube([collar_AF*1.2, engrave_depth, engrave_L], center=true);
}

module engraving_mark_cut_neg() {
  translate([0, -(collar_AF/2 - engrave_depth/2), 0])
    cube([collar_AF*1.2, engrave_depth, engrave_L], center=true);
}

// Final
difference() {
  union() {
    shaft_cylinder();
    hex_collar();
  }
  engraving_mark_cut_pos();
  engraving_mark_cut_neg();
}
}
