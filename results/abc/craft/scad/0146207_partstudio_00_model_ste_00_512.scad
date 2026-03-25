// Dimension-calibrated (target: 0.16 x 0.27 x 0.03 mm)
scale([1.000037, 0.701761, 1.120022])
{
// Thin mounting plate with rounded corners, 4 corner holes,
// 2 opposite diamond tabs with holes, and a raised faceted octagonal bezel
// around a recessed rectangular pocket. Single connected solid.

// ---------------- Parameters ----------------
bbox_L = 0.27; //[0.135:0.54:0.001]
bbox_W = 0.16; //[0.08:0.32:0.001]
bbox_H = 0.03; //[0.015:0.06:0.001]

plate_thk = 0.018; //[0.009:0.036:0.001]
corner_R = 0.012; //[0.006:0.024:0.001]

corner_hole_d = 0.01; //[0.005:0.02:0.001]
corner_hole_edge_offset_L = 0.02; //[0.01:0.04:0.001]
corner_hole_edge_offset_W = 0.02; //[0.01:0.04:0.001]

tab_span_out = 0.02; //[0.01:0.04:0.001]
tab_diamond_L = 0.04; //[0.02:0.08:0.001]
tab_diamond_W = 0.03; //[0.015:0.06:0.001]
tab_hole_d = 0.01; //[0.005:0.02:0.001]

bezel_outer_flat_d = 0.09; //[0.045:0.18:0.001]
bezel_inner_flat_d = 0.065; //[0.0325:0.13:0.001]
bezel_h = 0.008; //[0.004:0.016:0.001]

pocket_L = 0.09; //[0.045:0.18:0.001]
pocket_W = 0.05; //[0.025:0.1:0.001]
pocket_depth = 0.006; //[0.003:0.012:0.001]

eps_overlap = 0.001; //[0.0005:0.002:0.0005]
hole_extra_h = 0.01; //[0.005:0.02:0.001]
bezel_facet_scale = 0.92; //[0.85:0.98:0.01]

$fn = 64;

// ---------------- Helpers ----------------
module rounded_rect_2d(L, W, R) {
  // Robust rounded rectangle (2D) using hull of circles
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
  }
}

module oct_2d(flat_d) {
  // Octagon defined by "flat-to-flat" distance along X/Y
  polygon(points=[
    [ flat_d/2, 0],
    [ flat_d/4,  flat_d/4],
    [ 0,  flat_d/2],
    [-flat_d/4,  flat_d/4],
    [-flat_d/2, 0],
    [-flat_d/4, -flat_d/4],
    [ 0, -flat_d/2],
    [ flat_d/4, -flat_d/4]
  ]);
}

module plate_solid() {
  // Single connected base plate + integrated tabs (same thickness)
  union() {
    linear_extrude(height=plate_thk, center=true)
      rounded_rect_2d(bbox_L, bbox_W, corner_R);

    // Tabs centered on midpoints of two opposite sides (along +/-Y)
    for (sy = [-1, 1]) {
      translate([0, sy*(bbox_W/2 + tab_span_out - eps_overlap), 0])
        linear_extrude(height=plate_thk, center=true)
          polygon(points=[
            [ tab_diamond_L/2, 0],
            [ 0,  tab_diamond_W/2],
            [-tab_diamond_L/2, 0],
            [ 0, -tab_diamond_W/2]
          ]);
    }
  }
}

module bezel_ring_faceted() {
  // Raised octagonal ring with a faceted top (via slight scale taper)
  // Outer ring minus inner opening; then intersect with a tapered prism to create facets.
  zc = plate_thk/2 + bezel_h/2 - eps_overlap;

  translate([0,0,zc])
  intersection() {
    // Ring volume
    difference() {
      linear_extrude(height=bezel_h, center=true) oct_2d(bezel_outer_flat_d);
      linear_extrude(height=bezel_h + hole_extra_h, center=true) oct_2d(bezel_inner_flat_d);
    }

    // Facet shaper: tapered octagonal prism (creates planar facets on the ring)
    linear_extrude(height=bezel_h, center=true, scale=bezel_facet_scale)
      oct_2d(bezel_outer_flat_d);
  }
}

module corner_holes_4x() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([
      sx*(bbox_L/2 - corner_hole_edge_offset_L),
      sy*(bbox_W/2 - corner_hole_edge_offset_W),
      0
    ])
      cylinder(d=corner_hole_d, h=plate_thk + bezel_h + hole_extra_h, center=true);
  }
}

module tab_holes_2x() {
  for (sy = [-1, 1]) {
    translate([0, sy*(bbox_W/2 + tab_span_out - eps_overlap), 0])
      cylinder(d=tab_hole_d, h=plate_thk + hole_extra_h, center=true);
  }
}

module pocket_cutter() {
  // Recessed rectangular pocket from the top face into the plate
  // Place cutter so it starts at top surface and goes down pocket_depth.
  translate([0, 0, plate_thk/2 - pocket_depth/2 + eps_overlap])
    cube([pocket_L, pocket_W, pocket_depth + hole_extra_h], center=true);
}

// ---------------- Final Model ----------------
difference() {
  union() {
    plate_solid();
    bezel_ring_faceted();
  }

  // Holes
  corner_holes_4x();
  tab_holes_2x();

  // Central recessed pocket
  pocket_cutter();
}
}
