// Parameters
rail_length = 100; //[50:200:1]
rail_width = 9; //[5:18:0.5]
rail_height = 6; //[3:12:0.5]
edge_fillet_radius = 0.6; //[0.2:1.2:0.1]
chamfer_length = 1.2; //[0.5:3:0.1]
connect_overlap = 1; //[0.5:2:0.1]

// Rail Body
module rail_body() {
  cube([rail_width, rail_length, rail_height], center=true);
}

// Edge Fillets
module edge_fillets_sphere() {
  sphere(r=edge_fillet_radius, center=true);
}

// End Chamfer Cut
module end_chamfer_cut() {
  cube([rail_width + 2*connect_overlap, chamfer_length, rail_height + 2*connect_overlap], center=true);
}

// Rail with Edge Fillets
module rail_with_edge_fillets() {
  minkowski() {
    rail_body();
    edge_fillets_sphere();
  }
}

// Rail with End Chamfers
module rail_with_end_chamfers() {
  difference() {
    rail_with_edge_fillets();
    translate([0, rail_length/2 - chamfer_length/2, 0])
      rotate([0, 0, 45]) end_chamfer_cut();
    translate([0, -rail_length/2 + chamfer_length/2, 0])
      rotate([0, 0, 45]) end_chamfer_cut();
  }
}

// Final Rail
module rail_complete() {
  union() {
    rail_with_end_chamfers();
    // Placeholder for mounting holes and engraved markings
    // Currently no geometry for these, as per plan
  }
}

// Render the final rail
color("Silver") rail_complete();