// Dimension-calibrated (target: 0.11 x 0.21 x 0.10 mm)
scale([1.043902, 1.066688, 1.375000])
{
// Corrected to match: slender faceted/twisted prismatic rod + one chamfered rectangular block near one end
// + TWO distinct faceted polyhedral knobs mounted along the rod. Removed extra thin protruding elements.
// Ensures ONE connected solid. All translate() values derived from dimensions.

$fn = 64;

// Parameters (kept, but rod/block/knobs rebuilt to match description)
bbox_L = 0.21; //[0.105:0.42:0.001]
bbox_W = 0.11; //[0.055:0.22:0.001]
bbox_H = 0.1;  //[0.05:0.2:0.001]

rod_L = 0.205; //[0.1025:0.41:0.001]
rod_W = 0.02;  //[0.01:0.04:0.001]
rod_H = 0.02;  //[0.01:0.04:0.001]
rod_facet_sides = 8; //[4:16:1]
rod_twist_deg = 35;  //[0:120:1]

block_L = 0.06; //[0.03:0.12:0.001]
block_W = 0.09; //[0.045:0.18:0.001]
block_H = 0.08; //[0.04:0.16:0.001]
block_edge_chamfer = 0.004; //[0.002:0.008:0.0005]
block_pos_from_end = 0.02; //[0.01:0.04:0.001]

knob1_d = 0.04; //[0.02:0.08:0.001]
knob1_H = 0.03; //[0.015:0.06:0.001]
knob1_sides = 8; //[4:16:1]
knob1_pos = 0.075; //[0.03:0.16:0.001]

knob2_d = 0.032; //[0.016:0.064:0.001]
knob2_H = 0.026; //[0.013:0.052:0.001]
knob2_sides = 8; //[4:16:1]
knob2_pos = 0.145; //[0.06:0.19:0.001]
knob2_radial_offset = 0.018; //[0.009:0.036:0.001]

overlap = 0.001; //[0.0005:0.002:0.0005]
knob_bevel = 0.002; //[0.001:0.004:0.0005]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module oct_like_polygon(d, sides=8, rot=0) {
  // Regular polygon points (octagonal-like)
  polygon(points=[
    for (i=[0:sides-1])
      let(a = rot + i*360/sides)
      [ (d/2)*cos(a), (d/2)*sin(a) ]
  ]);
}

// Chamfer vertical edges of a rectangular prism by cutting 4 long wedges along Z
module chamfered_block(size=[1,1,1], c=0.05) {
  L = size[0]; W = size[1]; H = size[2];
  c2 = clamp(c, 0, min(W,H)/2 - 1e-6);

  difference() {
    cube([L,W,H], center=true);

    // Cut along the 4 vertical edges (parallel to X axis? Actually edges along Z at (±W/2, ±H/2))
    // Use long rotated prisms that remove a 45° chamfer on Y/Z corners.
    for (sy=[-1,1], sz=[-1,1]) {
      translate([0, sy*(W/2 - c2), sz*(H/2 - c2)])
        rotate([0,45*sy*sz,0])  // keep cut stable; actual chamfer comes from 45° in YZ via Z-rotation below
          rotate([45,0,0])
            cube([L + 2*overlap, 2*c2, 2*c2], center=true);
    }
  }
}

// Faceted prismatic rod with twist (irregular/faceted surface)
module twisted_faceted_rod() {
  // Build along X axis by extruding along Z then rotating.
  rotate([0,90,0])
    linear_extrude(height=rod_L, center=true, twist=rod_twist_deg, slices=max(20, rod_facet_sides*6))
      oct_like_polygon(d=min(rod_W,rod_H), sides=rod_facet_sides, rot=360/(rod_facet_sides*2));
}

// Faceted knob (octagonal-like) with slight bevel on both ends
module faceted_knob(d, h, sides=8) {
  // Use linear_extrude + scale to create beveled ends (frustum-like)
  // Centered on origin, axis along X after rotate.
  rotate([0,90,0])
    union() {
      // main body with slight taper
      linear_extrude(height=h, center=true, scale=0.96, slices=20)
        oct_like_polygon(d=d, sides=sides, rot=360/(sides*2));

      // end bevels (small frustums)
      for (sx=[-1,1]) {
        translate([sx*(h/2 - knob_bevel/2), 0, 0])
          rotate([0,90,0])
            cylinder(h=knob_bevel, r1=d/2, r2=(d/2)*0.92, center=true, $fn=sides);
      }
    }
}

// ---------- Assembly ----------
module assembly() {
  // Positions along rod X axis (rod centered at origin)
  x_block = -rod_L/2 + block_pos_from_end + block_L/2 - overlap;
  x_knob1 = -rod_L/2 + knob1_pos;
  x_knob2 = -rod_L/2 + knob2_pos;

  union() {
    // Main rod (faceted + twisted)
    twisted_faceted_rod();

    // Large rectangular block near one end, with chamfered vertical edges
    translate([x_block, 0, 0])
      chamfered_block([block_L, block_W, block_H], c=block_edge_chamfer);

    // Knob 1: centered on rod
    translate([x_knob1, 0, 0])
      faceted_knob(knob1_d, knob1_H, knob1_sides);

    // Knob 2: offset radially (Y) but still intersects rod for connectivity
    // Ensure it overlaps rod by at least 'overlap'
    translate([x_knob2, knob2_radial_offset, 0])
      faceted_knob(knob2_d, knob2_H, knob2_sides);

    // Small hidden connector rib to guarantee knob2 touches rod even if offset is large
    // (kept minimal; fully internal overlap)
    translate([x_knob2, knob2_radial_offset/2, 0])
      cube([knob2_H + 2*overlap, max(rod_W, rod_H) + knob2_radial_offset + 2*overlap, max(rod_W, rod_H)], center=true);
  }
}

assembly();
}
