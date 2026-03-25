// Dimension-calibrated (target: 0.05 x 0.03 x 0.03 mm)
scale([1.060259, 1.033375, 0.833367])
{
// Rectangular prismatic block with clipped corners on top/bottom faces,
// centered THROUGH octagonal bore opening on the SMALL side faces (YZ faces),
// plus top recessed slot and four corner recesses.
//
// Structural fixes applied:
// - Ensure octagonal bore is truly through along X and visible on left/right faces
// - Ensure slot + 4 square recesses are on the TOP face (Z+), not on side faces
// - Robust boolean overlaps via eps; all features intersect the base solid

// Parameters (mm)  (kept as provided; note these are extremely small)
L = 0.05; //[0.025:0.1:0.001]
W = 0.03; //[0.015:0.06:0.001]
H = 0.03; //[0.015:0.06:0.001]

chamfer = 0.003; //[0.0015:0.006:0.0005]

bore_flat_d = 0.012; //[0.006:0.024:0.0005]   // across flats
slot_L = 0.038; //[0.019:0.076:0.001]
slot_W = 0.004; //[0.002:0.008:0.0005]
slot_depth = 0.0015; //[0.0005:0.003:0.00025]

sq_size = 0.004; //[0.002:0.008:0.0005]
sq_depth = 0.001; //[0.0005:0.002:0.00025]
sq_offset_x = 0.018; //[0.009:0.036:0.001]
sq_offset_y = 0.01; //[0.005:0.02:0.001]

// Use a tiny epsilon for robust booleans at this scale
eps = 0.0005; //[0.00025:0.002:0.00025]

$fn = 64;

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Regular octagon sized by across-flats (AF)
module octagon2d_by_af(af){
  n = 8;
  // AF = 2*apothem = 2*R*cos(180/n)  => R = AF/(2*cos(180/n))
  R = af / (2*cos(180/n));
  polygon(points=[ for(i=[0:n-1]) [ R*cos(360*i/n), R*sin(360*i/n) ] ]);
}

// Main block with clipped corners visible in top/bottom views
// Implemented as 2D corner cuts extruded through full height (Z)
module main_block_with_clipped_corners(){
  c = clamp(chamfer, 0, min(L,W)/2 - eps);

  linear_extrude(height=H, center=true)
    difference(){
      square([L, W], center=true);

      // Clip 4 corners (45°) on the large faces silhouette (XY)
      for (sx=[-1,1], sy=[-1,1])
        translate([sx*(L/2 - c/2), sy*(W/2 - c/2)])
          rotate(45)
            square([c, c], center=true);
    }
}

// Through octagonal bore centered on the smaller side faces (YZ faces).
// Axis along X so it opens on left/right faces; extend beyond body for clean cut.
module through_octagonal_bore(){
  // Extrude along X by rotating an XY-profile into YZ and extruding in Z
  // rotate([0,90,0]) makes linear_extrude's Z axis align with global X.
  rotate([0,90,0])
    linear_extrude(height=L + 2*eps, center=true)
      octagon2d_by_af(bore_flat_d);
}

// Top recessed long slot (subtract), running along length (X) on TOP face (Z+)
module top_recessed_long_slot(){
  d = clamp(slot_depth, 0, H - 2*eps);
  // Place so it cuts into the top surface only
  zc = (H/2) - (d/2) + eps;  // slight overlap into the solid
  translate([0, 0, zc])
    cube([clamp(slot_L, 0, L - 2*eps), clamp(slot_W, 0, W - 2*eps), d + 2*eps], center=true);
}

// Four top corner square recesses (subtract) on TOP face (Z+)
module four_top_corner_square_recesses(){
  d = clamp(sq_depth, 0, H - 2*eps);

  // Keep recesses inside the clipped-corner outline by staying away from edges
  ox = clamp(sq_offset_x, 0, L/2 - sq_size/2 - eps);
  oy = clamp(sq_offset_y, 0, W/2 - sq_size/2 - eps);

  zc = (H/2) - (d/2) + eps;  // slight overlap into the solid

  for (sx=[-1,1], sy=[-1,1])
    translate([sx*ox, sy*oy, zc])
      cube([sq_size, sq_size, d + 2*eps], center=true);
}

// Final solid (single connected body with subtracted features)
difference(){
  // Base solid (single connected body)
  main_block_with_clipped_corners();

  // Subtractive features
  through_octagonal_bore();
  top_recessed_long_slot();
  four_top_corner_square_recesses();
}
}
