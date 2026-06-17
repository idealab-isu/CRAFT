// Dimension-calibrated (target: 0.05 x 0.03 x 0.03 mm)
scale([1.039314, 1.000155, 0.806577])
{
// Rectangular prismatic block with clipped (chamfered) corners on top/bottom faces,
// centered through octagonal bore (opens on the smaller side faces), top recessed slot + 4 corner recesses.

// ---------------- Parameters (mm) ----------------
L = 0.05; //[0.025:0.1:0.001]
W = 0.03; //[0.015:0.06:0.001]
H = 0.03; //[0.015:0.06:0.001]

chamfer = 0.003; //[0.0015:0.006:0.0005]   // corner clip size on top/bottom faces

bore_flat_d = 0.016; //[0.008:0.032:0.001] // across flats (octagon)
bore_lead_in = 0.001; //[0.0005:0.002:0.00025]
bore_lead_scale = 1.15; //[1.05:1.4:0.01]

slot_L = 0.04; //[0.02:0.08:0.001]
slot_W = 0.004; //[0.002:0.008:0.0005]
slot_depth = 0.0015; //[0.0005:0.003:0.00025]

corner_feat_size = 0.004; //[0.002:0.008:0.0005]
corner_feat_depth = 0.001; //[0.0005:0.002:0.00025]
corner_feat_offset_x = 0.006; //[0.003:0.012:0.0005]
corner_feat_offset_y = 0.006; //[0.003:0.012:0.0005]

edge_fillet_r = 0.0005; //[0.0:0.0015:0.00025]

// Robust overlap for booleans (small relative to part, but ensures clean cuts)
eps = 0.001; //[0.0002:0.002:0.0001]

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// keep features valid
ch  = clamp(chamfer, 0, min(L, W)/2 - eps);

sfL = clamp(slot_L, eps, L - 2*eps);
sfW = clamp(slot_W, eps, W - 2*eps);
sd  = clamp(slot_depth, eps, H/2 - eps);

cfS = clamp(corner_feat_size, eps, min(L, W)/2 - eps);
cfD = clamp(corner_feat_depth, eps, H/2 - eps);
cfx = clamp(corner_feat_offset_x, cfS/2 + eps, L/2 - cfS/2 - eps);
cfy = clamp(corner_feat_offset_y, cfS/2 + eps, W/2 - cfS/2 - eps);

efr = clamp(edge_fillet_r, 0, min(L, W, H)/10);

// Regular octagon points for given across-flats dimension (flat-to-flat)
module octagon2d(af) {
  // For a regular octagon: across-flats = 2 * R * cos(22.5°)
  R = af / (2 * cos(22.5));
  polygon(points=[ for (i=[0:7]) [ R*cos(22.5 + i*45), R*sin(22.5 + i*45) ] ]);
}

// ---------------- Base body with clipped corners on top/bottom faces ----------------
module body_with_face_corner_clips() {
  // Clip corners on the large faces by subtracting corner prisms that extend through full thickness.
  difference() {
    cube([L, W, H], center=true);

    // Corner clips: place triangles at each XY corner and extrude through full thickness.
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*(L/2 - ch), sy*(W/2 - ch), 0])
        scale([sx, sy, 1])
          linear_extrude(height=H + 4*eps, center=true)
            polygon(points=[[0,0],[ch,0],[0,ch]]);
    }
  }
}

// ---------------- Through octagonal bore (ALONG Y, opens on smaller side faces) ----------------
module through_oct_bore_with_leads() {
  // The bore must open on the smaller side faces (the XZ faces), so it runs along Y.
  // Extrude longer than W to guarantee a clean through-cut.
  union() {
    // Main through bore
    rotate([90,0,0])  // make extrusion axis = Y
      linear_extrude(height=W + 6*eps, center=true)
        octagon2d(bore_flat_d);

    // Lead-in at +Y end (slightly larger)
    rotate([90,0,0])
      translate([0, (W/2 - bore_lead_in/2), 0])
        linear_extrude(height=bore_lead_in + 6*eps, center=true)
          octagon2d(bore_flat_d * bore_lead_scale);

    // Lead-in at -Y end (slightly larger)
    rotate([90,0,0])
      translate([0, -(W/2 - bore_lead_in/2), 0])
        linear_extrude(height=bore_lead_in + 6*eps, center=true)
          octagon2d(bore_flat_d * bore_lead_scale);
  }
}

// ---------------- Top surface recess features (on +Z face) ----------------
module top_slot_recess() {
  // Cut from the top face downward; extend slightly above the face for reliable subtraction.
  translate([0, 0, H/2 - sd/2])
    cube([sfL, sfW, sd + 6*eps], center=true);
}

module top_corner_square_recesses() {
  for (sx=[-1,1], sy=[-1,1]) {
    translate([sx*(L/2 - cfx), sy*(W/2 - cfy), H/2 - cfD/2])
      cube([cfS, cfS, cfD + 6*eps], center=true);
  }
}

// ---------------- Final geometry (one connected solid) ----------------
module part_core() {
  difference() {
    body_with_face_corner_clips();

    // Subtractive features
    through_oct_bore_with_leads();   // now correctly opens on the smaller side faces
    top_slot_recess();
    top_corner_square_recesses();
  }
}

if (efr > 0) {
  // Rounded edges via Minkowski; keep as one connected solid.
  minkowski() {
    part_core();
    sphere(r=efr, $fn=32);
  }
} else {
  part_core();
}
}
