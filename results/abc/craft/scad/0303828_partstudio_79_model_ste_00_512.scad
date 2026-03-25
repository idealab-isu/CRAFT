// Dimension-calibrated (target: 0.03 x 0.05 x 0.02 mm)
scale([1.000033, 0.833994, 1.764782])
{
// Spool / standoff-like double-ended bracket with obround flanges,
// edge holes near the outer ends, and a raised lug on one side of each flange.
// Minkowski removed for performance; rounding simplified via 2D offset on lug only.

$fn = 48;

// Parameters (unitless; original meters)
web_L = 0.026;
web_W = 0.012;
web_H = 0.012;

flange_L = 0.012;          // overall obround length (X)
flange_W = 0.030;          // overall obround width  (Y)
flange_H = 0.012;          // thickness (Z)

hole_d = 0.004;
hole_edge_offset = 0.003;  // from outermost end of flange along X

lug_L = 0.004;
lug_W = 0.006;
lug_H = 0.006;
lug_side_offset = 0.009;   // Y offset from centerline

overlap = 0.001;

cutout_margin = 0.001;
cutout_W = 0.004;
cutout_L = 0.006;
cutout_spacing = 0.004;

lug_round_r = 0.0015;      // simplified rounding for lug only (2D offset)

// Derived
flange_center_offset = web_L/2 + flange_L/2 - overlap; // centers of flanges from origin

// ---------- Helpers ----------
module obround_2d(L, W) {
  // 2D capsule/obround centered at origin, length along X
  r = min(W/2, L/2);
  hull() {
    translate([-(L/2 - r), 0]) circle(r=r);
    translate([ (L/2 - r), 0]) circle(r=r);
  }
}

module obround_plate(L, W, H) {
  linear_extrude(height=H, center=true)
    obround_2d(L, W);
}

module central_web() {
  cube([web_L, web_W, web_H], center=true);
}

module end_flange(sign=1) {
  translate([sign*flange_center_offset, 0, 0])
    obround_plate(flange_L, flange_W, flange_H);
}

module through_hole(sign=1) {
  // Hole near the outer edge of each flange (along X), through Z
  x_outer = sign*(web_L/2 + flange_L - overlap);
  x_hole  = x_outer - sign*hole_edge_offset;

  translate([x_hole, 0, 0])
    cylinder(d=hole_d, h=(web_H + 2*lug_H + 0.02), center=true);
}

module lug_2d(L, W, r=0) {
  // Rounded rectangle via offset (fast) or plain square if r<=0
  if (r > 0)
    offset(r=r) square([L-2*r, W-2*r], center=true);
  else
    square([L, W], center=true);
}

module lug(sign=1) {
  // Lug sits on top of flange, offset to one side in Y.
  // Mirror Y offset for symmetry: left lug +Y, right lug -Y.
  y = (sign < 0) ? lug_side_offset : -lug_side_offset;

  translate([sign*flange_center_offset, y, flange_H/2 + lug_H/2 - overlap])
    linear_extrude(height=lug_H, center=true)
      lug_2d(lug_L, lug_W, min(lug_round_r, min(lug_L, lug_W)/2 - 1e-6));
}

module web_cutout(dx=0) {
  // Lightening cutouts in the web only (kept within web width)
  w = min(cutout_W, web_W - 2*cutout_margin);
  translate([dx, 0, 0])
    cube([cutout_L, w, web_H + 0.02], center=true);
}

// ---------- Build ----------
module main_solid_preholes() {
  union() {
    central_web();

    // Integrated obround flanges (connected to web by overlap)
    end_flange(-1);
    end_flange( 1);

    // Raised lugs on opposite sides for symmetric double-ended geometry
    lug(-1);
    lug( 1);
  }
}

module main_solid_with_cutouts() {
  difference() {
    main_solid_preholes();
    union() {
      web_cutout(-cutout_spacing/2);
      web_cutout( cutout_spacing/2);
    }
  }
}

module main_solid_with_holes() {
  difference() {
    main_solid_with_cutouts();
    through_hole(-1);
    through_hole( 1);
  }
}

// Final
main_solid_with_holes();
}
