// Parameters
rail_L = 100; //[50:200:1]
rail_W = 15; //[8:30:0.5]
rail_H = 10; //[5:20:0.5]
overlap = 1; //[0.5:2:0.1]
hole_d = 4; //[2:8:0.5]
hole_count = 4; //[2:8:1]
hole_edge_margin = 12; //[6:24:1]
hole_depth = 6; //[2:10:0.5]
chamfer_len = 2; //[0.5:5:0.5]
fillet_r = 0.8; //[0.2:2:0.1]
mark_depth = 0.3; //[0.1:1:0.1]
mark_W = 10; //[5:20:0.5]
mark_L = 20; //[8:40:1]

// Rail Body with Fillets
module rail_body_fillet() {
  minkowski() {
    cube([rail_W, rail_L, rail_H], center=true);
    sphere(r=fillet_r);
  }
}

// End Chamfers
module end_chamfers() {
  difference() {
    rail_body_fillet();
    translate([0, rail_L/2 - chamfer_len/2 + overlap, 0])
      rotate([0, 0, 45])
      cube([rail_W + 2*overlap, chamfer_len + 2*overlap, rail_H + 2*overlap], center=true);
    translate([0, -rail_L/2 + chamfer_len/2 - overlap, 0])
      rotate([0, 0, 45])
      cube([rail_W + 2*overlap, chamfer_len + 2*overlap, rail_H + 2*overlap], center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([0, -rail_L/2 + hole_edge_margin + i*(rail_L - 2*hole_edge_margin)/(hole_count - 1), rail_H/2 - hole_depth/2 + overlap])
        cylinder(h=hole_depth + 2*overlap, r=hole_d/2, center=true);
    }
  }
}

// Engraved Markings
module engraved_markings() {
  translate([0, 0, rail_H/2 - mark_depth/2 + overlap])
    cube([mark_W, mark_L, mark_depth + 2*overlap], center=true);
}

// Complete Model
difference() {
  end_chamfers();
  mounting_holes();
  engraved_markings();
}