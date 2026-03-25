// Dimension-calibrated (target: 0.01 x 0.01 x 0.02 mm)
scale([0.800058, 0.800134, 1.300218])
{
// T-bracket with circular through-hole (all dimensions in meters as given)

// Increase circle resolution so the hole is truly circular (not polygonal)
$fn = 96;

// Parameters
bbox_L = 0.02; //[0.01:0.04:0.001]
bbox_W = 0.01; //[0.005:0.02:0.001]
bbox_H = 0.01; //[0.005:0.02:0.001]

plate_L = 0.012; //[0.006:0.024:0.001]
plate_W = 0.01;  //[0.005:0.02:0.001]
plate_H = 0.01;  //[0.005:0.02:0.001]

stem_L  = 0.008; //[0.004:0.016:0.001]
stem_W  = 0.004; //[0.002:0.008:0.001]
stem_H  = 0.01;  //[0.005:0.02:0.001]

hole_d = 0.003; //[0.0015:0.006:0.0005]
hole_center_x_from_plate_end = 0.006; //[0.0:0.012:0.001]
hole_center_y = 0.005; //[0.0:0.01:0.001]

overlap = 0.001; //[0.0005:0.002:0.0005]
hole_extra_h = 0.002; //[0.001:0.004:0.0005]

// Derived: keep the overall length consistent with bbox_L
// Place plate and stem so the combined length spans bbox_L, centered at origin.
plate_xc = -bbox_L/2 + plate_L/2;
stem_xc  =  bbox_L/2 - stem_L/2;

// Base Shapes
module plate_block() {
  translate([plate_xc, 0, 0])
    cube([plate_L, plate_W, plate_H], center=true);
}

module stem_block() {
  translate([stem_xc, 0, 0])
    cube([stem_L, stem_W, stem_H], center=true);
}

module through_hole() {
  // Hole center measured from the plate's left end along X, and from plate's bottom along Y
  hole_x = (-bbox_L/2) + (plate_L - hole_center_x_from_plate_end);
  hole_y = (-plate_W/2) + hole_center_y;

  translate([hole_x, hole_y, 0])
    cylinder(h=plate_H + hole_extra_h, r=hole_d/2, center=true);
}

// Operations
module t_body_union() {
  // Ensure connectivity by overlapping stem into plate by 'overlap'
  union() {
    plate_block();
    translate([stem_xc - overlap/2, 0, 0])  // shift slightly into plate for guaranteed overlap
      cube([stem_L + overlap, stem_W, stem_H], center=true);
  }
}

module final_model() {
  difference() {
    t_body_union();
    through_hole();
  }
}

// Final Output
final_model();
}
