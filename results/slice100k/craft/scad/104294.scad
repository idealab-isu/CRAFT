// Long slotted rack/comb plate with pointed/chamfered tip and mounting tab
// Bounding box target: 24.4 x 99.3 x 2.0 mm

$fn = 128;

// Parameters (mm)
L = 99.32;          // overall length (X)
W = 24.41;          // tab width (Y) at mounting end
T = 2.0;            // thickness (Z)

tab_L   = 22;       // length of mounting tab (X)
strip_W = 14;       // width of long strip (Y)

tip_L = 10;         // pointed tip length (X)

slot_L = 6;         // slot length (X)
slot_W = 3;         // slot width (Y)
slot_pitch = 7;     // pitch along X
slot_start_from_tip = 12; // from tip end (X)
slot_end_before_tab = 6;  // keep-out before tab start (X)

hole_d = 3.2;
hole_spacing = 12;            // Y spacing between the two holes
hole_center_from_tab_end = 8; // from mounting end (X)

scallop_outer_d = 10;
scallop_inner_d = 6;
scallop_teeth = 10;

tab_corner_chamfer = 1.2;

eps = 0.05;

// Helpers
function x_tip()       = -L/2;
function x_mount_end() =  L/2;
function x_tab_start() =  L/2 - tab_L;

// 2D outline (XY), then extrude to thickness
module outline_2d() {
  union() {
    // Main strip rectangle (full length, narrow width)
    square([L, strip_W], center=true);

    // Mounting tab rectangle (wider, at +X end)
    // Overlaps the strip automatically (same plane), ensuring a single connected body.
    translate([x_tab_start() + tab_L/2, 0])
      square([tab_L, W], center=true);

    // Pointed/chamfered tip: triangular wedge at -X end
    // Base matches strip width at x = x_tip + tip_L, apex at x = x_tip
    polygon(points=[
      [x_tip(), 0],
      [x_tip() + tip_L,  strip_W/2],
      [x_tip() + tip_L, -strip_W/2]
    ]);
  }
}

// Rectangular slot (sharp corners) as 2D cutter
module slot_2d() {
  square([slot_L, slot_W], center=true);
}

// Scalloped (gear-like) cutout as 2D cutter
module scallop_2d() {
  difference() {
    union() {
      circle(d=scallop_outer_d);
      for (i = [0:scallop_teeth-1]) {
        rotate(i*360/scallop_teeth)
          translate([scallop_outer_d/2, 0])
            circle(d=scallop_outer_d*0.35);
      }
    }
    circle(d=scallop_inner_d);
  }
}

// Tab corner chamfers as 2D cutters (remove small right triangles)
module tab_corner_chamfers_2d() {
  c = tab_corner_chamfer;

  // top-right
  polygon(points=[
    [x_mount_end(),  W/2],
    [x_mount_end() - c, W/2],
    [x_mount_end(),  W/2 - c]
  ]);

  // bottom-right
  polygon(points=[
    [x_mount_end(), -W/2],
    [x_mount_end() - c, -W/2],
    [x_mount_end(), -W/2 + c]
  ]);

  // top-left (tab start)
  polygon(points=[
    [x_tab_start(),  W/2],
    [x_tab_start() + c, W/2],
    [x_tab_start(),  W/2 - c]
  ]);

  // bottom-left (tab start)
  polygon(points=[
    [x_tab_start(), -W/2],
    [x_tab_start() + c, -W/2],
    [x_tab_start(), -W/2 + c]
  ]);
}

module cutouts_2d() {
  union() {
    // Slots array along strip centerline
    x0 = x_tip() + slot_start_from_tip;
    x_max = x_tab_start() - slot_end_before_tab;

    // Compute max count from available length
    nmax = floor((x_max - x0 - slot_L/2) / slot_pitch) + 1;

    for (i = [0 : max(nmax-1, -1)]) {
      xi = x0 + i*slot_pitch;
      if (xi + slot_L/2 <= x_max)
        translate([xi, 0]) slot_2d();
    }

    // Mounting holes (two circular through-holes), symmetric about centerline
    // Positioned on the tab near the mounting end.
    x_h = x_mount_end() - hole_center_from_tab_end;
    translate([x_h,  hole_spacing/2]) circle(d=hole_d);
    translate([x_h, -hole_spacing/2]) circle(d=hole_d);

    // Central scalloped cutout on tab (centered in the tab)
    translate([x_tab_start() + tab_L/2, 0])
      scallop_2d();

    // Tab corner chamfers
    tab_corner_chamfers_2d();
  }
}

// Final solid (single connected plate)
difference() {
  linear_extrude(height=T, center=true, convexity=10)
    outline_2d();

  // Slightly taller cutter to guarantee clean through-cuts
  linear_extrude(height=T + 2*eps, center=true, convexity=10)
    cutouts_2d();
}