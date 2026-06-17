$fn = 128;

// Target bounding box (approx): 29.8 x 30.9 x 6.0 mm
bbox_X = 30.86;
bbox_Y = 29.78;
bbox_Z = 6.0;

ring_thickness = bbox_Z;

// Outer octagon (nut-like) - true octagon with flats aligned to X/Y
outer_flat_to_flat_X = bbox_X;
outer_flat_to_flat_Y = bbox_Y;

// Inner bore + keyways (two opposing, left-right)
bore_d = 20;
keyway_w = 3;                 // tangential width (Y)
keyway_depth_radial = 2;      // radial depth outward from bore
keyway_len_axial = bbox_Z;    // through full thickness

// Pins/tabs (two small cylinders) on +Z face near +X edge
pin_d = 2;
pin_h = 1.2;                  // protrusion beyond 6mm plate
pin_edge_offset = 2;          // from outer edge toward center
pin_spacing = 6;              // center-to-center in Y

// Robust boolean overlap / connectivity overlap
overlap = 1.2;                // 1-2mm overlap for solid connections

// ---------- Helpers ----------
function oct_points_from_flats(fx, fy) =
    let(a = fx/2, b = fy/2,
        // corner cut so resulting polygon is an octagon with flats on X/Y
        c = min(a, b) * (sqrt(2) - 1))
    [
      [ a - c,  b],
      [ a,      b - c],
      [ a,     -b + c],
      [ a - c, -b],
      [-a + c, -b],
      [-a,     -b + c],
      [-a,      b - c],
      [-a + c,  b]
    ];

module outer_oct_prism(h){
  linear_extrude(height=h, center=true)
    polygon(points=oct_points_from_flats(outer_flat_to_flat_X, outer_flat_to_flat_Y));
}

module bore_cut(){
  cylinder(d=bore_d, h=ring_thickness + 2*overlap, center=true);
}

module keyway_cut(sign=1){
  // Two opposing rectangular notches opening into the bore, oriented along X (left-right)
  // Start slightly inside bore and extend outward; ensure full-through cut.
  x_center = sign * (bore_d/2 + keyway_depth_radial/2 - overlap/2);
  translate([x_center, 0, 0])
    cube([keyway_depth_radial + overlap, keyway_w, keyway_len_axial + 2*overlap], center=true);
}

module pins(){
  // Two small cylindrical pins protruding from ONLY the +Z face near the +X outer edge.
  // Ensure they intersect the ring by `overlap` for a single connected solid.
  x_pin = outer_flat_to_flat_X/2 - pin_edge_offset - pin_d/2;

  // Place so the pin bottom is embedded into the ring by `overlap`
  // ring top surface is at +ring_thickness/2
  // pin bottom = z_pin - pin_h/2 = ring_thickness/2 - overlap
  z_pin = ring_thickness/2 - overlap + pin_h/2;

  union(){
    translate([x_pin,  pin_spacing/2, z_pin]) cylinder(d=pin_d, h=pin_h, center=true);
    translate([x_pin, -pin_spacing/2, z_pin]) cylinder(d=pin_d, h=pin_h, center=true);
  }
}

// ---------- Model ----------
module ring_body(){
  difference(){
    outer_oct_prism(ring_thickness);
    bore_cut();
    keyway_cut( 1);
    keyway_cut(-1);
  }
}

// Single connected solid
union(){
  ring_body();
  pins();
}