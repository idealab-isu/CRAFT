// IEC inlet (lugless) - ONE connected solid, no rear lugs.
// Structural fixes applied:
// - Ensure the model is an explicit single union() solid before cutting.
// - Rebuild/attach the small diagonal tab so it is guaranteed to intersect the main body
//   by 1-2mm even after rotation (use hull() between an anchor inside the body and the tab).
// - Provide the expected part/module name: iec (missing part fix).

type_lugless = 1; //[1:1:1]
include_screw_holes = 1; //[0:1:1]
include_spades_or_lugs = 0; //[0:0:1]
panel_mount = 1; //[1:1:1]
overlap = 1; //[0.5:2:0.1]

flange_w = 50; //[25:100:0.5]
flange_h = 28; //[14:56:0.5]
flange_t = 3; //[1.5:6:0.1]

bezel_w = 44; //[22:88:0.5]
bezel_h = 24; //[12:48:0.5]
bezel_t = 2; //[1:5:0.1]

body_w = 32; //[16:64:0.5]
body_h = 22; //[11:44:0.5]
body_depth_front = 14; //[7:28:0.5]
rear_body_depth = 18; //[9:36:0.5]

socket_w = 24.5; //[12.25:49:0.1]
socket_h = 16.34; //[8.17:32.68:0.1]
socket_corner_r = 3; //[1.5:6:0.1]
socket_offset_y = 0; //[-5:5:0.1]
orifice_cut_depth = 60; //[30:120:1]

screw_pitch_x = 40; //[20:80:0.5]
screw_pitch_y = 20; //[10:40:0.5]
screw_hole_d = 3.5; //[2:7:0.1]
screw_hole_cut_depth = 20; //[10:60:1]

$fn = 64;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rrect2d(w, h, r) {
  r2 = clamp(r, 0, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rrect3d(w, h, t, r) {
  linear_extrude(height=t, center=true) rrect2d(w, h, r);
}

module iec_lugless() {

  // Coordinate system:
  // Front face of flange is at z = 0.
  // Positive z goes outward (in front of panel), negative z goes inward (behind panel).

  z_flange = -flange_t/2; // flange spans z=[-flange_t, 0]

  // Bezel sits on the FRONT of flange, overlapping slightly to guarantee union connectivity.
  z_bezel  = (bezel_t/2) - overlap;

  // Body sits behind flange, overlapping slightly into flange to guarantee connectivity.
  z_body1  = -(flange_t + body_depth_front/2) + overlap;
  z_body2  = -(flange_t + body_depth_front + rear_body_depth/2) + overlap;

  body_total = body_depth_front + rear_body_depth;

  module outer_solid() {
    // Explicit single connected solid before cutting
    union() {
      // Flange
      translate([0, 0, z_flange])
        cube([flange_w, flange_h, flange_t], center=true);

      // Bezel (rounded)
      translate([0, 0, z_bezel])
        rrect3d(bezel_w, bezel_h, bezel_t, r=min(2, min(bezel_w, bezel_h)/6));

      // Front body
      translate([0, 0, z_body1])
        rrect3d(body_w, body_h, body_depth_front, r=min(1.5, min(body_w, body_h)/8));

      // Rear body (slightly smaller)
      rear_w = body_w * 0.96;
      rear_h = body_h * 0.96;
      translate([0, 0, z_body2])
        rrect3d(rear_w, rear_h, rear_body_depth, r=min(1.2, min(rear_w, rear_h)/8));

      // Side retention bumps (connected to body)
      bump_w = max(2.0, body_w*0.10);
      bump_h = max(6.0, body_h*0.55);
      bump_t = max(2.0, (body_depth_front + rear_body_depth)*0.18);

      // Place bumps around the mid of the combined body depth, slightly behind flange
      z_bump = -(flange_t + body_total*0.55);

      for (sx = [-1, 1]) {
        translate([sx*(body_w/2 + bump_w/2 - overlap), 0, z_bump])
          rrect3d(bump_w, bump_h, bump_t, r=min(1.0, bump_w/3));
      }

      // --- STRUCTURAL FIX: small diagonal tab/feature near the mid-slot ---
      // Guarantee physical attachment by hulling an "anchor" cube that is INSIDE the body
      // with the rotated tab cube. This removes any chance of a visible gap in side views.
      tab_len = max(6.0, body_w*0.28);     // along X
      tab_thk = max(2.0, body_h*0.12);     // along Y (thin)
      tab_dep = max(3.0, body_total*0.18); // along Z
      tab_ang = 25;                       // diagonal look

      // Place around the "mid-slot" region: slightly above center in Y, mid-depth in Z.
      y_tab = body_h*0.10;
      z_tab = -(flange_t + body_total*0.45);

      // Anchor is placed clearly inside the body by 1-2mm to ensure overlap.
      // (Using overlap*1.5 to be robust against rotation/boolean tolerances.)
      anchor_w = max(2.0, tab_len*0.22);
      anchor_h = max(2.0, tab_thk*1.6);
      anchor_d = max(2.0, tab_dep*0.70);

      // Anchor center: inside left side of body
      x_anchor = -(body_w/2 - anchor_w/2 - overlap*1.5);

      // Tab center: slightly outside, but will be connected via hull to anchor
      x_tab = -(body_w/2 - tab_len/2 + overlap*0.5);

      hull() {
        translate([x_anchor, y_tab, z_tab])
          cube([anchor_w, anchor_h, anchor_d], center=true);

        translate([x_tab, y_tab, z_tab])
          rotate([0, 0, tab_ang])
            cube([tab_len, tab_thk, tab_dep], center=true);
      }
    }
  }

  module inner_cuts() {
    union() {
      // Main socket orifice: starts at front face (z=0) and cuts inward.
      z_orifice = -(orifice_cut_depth/2) + overlap;
      translate([0, socket_offset_y, z_orifice])
        rrect3d(socket_w, socket_h, orifice_cut_depth, r=socket_corner_r);

      // Keying notches near top corners (small bites)
      notch_w = max(2.0, socket_w*0.18);
      notch_h = max(2.0, socket_h*0.18);
      notch_d = max(6.0, flange_t + bezel_t + 6);

      // Ensure notches start at front and go inward
      z_notch = -(notch_d/2) + overlap;
      y_top = socket_offset_y + socket_h/2 - notch_h/2;
      x_off = socket_w/2 - notch_w/2;

      for (sx = [-1, 1]) {
        translate([sx*x_off, y_top, z_notch])
          rotate([0, 0, sx*20])
            cube([notch_w, notch_h, notch_d], center=true);
      }

      if (include_screw_holes) {
        // Through holes: must pierce flange (and bezel if present).
        h_thru = max(screw_hole_cut_depth, flange_t + bezel_t + 2);
        z_thru = -flange_t/2; // centered in flange

        for (sx = [-1, 1], sy = [-1, 1]) {
          translate([sx*screw_pitch_x/2, sy*screw_pitch_y/2, z_thru])
            cylinder(d=screw_hole_d, h=h_thru, center=true);
        }

        // Countersink recess on FRONT face only (z near 0, going inward)
        cs_d = screw_hole_d * 2.0;
        cs_h = min(1.2, flange_t*0.6);

        // Place so top of countersink is at z=0 (front face)
        z_cs = -(cs_h/2) + overlap;

        for (sx = [-1, 1], sy = [-1, 1]) {
          translate([sx*screw_pitch_x/2, sy*screw_pitch_y/2, z_cs])
            cylinder(d1=cs_d, d2=screw_hole_d, h=cs_h, center=true);
        }
      }

      // Lugless: no rear lugs/spades modeled.
    }
  }

  difference() {
    outer_solid();
    inner_cuts();
  }
}

// Missing part fix: provide the expected top-level part/module name "iec"
module iec() { iec_lugless(); }

// Default render
iec();