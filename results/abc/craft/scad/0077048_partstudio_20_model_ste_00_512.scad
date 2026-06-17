// Dimension-calibrated (target: 0.12 x 0.05 x 0.02 mm)
scale([0.000958, 0.001020, 0.008571])
{
$fn = 64;

// -------------------- Parameters (mm) --------------------
L = 120;
W = 50;
T = 2.0;

corner_r = 12;

// overlap for solid connections (1–2mm requested)
overlap = 1.2;

// stepped base along one long edge (underside)
step_len = L - 2*corner_r;
step_w   = 8;
step_h   = 0.8;

// chamfered corner blocks (underside, both ends)
corner_block_len = 14;
corner_block_w   = 14;
corner_block_h   = 0.8;
corner_chamfer   = 3;

// cutouts
cut_through = T + 4;     // ensure full cut through everything
slot_len = 30;
slot_w   = 8;
slot_hex_flat = 10;      // controls "hex/slot" end facets

diamond_w = 10;
diamond_h = 14;

tri_side = 10;

// -------------------- Helpers --------------------
module rounded_rect_2d(l, w, r){
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
  }
}

module main_plate(){
  linear_extrude(height=T, center=true)
    rounded_rect_2d(L, W, corner_r);
}

module stepped_base(){
  // Make the step clearly visible: a shallow ledge along ONE long edge (underside),
  // slightly inset from the rounded perimeter and overlapping into the plate.
  // Place it along y = -W/2 edge.
  translate([0,
             -W/2 + step_w/2,
             -T/2 - step_h/2 + overlap/2])
    cube([step_len, step_w, step_h + overlap], center=true);
}

module chamfered_block_at(xc){
  // Distinct chamfered corner blocks at BOTH ends, on the same long edge as the step (underside).
  // These are separate from the rounded perimeter but overlap into the plate for a solid union.
  difference() {
    translate([xc,
               -W/2 + corner_block_w/2,
               -T/2 - corner_block_h/2 + overlap/2])
      cube([corner_block_len, corner_block_w, corner_block_h + overlap], center=true);

    // Chamfer the OUTER corner (towards -y and towards the end +/-x)
    // Use a rotated cube to cut a 45° chamfer.
    translate([xc + sign(xc)*(corner_block_len/2 - corner_chamfer/2),
               -W/2 + corner_chamfer/2,
               -T/2 - corner_block_h/2 + overlap/2])
      rotate([0,0,45])
        cube([corner_chamfer*2, corner_chamfer*2, corner_block_h + 2*overlap], center=true);
  }
}

module slot_hex(){
  linear_extrude(height=cut_through, center=true)
    polygon(points=[
      [-slot_len/2,                 -slot_hex_flat/2],
      [-slot_len/2+slot_hex_flat/2, -slot_w/2],
      [ slot_len/2-slot_hex_flat/2, -slot_w/2],
      [ slot_len/2,                 -slot_hex_flat/2],
      [ slot_len/2,                  slot_hex_flat/2],
      [ slot_len/2-slot_hex_flat/2,  slot_w/2],
      [-slot_len/2+slot_hex_flat/2,  slot_w/2],
      [-slot_len/2,                  slot_hex_flat/2]
    ]);
}

module diamond(){
  linear_extrude(height=cut_through, center=true)
    polygon(points=[
      [0,  diamond_h/2],
      [diamond_w/2, 0],
      [0, -diamond_h/2],
      [-diamond_w/2, 0]
    ]);
}

module triangle(){
  linear_extrude(height=cut_through, center=true)
    polygon(points=[
      [-tri_side/2, -tri_side*0.288675],
      [ tri_side/2, -tri_side*0.288675],
      [0,            tri_side*0.57735]
    ]);
}

// -------------------- Cutout Layout --------------------
module cutouts(){
  // Two rows of elongated hex/slot openings
  y_row1 =  W*0.18;
  y_row2 = -W*0.18;

  x_slots = [-L*0.28, 0, L*0.28];
  for (x = x_slots) {
    translate([x, y_row1, 0]) slot_hex();
    translate([x, y_row2, 0]) slot_hex();
  }

  // Two distinct diamonds near center (not an hourglass)
  translate([-L*0.08, 0, 0]) diamond();
  translate([ L*0.08, 0, 0]) diamond();

  // Four triangles (two near top, two near bottom)
  x_tri = [-L*0.22, L*0.22];
  y_tri_top =  W*0.34;
  y_tri_bot = -W*0.34;

  translate([x_tri[0], y_tri_top, 0]) triangle();
  translate([x_tri[1], y_tri_top, 0]) rotate([0,0,180]) triangle();

  translate([x_tri[0], y_tri_bot, 0]) rotate([0,0,180]) triangle();
  translate([x_tri[1], y_tri_bot, 0]) triangle();
}

// -------------------- Final Assembly (ONE connected solid) --------------------
difference() {
  union() {
    main_plate();

    // Shallow stepped base along one long edge (clearly present)
    stepped_base();

    // Chamfered corner blocks at both ends (same long edge as step)
    chamfered_block_at(-L/2 + corner_r + corner_block_len/2);
    chamfered_block_at( L/2 - corner_r - corner_block_len/2);
  }

  // through cutouts
  cutouts();
}
}
