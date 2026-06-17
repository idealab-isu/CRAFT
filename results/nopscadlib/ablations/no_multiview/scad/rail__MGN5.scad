// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 5.0; //[2.5:10.0:0.1]
rail_height = 3.6; //[1.8:7.2:0.1]
chamfer_length = 1.0; //[0.5:2.0:0.1]
fillet_radius = 0.4; //[0.2:0.8:0.05]
hole_diameter = 2.0; //[1.0:3.0:0.1]
hole_count = 4; //[2:8:1]
hole_edge_margin = 10.0; //[5.0:20.0:1]
hole_overlap = 0.5; //[0.2:2.0:0.1]

// Main rail body
module guide_rail_body() {
  color("Silver")
  cube([rail_width, rail_length, rail_height], center=true);
}

// Chamfer cuts
module end_chamfer_cut_pos() {
  translate([0, rail_length/2 - chamfer_length/2 + 1, 0])
  rotate([0, 45, 0])
  cube([rail_width*2, chamfer_length, rail_height*2], center=true);
}

module end_chamfer_cut_neg() {
  translate([0, -rail_length/2 + chamfer_length/2 - 1, 0])
  rotate([0, 45, 0])
  cube([rail_width*2, chamfer_length, rail_height*2], center=true);
}

// Mounting holes
module mounting_hole(pos_y) {
  translate([0, pos_y, 0])
  rotate([90, 0, 0])
  cylinder(h=rail_height + hole_overlap*2, r=hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    mounting_hole(-rail_length/2 + hole_edge_margin);
    mounting_hole(-rail_length/2 + hole_edge_margin + (rail_length - 2*hole_edge_margin)/3);
    mounting_hole(-rail_length/2 + hole_edge_margin + 2*(rail_length - 2*hole_edge_margin)/3);
    mounting_hole(rail_length/2 - hole_edge_margin);
  }
}

// Edge fillets (approximated)
module edge_fillets_sphere() {
  sphere(r=fillet_radius, center=true);
}

// Final rail with chamfers and holes
module rail_with_holes() {
  difference() {
    difference() {
      guide_rail_body();
      end_chamfer_cut_pos();
      end_chamfer_cut_neg();
    }
    mounting_holes();
  }
}

// Final output with edge fillets
module engraved_markings() {
  // Minkowski is avoided due to performance issues, so we skip this step
  rail_with_holes();
}

// Render the final output
engraved_markings();