// Dimension-calibrated (target: 0.13 x 0.05 x 0.05 mm)
scale([1.280741, 1.300000, 1.181818])
{
// Offset link/lever with two bosses and through hex holes
// Structural fixes:
// - Clear L-shaped/offset profile in side view via Z step between ends
// - Cylindrical bosses (no faceting)
// - Recalculated translations so parts touch with controlled overlap
// - Single connected solid, then holes subtracted
// - Optional uniform scaling to meet tiny bounding-box requirement

// ---------- Quality ----------
$fn = 96;

// ---------- Parameters (mm, before optional scaling) ----------
bbox_L = 0.13;
bbox_W = 0.05;
bbox_H = 0.05;

boss_large_d = 0.05;
boss_small_d = 0.04;

boss_large_t = 0.05;
boss_small_t = 0.03;

bar_t = 0.02;
bar_w = 0.02;
bar_L = 0.09;

hex_flat_large = 0.02;
hex_flat_small = 0.018;
hex_clearance = 0.001;

hex_h_extra = 0.01;

// Connection overlap (in mm, pre-scale). Keep small but nonzero.
overlap = 0.0015;

// L-shaped offset amount (creates the side-view step)
z_offset = 0.012;

// Optional: scale whole model so its max dimension is ~0.1mm.
// Set to 1 to keep original sizes.
target_max_dim = 0.10;
pre_max_dim = max(bbox_L, bbox_W, bbox_H);
scale_to_target = target_max_dim / pre_max_dim;  // ~0.769 for given bbox
use_scaling = true;

// ---------- Helpers ----------
function hex_R_from_flat(f) = f / sqrt(3); // circumradius for flat-to-flat = f

module hex_prism(flat, h) {
  // Regular hex with flats aligned to Y axis (rotation not critical)
  cylinder(r=hex_R_from_flat(flat), h=h, center=true, $fn=6);
}

// ---------- Geometry (centered around origin) ----------
module solid_body() {
  // Coordinate system:
  // X = length direction, Y = width, Z = thickness/offset direction
  //
  // Large boss centered at x = -bar_L/2, z = 0
  // Small boss centered at x = +bar_L/2, z = z_offset
  // Bar is a rectangular prism connecting the two boss centers, centered at z = z_offset/2

  xL = -bar_L/2;
  xS =  bar_L/2;

  zL = 0;
  zS = z_offset;

  // Bar spans between boss centers, with a little extra length to overlap into bosses
  bar_len = bar_L + overlap*2;
  bar_z   = (zL + zS)/2;

  union() {
    // Connecting bar (rectangular)
    translate([0, 0, bar_z])
      cube([bar_len, bar_w, bar_t], center=true);

    // Large boss (cylindrical), slightly overlapped with bar
    translate([xL, 0, zL])
      cylinder(d=boss_large_d, h=boss_large_t + overlap*2, center=true);

    // Small boss (cylindrical), offset in Z to create L-profile
    translate([xS, 0, zS])
      cylinder(d=boss_small_d, h=boss_small_t + overlap*2, center=true);

    // Web/step connector to make the offset visually and structurally continuous:
    // hull between two thin pads at the bar/boss junctions.
    hull() {
      translate([xL + boss_large_d/2 - overlap, 0, zL])
        cube([overlap*2, bar_w, bar_t], center=true);

      translate([xS - boss_small_d/2 + overlap, 0, zS])
        cube([overlap*2, bar_w, bar_t], center=true);
    }
  }
}

module body_with_holes() {
  xL = -bar_L/2;
  xS =  bar_L/2;

  zL = 0;
  zS = z_offset;

  difference() {
    solid_body();

    // Through hex hole in large boss
    translate([xL, 0, zL])
      hex_prism(hex_flat_large + hex_clearance, boss_large_t + hex_h_extra);

    // Through hex hole in small boss
    translate([xS, 0, zS])
      hex_prism(hex_flat_small + hex_clearance, boss_small_t + hex_h_extra);
  }
}

// ---------- Final Output ----------
if (use_scaling)
  scale([scale_to_target, scale_to_target, scale_to_target]) body_with_holes();
else
  body_with_holes();
}
