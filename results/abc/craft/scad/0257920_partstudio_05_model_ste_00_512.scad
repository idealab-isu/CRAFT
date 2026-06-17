// Dimension-calibrated (target: 0.04 x 0.02 x 0.01 mm)
scale([0.978261, 1.050000, 1.300000])
{
// Clean, connected mounting block with symmetric through-hole pattern
// Units: meters (as in original). Keep geometry simple and readable.

$fn = 64;

// Parameters
L = 0.04; //[0.02:0.08:0.001]
W = 0.02; //[0.01:0.04:0.001]
T = 0.006; //[0.003:0.009:0.001]

overlap = 0.001; //[0.0005:0.002:0.0005]   // 1–2mm overlap for robust unions
ear_chamfer = 0.002; //[0.001:0.004:0.0005]

boss_d = 0.008; //[0.004:0.016:0.0005]
boss_h = 0.004; //[0.002:0.008:0.0005]
boss_facets = 8; //[6:16:1]

tab_L = 0.004; //[0.002:0.008:0.0005]
tab_W = 0.004; //[0.002:0.01:0.0005]
tab_T = 0.004; //[0.002:0.006:0.0005]

hole_d_small = 0.002; //[0.001:0.004:0.0005]
hole_teardrop_L = 0.003; //[0.0015:0.006:0.0005]
hole_teardrop_W = 0.002; //[0.001:0.004:0.0005]
diamond_across_flats = 0.004; //[0.002:0.008:0.0005]

hole_edge_margin = 0.002; //[0.001:0.004:0.0005]
hole_pitch_L = 0.01; //[0.005:0.02:0.0005]
hole_pitch_W = 0.008; //[0.004:0.016:0.0005]

micro_chamfer = 0.0005; //[0.0002:0.001:0.0001]
countersink_d = 0.003; //[0.002:0.006:0.0005]

// ---------- Helpers ----------
module ear_chamfer_cuts() {
  // subtract these from the plate to create chamfered corner ears
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*(L/2 - ear_chamfer), sy*(W/2 - ear_chamfer), 0])
      rotate([0, 0, 45])
        cube([ear_chamfer*2, ear_chamfer*2, T + 2*overlap], center=true);
  }
}

module teardrop_hole_2d(len, w) {
  // 2D teardrop-ish profile (circle + pointed end), extruded later
  // Oriented along +X.
  hull() {
    translate([-(len/2 - w/2), 0]) circle(r=w/2);
    translate([ +(len/2 - w/2), 0]) circle(r=w/2);
    // add a small point to make it more "teardrop" than capsule
    translate([len/2, 0]) circle(r=w/6);
  }
}

module through_holes() {
  // All holes are true through-holes (cut silhouettes visible in ortho views)
  union() {
    // Two diamond (rotated-square) apertures near center, symmetric in X
    for (sx = [-1, 1]) {
      translate([sx*hole_pitch_L/2, 0, 0])
        rotate([0, 0, 45])
          cube([diamond_across_flats, diamond_across_flats, T + 2*overlap], center=true);
    }

    // Four small round holes in a symmetric rectangle
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*hole_pitch_L/2, sy*hole_pitch_W/2, 0])
        cylinder(d=hole_d_small, h=T + 2*overlap, center=true);
    }

    // Two teardrop-like holes near the ends, symmetric in X
    // Keep them inside the plate footprint with edge margin.
    teardrop_x = (L/2 - hole_edge_margin - hole_teardrop_L/2);
    for (sx = [-1, 1]) {
      translate([sx*teardrop_x, 0, 0])
        linear_extrude(height=T + 2*overlap, center=true)
          rotate( sx < 0 ? 180 : 0 )  // point outward
            teardrop_hole_2d(hole_teardrop_L, hole_teardrop_W);
    }

    // Light countersink/chamfer on the four small round holes (both faces)
    for (sx = [-1, 1], sy = [-1, 1]) {
      // top face
      translate([sx*hole_pitch_L/2, sy*hole_pitch_W/2, +T/2 - micro_chamfer/2])
        cylinder(h=micro_chamfer, r1=countersink_d/2, r2=0, center=true);
      // bottom face
      translate([sx*hole_pitch_L/2, sy*hole_pitch_W/2, -T/2 + micro_chamfer/2])
        cylinder(h=micro_chamfer, r1=countersink_d/2, r2=0, center=true);
    }
  }
}

module plate_with_chamfered_ears() {
  difference() {
    cube([L, W, T], center=true);
    ear_chamfer_cuts();
  }
}

module end_tabs() {
  // Thin tab/rod-like extensions at both ends, connected with overlap
  // Place tabs centered in Y, and flush to bottom face of plate.
  tab_z = -T/2 + tab_T/2 - overlap; // overlap into plate
  for (sx = [-1, 1]) {
    tab_x = sx*(L/2 + tab_L/2 - overlap); // overlap into plate
    translate([tab_x, 0, tab_z])
      cube([tab_L, tab_W, tab_T], center=true);
  }
}

module faceted_boss() {
  // Central faceted cylindrical boss protruding from top face, connected with overlap
  boss_z = +T/2 + boss_h/2 - overlap; // overlap into plate
  translate([0, 0, boss_z])
    cylinder(d=boss_d, h=boss_h, center=true, $fn=boss_facets);
}

// ---------- Final ----------
module final_geometry() {
  difference() {
    union() {
      plate_with_chamfered_ears();
      end_tabs();
      faceted_boss();
    }
    through_holes();
  }
}

final_geometry();
}
