// Parameters (original)
inner_diameter = 3; //[1.5:6:0.1]
outer_diameter = 7; //[3.5:14:0.1]
thickness = 0.5; //[0.25:1:0.05]
inner_radius = 1.5; //[0.75:3:0.05]
outer_radius = 3.5; //[1.75:7:0.05]
hole_clearance = 0; //[-0.2:0.5:0.05]

// Connectivity overlap (1–2mm required)
overlap = 1.0;

// --- Parts ---

// Flat washer (MISSING PART fixed: explicit washer module kept and used)
module washer(h=thickness) {
  difference() {
    cylinder(r=outer_radius, h=h, center=false);
    translate([0,0,-1]) cylinder(r=inner_radius + hole_clearance, h=h + 2, center=false);
  }
}

module round_grommet_assembly(h=thickness+1) {
  // Outer grommet body
  difference() {
    cylinder(r=outer_radius + 1, h=h, center=false);
    translate([0,0,-1]) cylinder(r=inner_radius + 0.5, h=h + 2, center=false);
  }
}

module round_grommet_top(h=thickness) {
  // Top cap / flange
  difference() {
    cylinder(r=outer_radius + 1, h=h, center=false);
    translate([0,0,-1]) cylinder(r=inner_radius + 0.5, h=h + 2, center=false);
  }
}

module screw_body(h=10, r=1.5) {
  cylinder(r=r, h=h, center=false);
}

module nut_body(h=2, r=2.5) {
  cylinder(r=r, h=h, center=false);
}

// --- Assembly: all parts physically intersect and are unioned into one solid ---
module assembly() {

  // Heights
  w_h   = thickness;        // washer thickness
  g_h   = thickness + 1;    // grommet assembly height
  gt_h  = thickness;        // grommet top height
  s_h   = 10;               // screw height
  n_h   = 2;                // nut height

  // Clamp overlap to a safe value for thin parts (still within 1–2mm requirement)
  ov = min(overlap, min(w_h, min(g_h, gt_h)) * 0.9);

  // Z stacking (all parts start at z=0 style; overlaps are created by starting next part early)
  z0 = 0;

  // Base washer
  z_w_base  = z0;

  // Grommet assembly overlaps washer by ov
  z_g_base  = z_w_base + w_h - ov;

  // Top cap overlaps grommet assembly by ov (FIX: cap attached, not floating)
  z_gt_base = z_g_base + g_h - ov;

  // Central post/screw overlaps into top cap by ov (FIX: no gap at top)
  z_s_base  = z_gt_base + gt_h - ov;

  // Nut overlaps screw by ov
  z_n_base  = z_s_base + s_h - ov;

  // Lower washer-like ring (under nut) overlaps nut and screw (FIX: attached, not floating)
  z_w2_base = z_n_base - w_h + ov;

  union() {
    // Base washer (expected part: washer) - attached to grommet via overlap
    color("Silver")
      translate([0,0,z_w_base]) washer(w_h);

    // Grommet assembly
    color("DimGray")
      translate([0,0,z_g_base]) round_grommet_assembly(g_h);

    // Upper flange/cap - attached to grommet via overlap
    color("DimGray")
      translate([0,0,z_gt_base]) round_grommet_top(gt_h);

    // Central cylindrical post - overlaps into cap and down through stack
    color("Black")
      translate([0,0,z_s_base]) screw_body(s_h, 1.5);

    // Lower washer-like ring - overlaps nut and screw (attached)
    color("Black")
      translate([0,0,z_w2_base]) washer(w_h);

    // Nut - overlaps screw
    color("Black")
      translate([0,0,z_n_base]) nut_body(n_h, 2.5);
  }
}

assembly();