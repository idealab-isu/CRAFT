// Dimension-calibrated (target: 0.15 x 0.38 x 0.06 mm)
scale([0.590000, 0.947500, 1.250000])
{
// Long prismatic bar with recessed panels, perimeter chamfer/mitre,
// and shallow arched (concave) top/bottom with a central rectangular rib/step.
// Bounding box target: ~0.1 x 0.4 x 0.1 mm (X x Y x Z)

L = 0.40;   // length (Y)
W = 0.10;   // width  (X)
H = 0.10;   // height (Z)

panel_margin_L = 0.03;   // margin from ends (Y)
panel_margin_W = 0.015;  // margin from sides (X)
panel_depth    = 0.010;  // recess depth into face (Z)

rib_W = 0.030;  // central rib width across X
rib_H = 0.010;  // rib height above top face and below bottom face

// Make the arched/concave curvature clearly visible in orthographic views
arch_sag = 0.012; // concave sag into the face (Z) (increased for recognizability)
arch_R   = 0.45;  // large radius for shallow concavity

chamfer = 0.006;  // perimeter chamfer amount (45deg)

recess_corner_r = 0.004; // rounded corners for recessed panel
$fn = 128;

eps = 0.0005;
overlap = 0.0015; // small overlap to guarantee watertight unions/differences

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,1], r=1, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  r2 = max(0, min(r, x/2 - eps, y/2 - eps));
  linear_extrude(height=z, center=center)
    offset(r=r2)
      square([x-2*r2, y-2*r2], center=true);
}

module base_bar() {
  cube([W, L, H], center=true);
}

module top_rib() {
  // Overlap slightly into the base so it is unquestionably connected
  translate([0, 0, H/2 + rib_H/2 - overlap])
    cube([rib_W, L, rib_H + 2*overlap], center=true);
}

module bottom_rib() {
  // Overlap slightly into the base so it is unquestionably connected
  translate([0, 0, -H/2 - rib_H/2 + overlap])
    cube([rib_W, L, rib_H + 2*overlap], center=true);
}

module recessed_panel_top() {
  // Cut into the top face (do not reach the rib peak)
  translate([0, 0, H/2 - panel_depth/2 + overlap])
    rounded_rect_prism(
      size=[W - 2*panel_margin_W, L - 2*panel_margin_L, panel_depth + 2*overlap],
      r=recess_corner_r,
      center=true
    );
}

module recessed_panel_bottom() {
  // Cut into the bottom face (do not reach the rib peak)
  translate([0, 0, -H/2 + panel_depth/2 - overlap])
    rounded_rect_prism(
      size=[W - 2*panel_margin_W, L - 2*panel_margin_L, panel_depth + 2*overlap],
      r=recess_corner_r,
      center=true
    );
}

module concave_cutter_top() {
  // Cylinder axis along Y; subtract to create shallow concavity across X on top.
  // Positioned so the cylinder intrudes by arch_sag at the top face (z=+H/2).
  rotate([90, 0, 0])
    translate([0, 0, H/2 + arch_R - arch_sag])
      cylinder(r=arch_R, h=L + 6*overlap, center=true);
}

module concave_cutter_bottom() {
  // Cylinder axis along Y; subtract to create shallow concavity across X on bottom.
  rotate([90, 0, 0])
    translate([0, 0, -H/2 - arch_R + arch_sag])
      cylinder(r=arch_R, h=L + 6*overlap, center=true);
}

module chamfered_box_mask() {
  // Chamfered prism mask (trims edges/corners) using Minkowski with an octahedron.
  ztot = H + 2*rib_H;
  c = chamfer;

  ix = max(eps, W - 2*c);
  iy = max(eps, L - 2*c);
  iz = max(eps, ztot - 2*c);

  minkowski() {
    cube([ix, iy, iz], center=true);
    polyhedron(
      points=[
        [ c, 0, 0], [-c, 0, 0],
        [ 0, c, 0], [ 0,-c, 0],
        [ 0, 0, c], [ 0, 0,-c]
      ],
      faces=[
        [0,2,4],[2,1,4],[1,3,4],[3,0,4],
        [2,0,5],[1,2,5],[3,1,5],[0,3,5]
      ]
    );
  }
}

// ---------- Model ----------
module model() {
  // Build bar + ribs, carve recesses and concavity, then apply chamfer mask.
  intersection() {
    difference() {
      union() {
        base_bar();
        top_rib();
        bottom_rib();
      }

      // Decorative recessed panels on broad faces
      recessed_panel_top();
      recessed_panel_bottom();

      // Shallow concave curvature across width on top/bottom
      // (kept after ribs are added so the rib remains as a central step)
      concave_cutter_top();
      concave_cutter_bottom();
    }

    // Apply chamfer/mitre around the perimeter (including rib height)
    chamfered_box_mask();
  }
}

model();
}
