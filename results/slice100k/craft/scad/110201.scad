// Dimension-calibrated (target: 48.00 x 10.00 x 16.00 mm)
scale([0.987654, 0.769231, 1.000000])
{
// U-shaped / saddle-style mounting strap (single connected solid)

// ---------- Parameters ----------
L = 48;                 // overall length (X)
W = 10;                 // strap width (Y)
H = 16;                 // overall height (Z)
t = 2;                  // bar thickness (radial thickness of strap)
hole_d = 4;
hole_edge_margin = 3;

arch_outer_R = 8;       // outer radius of arch (sets overall height with t)
arch_inner_R = 6;       // inner clearance radius (outer_R - t recommended)

tab_len = 16;           // length of each end tab (X)
arch_span_len = 16;     // straight span between tabs along X (controls arch length)
hole_center_from_end = 6;

overlap = 0.6;          // small overlap to guarantee connectivity/robust booleans
csk_d = 7.5;
csk_depth = 1;

$fn = 96;

// ---------- Derived ----------
arch_len = L - 2*tab_len;                 // length available for arched section along X
arch_len_eff = max(arch_len, overlap);    // avoid zero/negative
outerR = arch_outer_R;
innerR = arch_inner_R;

// Place the strap so the top of tabs is at Z = H/2 and overall height is H
// For a semicircle arch, overall height = outerR + t (from bottom of arch to top surface)
// We align: top surface Z_top = H/2, so bottom of arch is at Z_top - (outerR + t)
z_top = H/2;
z_bottom_arch = z_top - (outerR + t);
z_center_arch = z_bottom_arch + outerR;   // center of the semicircle

// Tab top surface at z_top, thickness t
z_tab_center = z_top - t/2;

// ---------- Helpers ----------
module tab(xc) {
  translate([xc, 0, z_tab_center])
    cube([tab_len + overlap, W, t + overlap], center=true);
}

module arch_solid() {
  // Create a half-ring (semi-annulus) in the X-Z plane, then extrude along X by arch_len_eff.
  // We build it by linear_extrude along X of a 2D semi-annulus in the Y-Z plane,
  // then rotate to align extrusion with X.
  translate([0, 0, z_center_arch])
    rotate([0, 90, 0])  // make linear_extrude go along X
      linear_extrude(height=arch_len_eff, center=true, convexity=10)
        difference() {
          // outer semicircle (upper half, y>=0 in 2D coords)
          intersection() {
            circle(r=outerR);
            translate([-outerR-1, 0]) square([2*outerR+2, outerR+2], center=false);
          }
          // inner semicircle removed
          intersection() {
            circle(r=innerR);
            translate([-innerR-1, 0]) square([2*innerR+2, innerR+2], center=false);
          }
        }
}

module strap_body() {
  // Ensure tabs connect to arch by overlapping slightly in X.
  union() {
    arch_solid();

    // Tab centers at ends
    tab(-(L/2 - tab_len/2));
    tab( (L/2 - tab_len/2));

    // Small bridging blocks to guarantee connection between arch and tabs
    // (covers any numerical gaps at the arch ends)
    bridge_len = overlap*2;
    translate([-(arch_len_eff/2 + bridge_len/2 - overlap), 0, z_tab_center])
      cube([bridge_len, W, t + overlap], center=true);
    translate([ (arch_len_eff/2 + bridge_len/2 - overlap), 0, z_tab_center])
      cube([bridge_len, W, t + overlap], center=true);
  }
}

module holes_and_csk() {
  for (sx = [-1, 1]) {
    xh = sx*(L/2 - hole_center_from_end);

    // Through hole (along Z)
    translate([xh, 0, z_tab_center])
      cylinder(d=hole_d, h=t + 4*overlap, center=true);

    // Countersink from top face
    translate([xh, 0, z_top - csk_depth/2 + overlap])
      cylinder(d1=csk_d, d2=hole_d, h=csk_depth + 2*overlap, center=true);
  }
}

module pipe_clearance() {
  // Remove a cylinder along Y to create clearance for a pipe/cable.
  // Centered at the arch center; length covers full width.
  translate([0, 0, z_center_arch])
    rotate([90, 0, 0])
      cylinder(r=innerR, h=W + 4*overlap, center=true);
}

// ---------- Final ----------
difference() {
  strap_body();
  holes_and_csk();
  pipe_clearance();
}
}
