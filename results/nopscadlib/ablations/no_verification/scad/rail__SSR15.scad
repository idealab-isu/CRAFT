// Parameters
rail_W = 15.0; //[7.5:30.0:0.5]
rail_H = 12.5; //[6.25:25.0:0.5]
rail_L = 100.0; //[50.0:200.0:1]
overlap = 1.0; //[0.5:2.0:0.1]
hole_d = 3.5; //[2.0:6.0:0.1]
hole_count = 4; //[2:8:1]
hole_edge_margin = 12.0; //[6.0:25.0:0.5]
hole_z_from_top = 3.0; //[1.5:6.0:0.25]
chamfer_len = 1.5; //[0.5:4.0:0.25]
fillet_r = 0.8; //[0.3:2.0:0.1]
groove_W = 6.0; //[3.0:10.0:0.25]
groove_D = 1.5; //[0.5:4.0:0.25]

// Rail Body
module rail_body() {
  color("Silver")
  cube([rail_W, rail_L, rail_H], center=true);
}

// Groove Cut
module groove_cut() {
  translate([0, 0, rail_H/2 - groove_D/2])
  cube([groove_W, rail_L + 2*overlap, groove_D + overlap], center=true);
}

// Hole Cutter Prototype
module hole_cutter_proto() {
  rotate([0, 90, 0])
  cylinder(h=rail_W + 2*overlap, r=hole_d/2, center=true);
}

// End Chamfer
module end_chamfer() {
  cube([rail_W + 2*overlap, chamfer_len, rail_H + 2*overlap], center=true);
}

// Fillet Sphere
module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Mounting Holes
module mounting_holes() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([0, -rail_L/2 + hole_edge_margin + i*(rail_L - 2*hole_edge_margin)/(hole_count - 1), rail_H/2 - hole_z_from_top])
      hole_cutter_proto();
    }
  }
}

// Rail with Groove and Holes
module rail_with_groove_and_holes() {
  difference() {
    rail_body();
    groove_cut();
    mounting_holes();
  }
}

// Rail with Chamfers
module rail_with_chamfers() {
  difference() {
    rail_with_groove_and_holes();
    translate([0, rail_L/2 - chamfer_len/2 + overlap/2, 0])
    rotate([0, 0, 45]) end_chamfer();
    translate([0, -rail_L/2 + chamfer_len/2 - overlap/2, 0])
    rotate([0, 0, 45]) end_chamfer();
  }
}

// Rail with Edge Fillets
module rail_with_edge_fillets() {
  minkowski() {
    rail_with_chamfers();
    fillet_sphere();
  }
}

// Complete Model
module complete_model() {
  rail_with_edge_fillets();
}

// Final Output
complete_model();