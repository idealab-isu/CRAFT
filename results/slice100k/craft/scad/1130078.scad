// Corrected OpenSCAD model: flared V-plate with central ridge/crease, stepped side profiles,
// rectangular stem with through-hole near stem end. One connected solid.
// Bounding box target: 52.33 x 50.0 x 38.77 mm (X x Y x Z)

$fn = 96;

// Parameters
bbox_x = 52.33;
bbox_y = 50.0;
bbox_z = 38.77;

thickness_z = bbox_z;

v_len_x = 34.0;
v_width_wide_y = bbox_y;
v_width_narrow_y = 26.0;

stem_len_x = bbox_x - v_len_x;          // ensures overall X matches bbox_x
stem_width_y = 22.0;

transition_len_x = 6.0;
overlap = 0.6;

// Stepped side profile (creates prismatic detailing on the V-plate)
step1_depth_y = 3.0;
step2_depth_y = 6.0;
step1_start_x = 6.0;
step1_end_x   = v_len_x - 2.0;
step2_start_x = 14.0;
step2_end_x   = v_len_x - 4.0;

// Central ridge/crease on V-plate (raised rib)
ridge_height_z = 2.0;
ridge_base_width_y = 10.0;
ridge_len_x = v_len_x - 2.0;
ridge_start_x = 1.0;

// Hole
hole_d = 8.0;
hole_center_from_stem_end_x = 6.0;

// Small bottom corner notches near stem end (as seen in top view)
notch_w_y = 3.0;
notch_d_x = 2.0;
notch_h_z = 6.0;
stem_end_margin_x = 3.0;

// Small edge rounding (keep light to avoid distorting bbox too much)
chamfer_xy = 0.6;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module v_plate_2d() {
  polygon(points=[
    [0, -v_width_wide_y/2],
    [0,  v_width_wide_y/2],
    [v_len_x,  v_width_narrow_y/2],
    [v_len_x, -v_width_narrow_y/2]
  ]);
}

module stem_2d() {
  polygon(points=[
    [v_len_x, -stem_width_y/2],
    [v_len_x,  stem_width_y/2],
    [v_len_x + stem_len_x,  stem_width_y/2],
    [v_len_x + stem_len_x, -stem_width_y/2]
  ]);
}

module transition_2d() {
  // Blend from V-plate narrow end to stem width over transition_len_x
  polygon(points=[
    [v_len_x - transition_len_x, -v_width_narrow_y/2],
    [v_len_x - transition_len_x,  v_width_narrow_y/2],
    [v_len_x,  stem_width_y/2],
    [v_len_x, -stem_width_y/2]
  ]);
}

module base_body() {
  // Main prismatic body (V-plate + transition + stem), all connected
  linear_extrude(height=thickness_z, center=true)
    union() {
      v_plate_2d();
      transition_2d();
      stem_2d();
    }
}

module side_step_cut(depth_y, x0, x1) {
  // Cuts a "step" along both long sides of the V-plate region only
  // by removing a band near +/-Y edges between x0..x1.
  x0c = clamp(x0, 0, v_len_x);
  x1c = clamp(x1, 0, v_len_x);
  if (x1c > x0c)
    linear_extrude(height=thickness_z + 2*overlap, center=true)
      union() {
        // top band
        polygon(points=[
          [x0c,  bbox_y/2 - depth_y],
          [x1c,  bbox_y/2 - depth_y],
          [x1c,  bbox_y/2 + 0.01],
          [x0c,  bbox_y/2 + 0.01]
        ]);
        // bottom band
        polygon(points=[
          [x0c, -bbox_y/2 - 0.01],
          [x1c, -bbox_y/2 - 0.01],
          [x1c, -bbox_y/2 + depth_y],
          [x0c, -bbox_y/2 + depth_y]
        ]);
      }
}

module central_ridge() {
  // Raised triangular rib along the centerline of the V-plate
  translate([ridge_start_x, 0, thickness_z/2 - ridge_height_z/2])
    linear_extrude(height=ridge_height_z, center=true)
      polygon(points=[
        [0, -ridge_base_width_y/2],
        [0,  ridge_base_width_y/2],
        [ridge_len_x, 0]
      ]);
}

module through_hole() {
  // Hole near stem end
  hole_x = v_len_x + stem_len_x - hole_center_from_stem_end_x;
  translate([hole_x, 0, 0])
    cylinder(d=hole_d, h=thickness_z + 2*overlap, center=true);
}

module alignment_notch(sign_y=1) {
  // Small notch at bottom corner near stem end (two mirrored)
  notch_x = v_len_x + stem_len_x - stem_end_margin_x - notch_d_x/2;
  notch_y = sign_y*(stem_width_y/2 - notch_w_y/2);
  notch_z = -thickness_z/2 + notch_h_z/2;
  translate([notch_x, notch_y, notch_z])
    cube([notch_d_x, notch_w_y, notch_h_z], center=true);
}

// ---------- Build ----------
module part_raw() {
  difference() {
    union() {
      base_body();
      central_ridge();
    }

    // Stepped side profiles (two levels) on V-plate
    side_step_cut(step1_depth_y, step1_start_x, step1_end_x);
    side_step_cut(step2_depth_y, step2_start_x, step2_end_x);

    // Hole
    through_hole();

    // Notches
    alignment_notch( 1);
    alignment_notch(-1);
  }
}

// Light rounding without breaking connectivity
minkowski() {
  part_raw();
  sphere(r=chamfer_xy);
}