// IEC power inlet module (IEC inlet filtered), panel cutout 40.0mm x 29.0mm
// One connected solid with recognizable IEC C14 inlet geometry (beveled mouth + key notch),
// pin cavities, rear filter can, flange, and snap tabs. All placements are formula-based.

$fn = 72;

// -------------------- Parameters --------------------
cutout_W = 40.0;          // panel cutout width (X)
cutout_H = 29.0;          // panel cutout height (Y)

flange_W = 50.0;
flange_H = 35.0;
flange_t = 2.5;

body_D = 34.0;            // depth behind panel
body_W = cutout_W + 2.0;  // slightly larger than cutout
body_H = cutout_H + 2.0;

front_face_t = 3.0;       // thickness of front "nose" region

// IEC C14-ish opening (visual, not a certified profile)
iec_open_W = 27.5;
iec_open_H = 19.5;
iec_corner_r = 2.0;

// Key notch (top center) typical of IEC inlets (visual)
key_notch_W = 7.0;
key_notch_H = 2.2;

// Bevel / funnel depth for inlet mouth
mouth_depth = 3.0;

// Pin cavity details (visual)
pin_r = 1.25;
pin_cav_d = 11.0;
pin_spacing = 10.0;
pin_row_y = -iec_open_H * 0.18;
ground_pin_y =  iec_open_H * 0.22;

// Rear filter can (visual)
filter_can_D = 20.0;
filter_can_W = body_W - 4.0;
filter_can_H = body_H - 4.0;

// Strain relief (visual)
strain_relief_r = 6.0;
strain_relief_L = 10.0;

// Snap tabs (visual)
snap_tab_overhang = 1.2;  // how far tab protrudes beyond body side
snap_tab_t = 1.6;
snap_tab_L = 9.0;

// Rounding
bezel_corner_r = 2.2;

// Robustness
eps = 0.01;
overlap = 0.8; // intentional overlap to guarantee connectivity

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2 - eps);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rounded_box(w, h, d, r, center=true) {
  linear_extrude(height=d, center=center)
    rounded_rect_2d(w, h, r);
}

module iec_open_2d(w, h, r) {
  // Base rounded rectangle with a small top-center key notch removed
  difference() {
    rounded_rect_2d(w, h, r);
    translate([0, h/2 - key_notch_H/2 + eps])
      square([key_notch_W, key_notch_H + 2*eps], center=true);
  }
}

// Coordinate convention:
// Front face at z = 0, positive z goes outward (front), negative z goes rearward (inside equipment).
// Flange spans z in [0, flange_t]. Main body spans z in [-body_D, 0].

// -------------------- Main solids --------------------
module front_flange() {
  translate([0, 0, flange_t/2])
    rounded_box(flange_W, flange_H, flange_t, bezel_corner_r, center=true);
}

module main_body() {
  // Touch flange at z=0 with overlap
  translate([0, 0, -body_D/2 + overlap/2])
    rounded_box(body_W, body_H, body_D + overlap, bezel_corner_r, center=true);
}

module rear_filter_can() {
  // Attached to rear of main body (rear face at z = -body_D)
  translate([0, 0, -body_D - filter_can_D/2 + overlap/2])
    rounded_box(filter_can_W, filter_can_H, filter_can_D + overlap, bezel_corner_r, center=true);
}

module strain_relief() {
  // Attached to rear of filter can (rear face at z = -body_D - filter_can_D)
  translate([0, 0, -body_D - filter_can_D - strain_relief_L/2 + overlap/2])
    cylinder(r=strain_relief_r, h=strain_relief_L + overlap, center=true);
}

module snap_tab(side=1) {
  // side = -1 (left), +1 (right)
  tab_w = snap_tab_t;
  tab_h = cutout_H * 0.42;
  tab_d = snap_tab_L;

  // Place so it overlaps body side and protrudes outward by snap_tab_overhang
  x = side*(body_W/2 + tab_w/2 - snap_tab_overhang);
  z = -(tab_d/2) + overlap/2; // near front, extends rearward
  translate([x, 0, z])
    cube([tab_w + overlap, tab_h, tab_d + overlap], center=true);
}

module snap_tabs() {
  union() {
    snap_tab(-1);
    snap_tab( 1);
  }
}

// -------------------- Cutouts (subtractions) --------------------
module iec_mouth_funnel() {
  // Beveled mouth: larger at the very front, tapering to the nominal opening
  // Implemented as a hull between two 2D profiles extruded at different Z.
  // Cuts through flange and into the front face region.
  z0 = -eps;                 // start at very front
  z1 = mouth_depth;          // into the part (positive z is outward, but flange is at z>0)
  // Our solid exists from z=0..flange_t (flange) and z<=0 (body).
  // So we cut from z=0 into negative z. We'll build the funnel in that direction.
  // Use z positions: 0 down to -mouth_depth.
  z_front = 0 + eps;
  z_back  = -mouth_depth;

  scale_front = 1.10;        // slightly larger at the very front
  scale_back  = 1.00;

  hull() {
    translate([0, 0, z_front])
      linear_extrude(height=eps, center=false)
        scale([scale_front, scale_front])
          iec_open_2d(iec_open_W, iec_open_H, iec_corner_r);

    translate([0, 0, z_back])
      linear_extrude(height=eps, center=false)
        scale([scale_back, scale_back])
          iec_open_2d(iec_open_W, iec_open_H, iec_corner_r);
  }
}

module iec_through_opening() {
  // Continue the nominal opening through flange and into body
  cut_d = flange_t + front_face_t + 10; // ensure it reaches into body
  // Start at front of flange and cut rearward (negative z)
  translate([0, 0, flange_t + eps])  // start just behind flange front
    rotate([180, 0, 0])              // extrude "down" in -Z
      linear_extrude(height=cut_d, center=false)
        iec_open_2d(iec_open_W, iec_open_H, iec_corner_r);
}

module iec_pin_cavities() {
  // Cylindrical cavities behind the opening (visual)
  zc = -(front_face_t + pin_cav_d/2); // behind front face
  union() {
    translate([-pin_spacing/2, pin_row_y, zc])
      cylinder(r=pin_r, h=pin_cav_d, center=true);
    translate([ pin_spacing/2, pin_row_y, zc])
      cylinder(r=pin_r, h=pin_cav_d, center=true);
    translate([0, ground_pin_y, zc])
      cylinder(r=pin_r, h=pin_cav_d, center=true);
  }
}

module inner_hollow() {
  // Hollow out the main body to avoid a solid block look (keeps shell)
  wall = 2.0;
  iw = max(1, body_W - 2*wall);
  ih = max(1, body_H - 2*wall);
  id = max(1, body_D - wall); // leave material at front
  // Keep front wall thickness ~wall by starting hollow behind z=0
  translate([0, 0, -id/2 - wall/2 + overlap/2])
    rounded_box(iw, ih, id + overlap, max(0.6, bezel_corner_r-0.9), center=true);
}

module rear_cable_passage() {
  // Small passage into strain relief area (visual)
  pass_r = max(2.5, strain_relief_r - 2.0);
  pass_d = filter_can_D + strain_relief_L + 2;
  zc = -body_D - filter_can_D - strain_relief_L/2;
  translate([0, 0, zc])
    cylinder(r=pass_r, h=pass_d, center=true);
}

// -------------------- Assembly --------------------
module iec_inlet_filtered_40x29() {
  difference() {
    union() {
      // Connected solids
      front_flange();
      main_body();
      rear_filter_can();
      strain_relief();
      snap_tabs();

      // Bridging rib to guarantee manifold connection between flange and body
      translate([0, 0, -overlap/2])
        cube([cutout_W, cutout_H, overlap], center=true);
    }

    // Subtractions for recognizable features
    iec_mouth_funnel();
    iec_through_opening();
    iec_pin_cavities();
    inner_hollow();
    rear_cable_passage();
  }
}

// Final output
iec_inlet_filtered_40x29();