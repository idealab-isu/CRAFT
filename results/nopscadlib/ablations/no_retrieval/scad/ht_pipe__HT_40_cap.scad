// HT 40 pipe cap (socketed, closed end) — structural fix
// Goal: recognizable HT40 cap: closed end + open socket + wall thickness + slight outer step/lip.
// Single connected solid. All translate() values are formula-based. Clean geometry.

$fn = 128;

// -------------------- Parameters (simplified) --------------------
pipe_od = 40;                 // nominal HT40 pipe OD (simplified)
socket_id_clearance = 0.6;    // clearance so pipe can slide in
wall_thk = 2.6;               // cap wall thickness (radial)
cap_length = 45;              // overall length
socket_depth = 30;            // depth of socket cavity from open end
end_thk = 4.0;                // thickness of the closed end
chamfer_len = 2.0;            // lead-in chamfer length at opening
cap_od_extra = 6.0;           // extra OD over pipe OD (fitting bulk)
stop_lip = 1.5;               // radial inward step at socket bottom (internal stop)

// Robust boolean overlaps
eps = 0.02;
overlap = 1.5;                // 1–2mm overlap for reliable unions/differences

// -------------------- Derived dimensions --------------------
cap_or    = (pipe_od + cap_od_extra) / 2;
socket_ir = (pipe_od + socket_id_clearance) / 2;

// Ensure the outer wall is at least wall_thk around the socket
cap_or_eff = max(cap_or, socket_ir + wall_thk);

// Clamp lengths so the cavity never breaks through the closed end
cap_length_eff   = max(cap_length, end_thk + 2);
socket_depth_eff = min(socket_depth, cap_length_eff - end_thk);
socket_depth_eff = max(0, socket_depth_eff);

chamfer_len_eff = min(chamfer_len, socket_depth_eff);
chamfer_len_eff = max(0, chamfer_len_eff);

// Internal stop ring thickness (axial)
stop_axial_thk = min(2.5, max(1.2, socket_depth_eff/8));
stop_axial_thk = min(stop_axial_thk, socket_depth_eff);

// Z references (cap centered at z=0)
z_open   = -cap_length_eff/2;
z_closed =  cap_length_eff/2;

// -------------------- Geometry modules --------------------
module cap_outer_body() {
  // Outer body: simple cylinder (fitting bulk)
  cylinder(h = cap_length_eff, r = cap_or_eff, center = true);
}

module internal_cavity() {
  // Hollow socket: open at z_open, stops before closed end.
  // Use explicit z extents to guarantee it doesn't accidentally cut through.
  z_cav_start = z_open - overlap/2;                 // slightly beyond open face
  z_cav_end   = z_open + socket_depth_eff;          // socket bottom plane
  cav_h       = max(0, (z_cav_end - z_cav_start) + overlap);

  union() {
    // Straight bore
    if (socket_depth_eff > 0)
      translate([0, 0, (z_cav_start + z_cav_end)/2])
        cylinder(h = cav_h, r = socket_ir, center = true);

    // Lead-in chamfer at opening (wider at the very opening)
    if (chamfer_len_eff > 0) {
      z_ch_start = z_open - overlap/2;
      z_ch_end   = z_open + chamfer_len_eff;
      ch_h       = (z_ch_end - z_ch_start) + overlap;

      translate([0, 0, (z_ch_start + z_ch_end)/2])
        cylinder(h = ch_h,
                 r1 = socket_ir + chamfer_len_eff,
                 r2 = socket_ir,
                 center = true);
    }
  }
}

module internal_stop_lip() {
  // Add an internal stop as solid material intruding into the socket near its bottom.
  // This is added AFTER hollowing, so it remains as a connected feature.
  if (socket_depth_eff > 0 && stop_lip > 0 && stop_axial_thk > 0) {
    z_stop_center = z_open + socket_depth_eff - stop_axial_thk/2;

    // Ring that occupies the annulus between (socket_ir - stop_lip) and socket_ir
    translate([0, 0, z_stop_center])
      difference() {
        cylinder(h = stop_axial_thk + overlap, r = socket_ir, center = true);
        cylinder(h = stop_axial_thk + overlap + 0.5, r = max(0.1, socket_ir - stop_lip), center = true);
      }
  }
}

module outer_lip_step() {
  // Slight outer lip/step near the opening, typical of caps/fittings.
  // Kept simple and connected with a small overlap into the main body.
  lip_h = min(6, cap_length_eff/4);
  lip_h = max(2.5, lip_h);

  lip_radial = 1.2; // subtle step
  r_lip = cap_or_eff + lip_radial;

  // Place at open end, overlapping into the body
  z_lip_center = z_open + lip_h/2 - overlap/2;

  translate([0, 0, z_lip_center])
    cylinder(h = lip_h + overlap, r = r_lip, center = true);
}

// -------------------- Main cap --------------------
module ht40_cap() {
  union() {
    // Outer body + outer lip, then hollow out socket, then add internal stop
    difference() {
      union() {
        cap_outer_body();
        outer_lip_step();
      }
      internal_cavity();
    }
    internal_stop_lip();
  }
}

ht40_cap();