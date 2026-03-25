// Low-profile decorative plate/nameplate insert
// Bounding box target: L x W x H = 3.1 x 1.6 x 0.5 mm

// Parameters
L = 3.10;                 // overall length (X)
W = 1.60;                 // overall width  (Y)
H = 0.50;                 // overall height (Z)

corner_clip = 0.25;       // clipped corner amount (plan)
outer_chamfer = 0.06;     // top-edge chamfer height

panel_inset_x = 0.35;     // panel offset from left/right
panel_inset_y = 0.25;     // panel offset from top/bottom
panel_recess_depth = 0.10;// recess depth into top face

border_width = 0.18;      // raised border width around inner panel
panel_corner_cut = 0.12;  // angled cuts on panel corners (plan)

micro_texture_depth = 0.01; // subtle extra recess in inner panel

fillet_r = 0.03;          // small overall edge softening
eps = 0.01;

// ---------- Helpers (2D) ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module octo2d(len, wid, clip) {
  // Octagonal-like perimeter: rectangle with clipped corners
  polygon(points=[
    [ len/2 - clip,  wid/2],
    [-len/2 + clip,  wid/2],
    [-len/2,         wid/2 - clip],
    [-len/2,        -wid/2 + clip],
    [-len/2 + clip, -wid/2],
    [ len/2 - clip, -wid/2],
    [ len/2,        -wid/2 + clip],
    [ len/2,         wid/2 - clip]
  ]);
}

module panel2d(px, py, clip) {
  // Panel outline with clipped corners
  octo2d(px, py, clip);
}

// ---------- Main solids ----------
module base_plate() {
  // Single connected plate with clipped corners
  linear_extrude(height=H, center=true)
    octo2d(L, W, corner_clip);
}

module top_chamfer_cut() {
  // Remove a thin ring near the top to create a chamfered outer edge.
  // Uses 2D offset difference to form a wedge-like cut.
  translate([0,0, H/2 - outer_chamfer])
  linear_extrude(height=outer_chamfer + eps, center=false)
    difference() {
      octo2d(L, W, corner_clip);
      offset(delta=-outer_chamfer)
        octo2d(L, W, corner_clip);
    }
}

module recessed_panel_cut() {
  // Recessed panel region (with angled corner cuts) cut into TOP face only.
  px = L - 2*panel_inset_x;
  py = W - 2*panel_inset_y;

  // Keep panel valid
  px2 = clamp(px, 0.2, L - 2*outer_chamfer);
  py2 = clamp(py, 0.2, W - 2*outer_chamfer);

  // Panel corner clip should not exceed half-dim
  pclip = clamp(panel_corner_cut, 0, min(px2, py2)/2 - 0.001);

  translate([0,0, H/2 - panel_recess_depth])
  linear_extrude(height=panel_recess_depth + eps, center=false)
    panel2d(px2, py2, pclip);
}

module inner_texture_cut() {
  // Slight extra recess inside the raised border (top face only)
  px = L - 2*panel_inset_x - 2*border_width;
  py = W - 2*panel_inset_y - 2*border_width;

  px2 = clamp(px, 0.15, L);
  py2 = clamp(py, 0.15, W);

  // Slightly smaller corner clip for inner area
  pclip = clamp(panel_corner_cut - border_width*0.5, 0, min(px2, py2)/2 - 0.001);

  translate([0,0, H/2 - panel_recess_depth - micro_texture_depth])
  linear_extrude(height=micro_texture_depth + eps, center=false)
    panel2d(px2, py2, pclip);
}

module plate_with_top_details() {
  // Opposite face remains mostly flat: all detailing is cut from the top only.
  difference() {
    base_plate();
    top_chamfer_cut();
    recessed_panel_cut();
    inner_texture_cut();
  }
}

// Final output: small global fillet/softening while keeping one connected solid
minkowski() {
  plate_with_top_details();
  sphere(r=fillet_r, $fn=24);
}