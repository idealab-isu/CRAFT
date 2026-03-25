// Dimension-calibrated (target: 0.01 x 0.01 x 0.00 mm)
scale([1.078479, 0.125009, 7.504120])
{
// Short thick cylindrical sleeve/cap-like solid with slightly chamfered end edges,
// a visible shallow circumferential groove near one end, and an asymmetric rectangular lug
// with a small notch cutout. One connected solid.

$fn = 128;

// --- Parameters (meters as given; keep as-is) ---
body_d = 0.008;          // outer diameter
body_h = 0.0020;         // overall height (slightly more plate-like)

wall_t = 0.0007;         // sleeve wall thickness
cap_floor = 0.00035;     // closed-end floor thickness (cap-like)

edge_chamfer = 0.00018;  // small chamfer on outer end edges

// Groove (external circumferential)
groove_depth = 0.00025;               // radial depth into outer surface
groove_w = 0.0007;                    // axial width
groove_offset_from_open_end = 0.00055;// from open end (-Z) to groove center

// Lug
lug_l = 0.0042;         // length outward from cylinder (X)
lug_w = 0.0030;         // width (Y)
lug_h = body_h;         // match body height
lug_y_offset = body_d * 0.14; // asymmetry in Y

// Notch in lug
notch_l = 0.0012;
notch_w = 0.0010;
notch_h = 0.0012;

overlap = 0.002;        // 1–2mm overlap for robust connectivity (per requirement)
eps = 1e-6;

// --- Helpers ---
module chamfered_cylinder(h, r, c) {
  c2 = min(c, h/2 - 2*eps);
  union() {
    cylinder(h=h - 2*c2, r=r, center=true);
    translate([0,0,(h/2 - c2/2)])
      cylinder(h=c2, r1=r, r2=max(r - c2, 0), center=true);
    translate([0,0,(-h/2 + c2/2)])
      cylinder(h=c2, r1=max(r - c2, 0), r2=r, center=true);
  }
}

module outer_shell() {
  chamfered_cylinder(body_h, body_d/2, edge_chamfer);
}

module inner_void() {
  // Open end at -Z, closed end at +Z with floor thickness cap_floor
  inner_r = max(body_d/2 - wall_t, 0);
  inner_h = max(body_h - cap_floor, 0);

  // Center so top of void is at +Z: (body_h/2 - cap_floor)
  inner_center_z = (body_h/2 - cap_floor) - inner_h/2;

  translate([0,0,inner_center_z])
    cylinder(h=inner_h + 2*eps, r=inner_r, center=true);
}

module lug_solid() {
  // Attach to +X side with guaranteed overlap into the cylinder
  // Inner face penetrates cylinder by 'overlap'
  lug_center_x = (body_d/2) + (lug_l/2) - overlap;

  translate([lug_center_x, lug_y_offset, 0])
    cube([lug_l, lug_w, lug_h], center=true);
}

module groove_cutter() {
  // Cut a shallow circumferential groove near the open end (-Z)
  // Use a slightly larger outer radius so the subtraction is guaranteed to bite.
  groove_center_z_raw = -body_h/2 + groove_offset_from_open_end;
  groove_center_z = min(
                    max(groove_center_z_raw, -body_h/2 + groove_w/2 + eps),
                    +body_h/2 - groove_w/2 - eps
                  );

  outer_r = body_d/2 + 0.001; // ensure visible/robust cut (>= 1mm beyond OD)
  inner_r = max(body_d/2 - groove_depth, 0);

  translate([0,0,groove_center_z])
    difference() {
      cylinder(h=groove_w + 2*eps, r=outer_r, center=true);
      cylinder(h=groove_w + 4*eps, r=inner_r, center=true);
    }
}

module notch_cutter() {
  // Notch cutout in the lug to suggest indexing/locking.
  // Place it on the OUTER end of the lug and cut inward.
  lug_center_x = (body_d/2) + (lug_l/2) - overlap;
  lug_outer_x  = lug_center_x + lug_l/2;

  // Keep notch fully within lug bounds, near +Y and +Z edges.
  notch_center_x = lug_outer_x - notch_l/2;                      // flush to outer face
  notch_center_y = lug_y_offset + (lug_w/2 - notch_w/2) - eps;   // near +Y edge
  notch_center_z = (lug_h/2 - notch_h/2) - eps;                  // near +Z edge

  translate([notch_center_x, notch_center_y, notch_center_z])
    cube([notch_l + 2*eps, notch_w + 2*eps, notch_h + 2*eps], center=true);
}

// --- Model ---
difference() {
  union() {
    outer_shell();
    lug_solid();
  }
  inner_void();       // sleeve/cap (open at -Z, closed at +Z)
  groove_cutter();    // visible shallow circumferential groove near open end
  notch_cutter();     // notch in lug
}
}
