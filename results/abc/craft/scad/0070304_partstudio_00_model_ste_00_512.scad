// Dimension-calibrated (target: 0.09 x 0.04 x 0.04 mm)
scale([0.872635, 0.950523, 9.500665])
{
// Flat stepped mounting plate with narrow tongue + rounded tip and 5 hex through-holes
// Units are in mm (small values here are intentional per provided parameters).

$fn = 96;

// Parameters
L = 0.09;                 //[0.045:0.18:0.001] overall length
W = 0.04;                 //[0.02:0.08:0.001] body width
T = 0.004;                //[0.002:0.008:0.0005] thickness

base_L = 0.05;            //[0.025:0.1:0.001] wide section length
tongue_L = 0.04;          //[0.02:0.08:0.001] narrow tongue length
tongue_W = 0.024;         //[0.012:0.048:0.001] tongue width
tip_R = 0.012;            //[0.006:0.024:0.001] rounded tip radius (semicircle)

hex_large_AF = 0.016;     //[0.008:0.032:0.001] across flats
hex_small_AF = 0.008;     //[0.004:0.016:0.0005]
hex_clearance = 0.0005;   //[0.0:0.0015:0.0001]

large_hex_x = 0.022;      //[0.011:0.044:0.001] from left end of overall part
large_hex_y = 0.0;        //[-0.01:0.01:0.0005]

small_hex_center_x = 0.072; //[0.036:0.144:0.001] from left end of overall part
small_hex_dx = 0.01;        //[0.005:0.02:0.0005]
small_hex_dy = 0.01;        //[0.005:0.02:0.0005]

overlap = 0.001;          //[0.0005:0.002:0.0001] ensures connectivity/robust boolean

// Helpers
function hex_r_from_AF(af) = (af/2) / cos(30); // circumradius for a hex with given across-flats

module hex_hole(af, h) {
  rotate([0,0,30])
    cylinder(r=hex_r_from_AF(af + hex_clearance), h=h, center=true, $fn=6);
}

// 2D outline (extruded to thickness)
module plate_2d() {
  // Coordinate system: x from 0..L, y centered about 0
  // Wide rectangle: [0..base_L] x [-W/2..W/2]
  // Tongue rectangle: [base_L..base_L+tongue_L] x [-tongue_W/2..tongue_W/2]
  // Rounded tip: semicircle centered at x = base_L + tongue_L, radius tip_R, unioned with tongue
  union() {
    translate([base_L/2, 0])
      square([base_L, W], center=true);

    // Tongue + rounded end
    union() {
      translate([base_L + tongue_L/2, 0])
        square([tongue_L, tongue_W], center=true);

      // Full circle unioned; only the forward half protrudes beyond tongue end
      translate([base_L + tongue_L, 0])
        circle(r=tip_R);
    }
  }
}

module plate_solid() {
  linear_extrude(height=T, center=true, convexity=10)
    plate_2d();
}

module holes() {
  // Through holes: make taller than T for clean subtraction
  hole_h = T + 2*overlap;

  // Large hex on wide section
  translate([large_hex_x, large_hex_y, 0])
    hex_hole(hex_large_AF, hole_h);

  // Four small hex holes in 2x2 near rounded end
  for (sx = [-small_hex_dx/2, small_hex_dx/2])
    for (sy = [-small_hex_dy/2, small_hex_dy/2])
      translate([small_hex_center_x + sx, sy, 0])
        hex_hole(hex_small_AF, hole_h);
}

// Final
difference() {
  plate_solid();
  holes();
}
}
