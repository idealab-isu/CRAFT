// Dimension-calibrated (target: 10.00 x 18.00 x 6.35 mm)
scale([1.014095, 1.000038, 0.635024])
{
// Push-in clip / rivet style fastener with split V-fork prongs
// Target bounding box: ~10.0 (Y) x 18.0 (X) x 6.3 (Z) mm, elongated along X
$fn = 96;

// ---------- Parameters ----------
L_total = 18.0;
W_max   = 10.0;
H_max   = 6.30;

head_d  = 10.0;
head_t  = 2.40;

shank_d = 4.20;
shank_L = 9.60;

transition_L = 1.20;

prong_L   = 6.00;
prong_thk = 6.30;   // Z thickness of prong region (matches H_max)
prong_w   = 3.60;   // each prong half-width in Y

gap_root = 0.80;
gap_tip  = 2.60;

tip_chamfer_L = 1.20;
relief_r = 0.55;

overlap = 0.60;

head_edge_round_r = 0.35;

// ---------- Derived placement along X ----------
x0 = -L_total/2;

x_head_c = x0 + head_t/2;

x_shank_start = x0 + head_t;
x_shank_end   = x_shank_start + shank_L;

x_tr_start = x_shank_end;
x_tr_end   = x_tr_start + transition_L;

x_pr_start = x_tr_end;
x_pr_end   = x_pr_start + prong_L;

// ---------- Helpers ----------
module flange_head() {
  // Slightly rounded head edge without changing overall envelope much
  translate([x_head_c, 0, 0])
    rotate([0, 90, 0])
      minkowski() {
        cylinder(r=head_d/2 - head_edge_round_r, h=head_t, center=true);
        sphere(r=head_edge_round_r);
      }
}

module cylindrical_shank() {
  translate([(x_shank_start + x_shank_end)/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=shank_d/2, h=shank_L + overlap, center=true);
}

module shank_to_prong_transition() {
  // Taper from shank to prong thickness envelope (keeps connection smooth)
  r2 = max(prong_thk/2 * 0.35, 0.8);
  translate([(x_tr_start + x_tr_end)/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=shank_d/2, r2=r2, h=transition_L + overlap, center=true);
}

module prongs_envelope() {
  // Full prong region envelope; will be split by V-slot and shaped by chamfers
  translate([(x_pr_start + x_pr_end)/2, 0, 0])
    cube([prong_L + overlap, min(W_max, 2*prong_w + gap_tip), prong_thk], center=true);
}

module v_slot_gap() {
  // True V-shaped split (in X-Y), extruded through Z thickness
  // Root at x_pr_start, tip at x_pr_end
  translate([x_pr_start - overlap/2, 0, 0])
    linear_extrude(height=prong_thk + 2*overlap, center=true)
      polygon(points=[
        [0,        -gap_root/2],
        [0,         gap_root/2],
        [prong_L,   gap_tip/2],
        [prong_L,  -gap_tip/2]
      ]);
}

module tip_wedge_chamfers() {
  // Create opposing wedge/chamfered tips so each prong tapers toward the end.
  // Two wedges remove material from the outer sides near the tip.
  y_env = min(W_max, 2*prong_w + gap_tip);
  x_cut = x_pr_end - tip_chamfer_L;

  for (s = [-1, 1]) {
    translate([x_cut - overlap, s*(y_env/2), 0])
      rotate([0, 0, s*0])
        linear_extrude(height=prong_thk + 2*overlap, center=true)
          polygon(points=[
            [0, 0],
            [tip_chamfer_L + 2*overlap, 0],
            [tip_chamfer_L + 2*overlap, -s*(y_env/2 + 2*overlap)],
            [0, -s*(y_env/2 + 2*overlap)]
          ]);
  }
}

module relief_notches() {
  // Small circular reliefs at the split root to encourage flex
  x_rel = x_pr_start + relief_r;
  for (s = [-1, 1]) {
    translate([x_rel, s*(gap_root/2 + relief_r), 0])
      rotate([0, 90, 0])
        cylinder(r=relief_r, h=shank_d + 2*overlap, center=true);
  }
}

module prongs_forked() {
  difference() {
    prongs_envelope();
    v_slot_gap();
    tip_wedge_chamfers();
    relief_notches();
  }
}

// ---------- Final assembly (one connected solid) ----------
union() {
  flange_head();
  cylindrical_shank();
  shank_to_prong_transition();
  prongs_forked();
}
}
