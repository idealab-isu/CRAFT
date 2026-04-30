// Folding whip RF antenna module (mm)
// Clean, self-contained  generated from provided JSON plan + sketch-grounded dimensions.

$fn=32;

// -------------------------
// Parameters (from plan JSON)
// -------------------------
L_total = 108.5; //[54.25:217:0.1]
D_base = 9.5; //[4.75:19:0.1]
D_tip = 7.9; //[3.95:15.8:0.1]
L_fixed = 20.6; //[10.3:41.2:0.1]
pivot_from_base = 20.6; //[10.3:41.2:0.1]
panel_gap = 6.45; //[3.225:12.9:0.05]
pivot_axis_D = 2.5; //[1.25:5:0.05]
hinge_body_L = 8; //[4:16:0.1]
hinge_body_D = 10.5; //[5.25:21:0.1]
overlap = 1; //[0.5:2:0.1]
washer_OD = 14.5; //[7.25:29:0.1]
washer_thk = 1.6; //[0.8:3.2:0.05]
nut_AF = 12; //[6:24:0.1]
nut_thk = 4.5; //[2.25:9:0.1]
base_post_L = 30; //[15:60:0.1]

// -------------------------
// Derived helpers
// -------------------------
eps = 0.01;

module _hex_prism(af=12, h=4.5, center=true) {
  // Regular hex with across-flats = af
  r = af / sqrt(3);
  cylinder(h=h, r=r, $fn=6, center=center);
}

module _washer(od=14.5, id=2.7, thk=1.6) {
  color([0.75, 0.75, 0.77])  // aluminum-ish
  difference() {
    cylinder(h=thk, r=od/2, center=true);
    cylinder(h=thk + 2*eps, r=id/2, center=true);
  }
}

module _nut(af=12, thk=4.5, hole_d=2.7) {
  color([0.4, 0.4, 0.43])  // steel-ish
  difference() {
    _hex_prism(af=af, h=thk, center=true);
    cylinder(h=thk + 2*eps, r=hole_d/2, center=true, $fn=32);
  }
}

module _whip_fixed_section() {
  color([0.15, 0.15, 0.17])  // black anodized look
  translate([0, 0, L_fixed/2])
    cylinder(h=L_fixed, r=D_base/2, center=true);
}

module _whip_tapered_section() {
  // Taper from base diameter to tip diameter over remaining length
  color([0.15, 0.15, 0.17])
  translate([0, 0, L_fixed + (L_total - L_fixed)/2 - overlap])
    cylinder(h=(L_total - L_fixed), r1=D_base/2, r2=D_tip/2, center=true);
}

module _panel_gap_spacer_region() {
  // Spacer region near base (same OD as base)
  color([0.2, 0.2, 0.22])
  translate([0, 0, panel_gap/2])
    cylinder(h=panel_gap, r=D_base/2, center=true);
}

module _base_post() {
  // Below panel: simplified post (thread not modeled; sketch shows threads but plan says simplified)
  color([0.15, 0.15, 0.17])
  translate([0, 0, -base_post_L/2 + overlap])
    cylinder(h=base_post_L, r=D_base/2, center=true);
}

module _hinge_knuckle_detail() {
  // Knuckle cylinder oriented along X at pivot location
  color([0.12, 0.12, 0.14])
  translate([0, 0, pivot_from_base])
    rotate([0, 90, 0])
      difference() {
        cylinder(h=hinge_body_L, r=hinge_body_D/2, center=true);
        // pivot bore
        cylinder(h=hinge_body_L + 2*eps, r=pivot_axis_D/2, center=true, $fn=32);
      }
}

module _pivot_hinge_axis() {
  // Pin through knuckle (visible)
  color([0.75, 0.75, 0.77])
  translate([0, 0, pivot_from_base])
    rotate([0, 90, 0])
      cylinder(h=hinge_body_L + 2*overlap, r=pivot_axis_D/2, center=true, $fn=32);
}

module _fasteners_stack() {
  // Washer + nut above panel gap (simplified but recognizable)
  // Place centered on Z like plan; use pivot_axis_D as through-hole proxy.
  translate([0, 0, panel_gap + washer_thk/2 - overlap])
    _washer(od=washer_OD, id=pivot_axis_D + 0.2, thk=washer_thk);

  translate([0, 0, panel_gap + washer_thk + nut_thk/2 - overlap])
    _nut(af=nut_AF, thk=nut_thk, hole_d=pivot_axis_D + 0.2);
}

// -------------------------
// Base shapes (as modules for clarity)
// -------------------------
module bs_fixed_straight_section() { _whip_fixed_section(); }
module bs_whip_body_tapered() { _whip_tapered_section(); }
module bs_panel_gap_spacer_region() { _panel_gap_spacer_region(); }
module bs_base_post() { _base_post(); }
module bs_washer() {
  translate([0, 0, panel_gap + washer_thk/2 - overlap])
    _washer(od=washer_OD, id=pivot_axis_D + 0.2, thk=washer_thk);
}
module bs_nut_proxy() {
  // Use hex nut instead of box proxy for realism (still matches plan intent)
  translate([0, 0, panel_gap + washer_thk + nut_thk/2 - overlap])
    _nut(af=nut_AF, thk=nut_thk, hole_d=pivot_axis_D + 0.2);
}
module bs_hinge_knuckle_detail() { _hinge_knuckle_detail(); }
module bs_pivot_hinge_axis() { _pivot_hinge_axis(); }

// -------------------------
// Operations (per plan sequence)
// -------------------------
module op_union_whip_and_base() {
  union() {
    bs_fixed_straight_section();
    bs_whip_body_tapered();
    bs_panel_gap_spacer_region();
    bs_base_post();
  }
}

module op_union_hinge() {
  union() {
    bs_hinge_knuckle_detail();
    bs_pivot_hinge_axis();
  }
}

module op_union_fasteners() {
  union() {
    bs_washer();
    bs_nut_proxy();
  }
}

module op_union_complete_model() {
  union() {
    op_union_whip_and_base();
    op_union_hinge();
    op_union_fasteners();
  }
}

// -------------------------
// Final output
// -------------------------
op_union_complete_model();