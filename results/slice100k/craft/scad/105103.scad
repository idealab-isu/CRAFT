// Serrated rack/knife insert with mounting plate
// Bounding box target: 24.4 x 99.3 x 3.0 mm

$fn = 96;

// Parameters
L = 99.32;
W = 24.41;
T = 3;

mount_L = 24;
blade_W = 14;

tip_L = 8;
tip_chamfer_W = 6;

tooth_pitch = 2;
tooth_depth = 2.2;
tooth_margin = 0.8;

hole_d = 3.2;
hole_spacing = 12;
hole_edge_offset = 6;

star_outer_d = 10;
star_inner_d = 6;
star_points = 8;

mount_transition_L = 6;
overlap = 0.6;

// ---------- Helpers ----------
function clamp(v, a, b) = v < a ? a : (v > b ? b : v);

module mount_hole_xy(x, y) {
  translate([x, y, -overlap])
    cylinder(h=T + 2*overlap, r=hole_d/2);
}

module star2d(cx, cy, ro, ri, n) {
  polygon(points=[
    for (i = [0:2*n-1]) let(
      ang = i*180/n,
      r = (i % 2 == 0) ? ro : ri
    ) [cx + r*cos(ang), cy + r*sin(ang)]
  ]);
}

module central_star_cutout() {
  linear_extrude(height=T + 2*overlap)
    star2d(-L/2 + mount_L/2, 0, star_outer_d/2, star_inner_d/2, star_points);
}

// ---------- 2D outline ----------
module base_outline_2d() {
  // Blade with chamfered/pointed tip (right end)
  polygon(points=[
    [-L/2, -blade_W/2],
    [ L/2 - tip_L, -blade_W/2],
    [ L/2, -blade_W/2 + tip_chamfer_W/2],
    [ L/2,  blade_W/2 - tip_chamfer_W/2],
    [ L/2 - tip_L,  blade_W/2],
    [-L/2,  blade_W/2]
  ]);
}

module mount_plate_2d() {
  // Diamond/arrowhead mounting plate on left end
  polygon(points=[
    [-L/2, 0],
    [-L/2 + mount_L/2,  W/2],
    [-L/2 + mount_L, 0],
    [-L/2 + mount_L/2, -W/2]
  ]);
}

module transition_2d() {
  // Ensure connection between mount plate and blade (overlapping rectangle)
  polygon(points=[
    [-L/2 + mount_L - overlap, -blade_W/2],
    [-L/2 + mount_L + mount_transition_L, -blade_W/2],
    [-L/2 + mount_L + mount_transition_L,  blade_W/2],
    [-L/2 + mount_L - overlap,  blade_W/2]
  ]);
}

module teeth_2d() {
  // Teeth along one long edge (top edge y=+blade_W/2), spanning most of blade length
  x0 = -L/2 + mount_L + tooth_margin;
  x1 =  L/2 - tip_L - tooth_margin;
  usable = x1 - x0;
  n = max(1, floor(usable / tooth_pitch));

  union() {
    for (i = [0:n-1]) {
      xi = x0 + i*tooth_pitch;
      polygon(points=[
        [xi,                 blade_W/2],
        [xi + tooth_pitch/2, blade_W/2 + tooth_depth],
        [xi + tooth_pitch,   blade_W/2]
      ]);
    }
  }
}

module full_profile_2d() {
  union() {
    base_outline_2d();
    mount_plate_2d();
    transition_2d();
    teeth_2d();
  }
}

// ---------- 3D model ----------
difference() {
  // Solid plate
  linear_extrude(height=T)
    full_profile_2d();

  // Two mounting holes (through)
  mount_hole_xy(-L/2 + hole_edge_offset, 0);
  mount_hole_xy(-L/2 + hole_edge_offset + hole_spacing, 0);

  // Central gear/star-shaped cutout (through)
  translate([0, 0, -overlap])
    central_star_cutout();
}