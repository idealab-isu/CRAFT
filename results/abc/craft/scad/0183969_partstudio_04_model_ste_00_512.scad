// Dimension-calibrated (target: 0.04 x 0.03 x 0.16 mm)
scale([0.750413, 0.868549, 0.995031])
{
// Curved lightweighted strap/handle with 2 rectangular windows, end holes,
// chamfered/rounded ends, and a stepped/faceted reinforced midsection.
// Units: mm. One connected solid. Length along Z, thickness along Y.

$fn = 96;

// ---------------- Parameters ----------------
L = 0.16;                 // overall length (Z)
H = 0.03;                 // thickness (Y)
curve_sag = 0.006;        // lateral bow amount (X), peak at ends

body_w_end = 0.032;       // width at ends (X)
body_w_mid = 0.04;        // width at mid (X)

end_round_r = 0.006;      // end rounding radius
end_chamfer = 0.004;      // end chamfer depth (along Z)

hole_d = 0.006;           // end hole diameter
hole_end_offset = 0.014;  // hole offset from end along Z

win_len = 0.045;          // window length (Z)
win_w = 0.018;            // window width (X)
win_corner_r = 0.002;     // window corner radius
win_gap = 0.01;           // gap between windows (Z)

mid_step_len = 0.03;      // reinforced region length (Z)
mid_step_drop = 0.004;    // step amount (X,Y)
facet_count = 6;          // number of facets around midsection

eps = 0.0008;
overlap = 0.0015;         // small guaranteed overlap for robust connectivity

// ---------------- Derived placements ----------------
z_end_hole_pos =  L/2 - hole_end_offset;
z_end_hole_neg = -L/2 + hole_end_offset;

z_win_center_offset = (win_gap/2 + win_len/2);
z_win_pos =  z_win_center_offset;
z_win_neg = -z_win_center_offset;

// Keep windows fully inside ends and outside reinforced midsection
function clamp(v, a, b) = min(max(v, a), b);
z_win_limit = (L/2 - end_round_r - end_chamfer - win_len/2 - 2*eps);
z_win_pos_c = clamp(z_win_pos, -z_win_limit, z_win_limit);
z_win_neg_c = clamp(z_win_neg, -z_win_limit, z_win_limit);

// ---------------- Helpers ----------------
module rounded_rect_prism(size=[10,10,10], r=1, center=true) {
  // size = [X,Y,Z]
  x = size[0]; y = size[1]; z = size[2];
  rr = min(r, x/2 - eps, y/2 - eps);
  if (rr <= 0) {
    cube(size, center=center);
  } else {
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
      linear_extrude(height=z, center=true, convexity=10)
        offset(r=rr)
          square([x-2*rr, y-2*rr], center=true);
  }
}

// Bow function: 0 at center, +/-curve_sag at ends (smooth)
function bow_x(z) = curve_sag * (2*z/L);

// Cross-section slice at z (thin in Z), used for hulling
module strap_section(w, zpos) {
  translate([ bow_x(zpos), 0, zpos ])
    rounded_rect_prism(
      [w, H, eps],
      r=min(end_round_r*0.6, w/2-eps, H/2-eps),
      center=true
    );
}

module curved_tapered_body() {
  // Continuous elongated strap via hull of multiple sections
  hull() {
    strap_section(body_w_end, -L/2);
    strap_section(body_w_mid, -L/4);
    strap_section(body_w_mid,  0);
    strap_section(body_w_mid,  L/4);
    strap_section(body_w_end,  L/2);
  }
}

module end_rounding() {
  // Rounded caps blended into strap (ensure overlap into body)
  for (s = [-1, 1]) {
    z0 = s*(L/2 - end_round_r);
    hull() {
      translate([ bow_x(z0), 0, z0 ]) sphere(r=end_round_r);
      strap_section(body_w_end, s*(L/2 - 2*end_round_r - overlap));
    }
  }
}

module reinforced_midsection() {
  // Stepped reinforcement centered at Z=0
  union() {
    rounded_rect_prism(
      [body_w_mid + 2*mid_step_drop, H + mid_step_drop, mid_step_len + 2*overlap],
      r=min(end_round_r*0.55,
            (body_w_mid+2*mid_step_drop)/2-eps,
            (H+mid_step_drop)/2-eps),
      center=true
    );

    rounded_rect_prism(
      [body_w_mid - mid_step_drop, H + 2*mid_step_drop, mid_step_len*0.6 + 2*overlap],
      r=min(end_round_r*0.5,
            (body_w_mid-mid_step_drop)/2-eps,
            (H+2*mid_step_drop)/2-eps),
      center=true
    );
  }
}

module end_chamfer_cutters() {
  // Chamfer both ends with wedges that intersect the strap ends
  for (s = [-1, 1]) {
    zc = s*(L/2 - end_chamfer/2);
    translate([ bow_x(zc), 0, zc ])
      rotate([0, 45*s, 0])
        cube([body_w_mid*3, H*3, end_chamfer*3], center=true);
  }
}

module window_cutout(zc) {
  // Enclosed rectangular through-window (through Y)
  translate([ bow_x(zc), 0, zc ])
    rounded_rect_prism([win_w, H + 6*eps, win_len], r=win_corner_r, center=true);
}

module end_hole(zc) {
  // Through-hole along Y
  translate([ bow_x(zc), 0, zc ])
    rotate([90, 0, 0])
      cylinder(d=hole_d, h=H + 8*eps, center=true);
}

module facet_cutters() {
  // Facet only the midsection: cutters limited in Z to mid_step_len
  // IMPORTANT: these are SUBTRACTED, so they must be placed OUTSIDE and cut IN.
  // Use large blocks positioned beyond the outer radius so they shave flats.
  outer_r = (body_w_mid/2 + mid_step_drop + overlap);
  cut_w = body_w_mid*4;
  cut_h = (H + 6*mid_step_drop)*6;
  cut_z = mid_step_len*1.25 + 2*overlap;

  for (i = [0:facet_count-1]) {
    ang = i * 360/facet_count;
    rotate([0, 0, ang])
      translate([ outer_r + cut_w/2 - overlap, 0, 0 ])
        cube([cut_w, cut_h, cut_z], center=true);
  }
}

module main_solid() {
  // One continuous elongated strap + blended ends + connected reinforcement
  union() {
    curved_tapered_body();
    end_rounding();

    // Ensure reinforcement is fused to strap with explicit overlap hull
    hull() {
      reinforced_midsection();
      strap_section(body_w_mid, 0);
      // add two nearby sections to guarantee a continuous midspan silhouette
      strap_section(body_w_mid,  mid_step_len/2 - overlap);
      strap_section(body_w_mid, -mid_step_len/2 + overlap);
    }
  }
}

module final_part() {
  difference() {
    // Base + reinforcement, then chamfer ends and facet midsection
    difference() {
      difference() {
        main_solid();
        end_chamfer_cutters();
      }
      facet_cutters();
    }

    // Two enclosed rectangular through-windows along the length
    window_cutout(z_win_pos_c);
    window_cutout(z_win_neg_c);

    // Two small circular through-holes at ends (same continuous strap)
    end_hole(z_end_hole_pos);
    end_hole(z_end_hole_neg);
  }
}

// Final Output (upright, length along Z)
final_part();
}
