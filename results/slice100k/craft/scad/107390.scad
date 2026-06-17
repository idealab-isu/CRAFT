// Dimension-calibrated (target: 3.00 x 1.20 x 9.00 mm)
scale([0.982054, 1.599796, 0.124896])
{
// Curved C-shaped clamp/brace segment with faceted outer surface and concave inner channel
// Target bounding box: 3.0 x 1.2 x 9.0 mm (X x Y x Z), elongated along Z

$fn = 96;

// Parameters (kept from prompt, but geometry rebuilt to be connected and correctly oriented)
bbox_L = 9.0;   // Z length
bbox_W = 3.0;   // X width
bbox_H = 1.2;   // Y thickness

arc_angle_deg = 220.0;

wall_t = 0.45;
channel_R = 1.05;
channel_depth = 0.55;

tab_len = 0.9;
tab_thick_extra = 0.15;

facet_count = 10;
facet_radial_extra = 0.25;

chamfer_r = 0.12;
notch_r = 0.18;
notch_z = 0.35;
texture_r = 0.08;

overlap = 0.6;

// Derived dimensions to hit bbox_W in X
R_in  = channel_R;
R_out = R_in + wall_t;
R_mid = (R_in + R_out) / 2;

// Ensure outer diameter fits bbox_W (X): 2*(R_out + facet_radial_extra) ~= bbox_W
// If parameters don't match perfectly, we scale X slightly to enforce bbox_W.
scale_x = bbox_W / (2 * (R_out + facet_radial_extra));
scale_y = 1; // thickness already bbox_H
scale_z = 1; // length already bbox_L

// --- Helpers ---
module ring_arc_2d(Ro, Ri, ang) {
  // 2D annular sector in XY plane, centered at origin, spanning angle "ang" about +X axis
  difference() {
    circle(r = Ro);
    circle(r = Ri);
    // Keep only sector: intersection with wedge polygon
    // Build a large wedge that covers [-ang/2, +ang/2]
    intersection() {
      // annulus already present via difference above, so just wedge here
      polygon(points = concat([[0,0]],
        [for (a = [-ang/2 : 2 : ang/2]) [ (Ro+5)*cos(a), (Ro+5)*sin(a) ]],
        [[0,0]]
      ));
    }
  }
}

module clamp_body() {
  // Extrude along Z to make the elongated clamp segment
  linear_extrude(height = bbox_L, center = true, convexity = 10)
    ring_arc_2d(R_out + facet_radial_extra, R_in, arc_angle_deg);
}

module inner_channel_cut() {
  // Concave inner channel: remove a slightly deeper arc from the inside
  // Depth is radial: cut from R_in outward by channel_depth (clamped)
  cut_Ro = R_in + min(channel_depth, max(0.01, (R_out - R_in) + facet_radial_extra));
  linear_extrude(height = bbox_L + 2*overlap, center = true, convexity = 10)
    ring_arc_2d(cut_Ro, 0, arc_angle_deg);
}

module end_tabs() {
  // Two squared-off end tabs at the arc ends, connected by overlap into the arc
  // Place at the two end angles, at radius ~R_mid, extruded as boxes along Z
  for (sgn = [-1, 1]) {
    a = sgn * arc_angle_deg/2;
    // Position at arc end, slightly pushed outward to ensure overlap with arc body
    px = (R_mid) * cos(a);
    py = (R_mid) * sin(a);

    // Tab main
    translate([px, py, sgn*(bbox_L/2 - tab_len/2 + overlap/2)])
      rotate([0, 0, a])
        cube([bbox_W, bbox_H, tab_len], center = true);

    // Slight thickening step on the outside face (adds thickness in +Y local)
    translate([px, py, sgn*(bbox_L/2 - tab_len/2 + overlap/2)])
      rotate([0, 0, a])
        translate([0, tab_thick_extra/2, 0])
          cube([bbox_W, tab_thick_extra, tab_len], center = true);
  }
}

module outer_facets_cut() {
  // Create faceted outer surface by subtracting rotated half-planes (as thin boxes)
  // around the outside radius. This yields a polygonal outer arc.
  for (i = [0:facet_count-1]) {
    a = -arc_angle_deg/2 + (i + 0.5) * (arc_angle_deg / facet_count);
    // Place cutter at outer radius, oriented radially
    translate([0, 0, 0])
      rotate([0, 0, a])
        translate([R_out + facet_radial_extra + bbox_W, 0, 0])
          cube([2*bbox_W, 4*(R_out + facet_radial_extra + bbox_W), bbox_L + 2*overlap], center = true);
  }
}

module small_edge_chamfers_cut() {
  // Simple chamfer approximation: subtract small cylinders at 4 long edges (Z edges)
  // Positioned near outer corners of the bounding box.
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*(bbox_W/2 - chamfer_r), sy*(bbox_H/2 - chamfer_r), 0])
      rotate([0, 90, 0])
        cylinder(r = chamfer_r, h = bbox_W + 2*overlap, center = true);
  }
}

module tiny_inner_relief_notches_cut() {
  // Two small notches near the ends, cut into the inner channel region
  // Place near inner radius at mid-angle (0 deg), mirrored in Z.
  for (sz = [-1, 1]) {
    translate([R_in - notch_r*0.6, 0, sz*(bbox_L/2 - tab_len - notch_z)])
      rotate([90, 0, 0])
        cylinder(r = notch_r, h = bbox_H + 2*overlap, center = true);
  }
}

module surface_texture_bumps() {
  // Small bumps on the outer surface (additive)
  // Place on outer radius at a few Z positions.
  for (zpos = [0, -bbox_L/4, bbox_L/4]) {
    translate([(R_out + facet_radial_extra - texture_r*0.2), 0, zpos])
      sphere(r = texture_r);
  }
}

// --- Final model ---
module final_model() {
  // Build connected solid, then enforce bbox_W via X scaling
  scale([scale_x, scale_y, scale_z])
  difference() {
    union() {
      difference() {
        // Main arc body
        clamp_body();

        // Inner concave channel
        inner_channel_cut();

        // Facet cuts on outer surface
        outer_facets_cut();
      }

      // End tabs (connected)
      end_tabs();

      // Small surface bumps/markings
      surface_texture_bumps();
    }

    // Minor chamfers and relief notches
    small_edge_chamfers_cut();
    tiny_inner_relief_notches_cut();
  }
}

final_model();
}
