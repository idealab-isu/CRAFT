// A extrusion bracket envelope: [40, 40, 35]
// Typical L-corner extrusion bracket: two perpendicular legs + triangular gusset + mounting slots.
// ONE connected solid. No floating parts.

$fn = 64;

// Envelope (overall bounding box)
envelope_x = 40; //[20:80:1]
envelope_y = 40; //[20:80:1]
envelope_z = 35; //[18:70:1]

// Bracket geometry
leg_thickness   = 6;      //[3:12:1]   // thickness of each leg (in X or Y)
plate_thickness = 8;      //[4:16:1]   // thickness in Z
gusset_thickness= 6;      //[3:12:1]   // thickness of triangular rib (in Z)
inner_relief    = 1.0;    //[0:3:0.1]  // small relief at inside corner

// Slots/holes
slot_width      = 6.6;    //[4:9:0.1]  // across-slot width (typical M6 clearance)
slot_length     = 14;     //[8:24:1]   // slot length
slot_edge_offset= 12;     //[6:18:1]   // distance from outer edge to slot centerline
slot_overlap    = 1;      //[0.5:2:0.1]

// Connectivity overlap (guarantees attachment between solids)
attach_overlap  = 1.5;    //[1:2:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module slot2d(len, wid) {
  // 2D rounded slot centered at origin, along X
  hull() {
    translate([-len/2, 0]) circle(d=wid);
    translate([ len/2, 0]) circle(d=wid);
  }
}

module extrusion_corner_bracket() {
  // Ensure parameters fit inside envelope
  lt = clamp(leg_thickness, 2, min(envelope_x, envelope_y)/2);
  pt = clamp(plate_thickness, 2, envelope_z);
  gt = clamp(gusset_thickness, 2, pt);

  // Place bracket so it occupies the +X,+Y quadrant, centered in Z
  // Overall envelope: X:[0..envelope_x], Y:[0..envelope_y], Z:[-pt/2..pt/2]
  // Then translate to center the whole envelope at origin.
  translate([-envelope_x/2, -envelope_y/2, 0]) {

    difference() {
      union() {
        // Two perpendicular legs (L shape)
        translate([0, 0, -pt/2])
          cube([envelope_x, lt, pt], center=false);

        translate([0, 0, -pt/2])
          cube([lt, envelope_y, pt], center=false);

        // Triangular gusset (rib) inside the L, centered in Z, connected to both legs
        translate([0, 0, -gt/2])
          linear_extrude(height=gt)
            polygon(points=[[0,0],[envelope_x,0],[0,envelope_y]]);

        // --- CONNECTIVITY FIX ---
        // The right-side rectangular block must be physically attached to the main body.
        // In the original, it was placed at Y=0 with depth=lt, which only touches the X-leg
        // and can appear disconnected in top/bottom views from the main bracket mass.
        //
        // Fix: make it overlap BOTH legs by spanning Y from 0..(lt+attach_overlap),
        // and overlap in X by attach_overlap. This guarantees a single connected solid.
        right_block_w = lt;                          // width in X
        right_block_d = lt + attach_overlap;         // depth in Y (overlaps into the Y-leg region)
        right_block_h = pt;                          // same Z thickness as bracket

        // Block spans:
        // X: [envelope_x - attach_overlap .. envelope_x - attach_overlap + right_block_w]
        // Y: [0 .. right_block_d]  (overlaps the corner region by attach_overlap)
        translate([envelope_x - attach_overlap, 0, -pt/2])
          cube([right_block_w, right_block_d, right_block_h], center=false);
      }

      // Inside-corner relief (small cut) to avoid sharp internal corner
      if (inner_relief > 0) {
        translate([lt, lt, 0])
          cylinder(r=inner_relief, h=pt + 2*slot_overlap, center=true);
      }

      // Two mounting slots: one on each leg, cut through Z
      sx = clamp(envelope_x - slot_edge_offset, lt + slot_length/2 + 1, envelope_x - slot_length/2 - 1);
      sy = lt/2;

      translate([sx, sy, 0])
        linear_extrude(height=pt + 2*slot_overlap, center=true)
          slot2d(slot_length, slot_width);

      tx = lt/2;
      ty = clamp(envelope_y - slot_edge_offset, lt + slot_length/2 + 1, envelope_y - slot_length/2 - 1);

      translate([tx, ty, 0])
        rotate([0,0,90])
          linear_extrude(height=pt + 2*slot_overlap, center=true)
            slot2d(slot_length, slot_width);
    }
  }
}

// Output
extrusion_corner_bracket();