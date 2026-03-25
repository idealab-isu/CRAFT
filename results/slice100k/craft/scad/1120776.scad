// Flat triangular/teardrop mounting plate with 2 large lobe holes + 2 small center holes
// Target bounding box: 18.3 x 21.6 x 2.5 mm

$fn = 96;

// Parameters (mm)
bbox_X = 18.31;
bbox_Y = 21.58;
T      = 2.54;

lobe_R = 4.2;          // outer lobe radius (controls rounded corners)
tip_R  = 2.6;          // bottom tip rounding radius

hole_big_D = 4.6;
hole_big_offset_X = 5.6;
hole_big_offset_Y = 7.6;

hole_small_D = 2.2;
hole_small_spacing_X = 6.0;
hole_small_offset_Y  = 1.5;

overlap = 0.8;

// Derived extents (ensure exact bbox after clipping)
x_max = bbox_X/2;
y_max = bbox_Y/2;

// Place lobes so their outermost edges hit bbox_X exactly after clipping
lobe_cx = x_max - lobe_R;                 // lobe center X
lobe_cy = hole_big_offset_Y;              // lobe center Y (kept param-driven)

// Place tip so its lowest edge hits -bbox_Y/2 exactly after clipping
tip_cy  = -y_max + tip_R;

// Helper: 2D circle
module c2(r) circle(r=r);

// 2D outline (built from hulls of circles, then clipped to bbox)
module outline2d() {
  intersection() {
    // Clip to exact bounding box in XY
    square([bbox_X, bbox_Y], center=true);

    // Teardrop/triangular plate: hull between two top lobes and bottom tip
    hull() {
      translate([ lobe_cx, lobe_cy]) c2(lobe_R);
      translate([-lobe_cx, lobe_cy]) c2(lobe_R);
      translate([0, tip_cy])         c2(tip_R);
    }
  }
}

// 3D plate
module plate3d() {
  linear_extrude(height=T, center=true)
    outline2d();
}

// Holes (3D cutters)
module holes3d() {
  // Large lobe holes (round)
  translate([ lobe_cx, lobe_cy, 0])
    cylinder(d=hole_big_D, h=T + 2*overlap, center=true);
  translate([-lobe_cx, lobe_cy, 0])
    cylinder(d=hole_big_D, h=T + 2*overlap, center=true);

  // Two smaller holes near center (simple bolt pattern)
  translate([ hole_small_spacing_X/2, -hole_small_offset_Y, 0])
    cylinder(d=hole_small_D, h=T + 2*overlap, center=true);
  translate([-hole_small_spacing_X/2, -hole_small_offset_Y, 0])
    cylinder(d=hole_small_D, h=T + 2*overlap, center=true);
}

// Final model (single connected solid)
difference() {
  plate3d();
  holes3d();
}