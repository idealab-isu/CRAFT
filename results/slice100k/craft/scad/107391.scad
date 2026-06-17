$fn = 80;

// Target bounding box (X x Y x Z): 5.4 x 0.6 x 6.7 mm
// Elongated along Z (length), thin along Y (thickness), width along X.

Lz = 6.70;   // length (Z)
Wx = 5.40;   // width  (X)
Ty = 0.60;   // thickness (Y)

// Plan-view rounding + slight taper
corner_r = 0.85;        // generous perimeter fillet in plan view
taper_delta_W = 0.35;   // one end narrower by this amount (in X)

// Side scallops/notches (both left and right edges), shallow
scallop_depth = 0.22;   // how far scallop bites into side (X)
scallop_r = 0.55;       // scallop radius
scallop_z = 0.0;        // centered along length

// Subtle diagonal surface contouring/rib-like relief (very shallow)
rib_h = 0.05;           // height of raised ribs on each face
rib_w = 0.55;           // rib band width (in X)
rib_angle_deg = 28;     // diagonal direction in XZ
rib_spacing = 1.35;     // spacing along Z
rib_count = 3;          // number of ribs

overlap = 0.05;

module rounded_rect_2d(w, l, r) {
  r2 = max(0, min(r, min(w, l)/2 - 0.001));
  offset(r=r2) square([w-2*r2, l-2*r2], center=true);
}

// Tapered outline in XZ: hull between two rounded rectangles at opposite ends
module tapered_outline_2d(w, l, r, taper_dw) {
  w2 = max(0.01, w - taper_dw);
  hull() {
    translate([0, -l/2 + r, 0]) rounded_rect_2d(w,  2*r, r);
    translate([0,  l/2 - r, 0]) rounded_rect_2d(w2, 2*r, r);
  }
}

// Base plate (plan view in XZ), extruded in Y
module base_plate() {
  linear_extrude(height=Ty, center=true, convexity=8)
    tapered_outline_2d(Wx, Lz, corner_r, taper_delta_W);
}

// Shallow side scallops: subtract cylinders whose axes are along Y
module scallops_cut() {
  // Place cylinder centers slightly outside the side edges so the cut is shallow.
  x_left  = -Wx/2 - scallop_r + scallop_depth;
  x_right =  Wx/2 + scallop_r - scallop_depth;

  for (sx = [x_left, x_right]) {
    translate([sx, 0, scallop_z])
      rotate([90, 0, 0])  // cylinder axis along Y
        cylinder(r=scallop_r, h=Ty + 2*overlap, center=true);
  }
}

// One diagonal rib slab, later intersected with the plate footprint
module rib_slab(z0, is_top=true) {
  y0 = is_top ? (Ty/2 - rib_h/2) : (-Ty/2 + rib_h/2);
  translate([0, y0, z0])
    rotate([0, rib_angle_deg, 0])  // diagonal in XZ
      cube([rib_w, rib_h, Lz*2.0], center=true);
}

module ribs(is_top=true) {
  for (i = [-(rib_count-1)/2 : 1 : (rib_count-1)/2]) {
    rib_slab(i * rib_spacing, is_top);
  }
}

module model() {
  union() {
    // Main plate with scallops (no through-holes/slots)
    difference() {
      base_plate();
      scallops_cut();
    }

    // Subtle raised diagonal ribs on both faces, clipped to the plate footprint
    intersection() {
      union() {
        ribs(true);
        ribs(false);
      }
      linear_extrude(height=Ty + 2*overlap, center=true, convexity=6)
        tapered_outline_2d(Wx, Lz, corner_r, taper_delta_W);
    }
  }
}

model();