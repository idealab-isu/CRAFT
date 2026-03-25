// Parameters
outer_diameter = 20.0; //[10.0:40.0:0.01]
thickness = 18.01; //[9.0:36.02:0.01]
hole_diameter = 8.0; //[4.0:16.0:0.01]
eps_overlap = 0.8; //[0.2:2.0:0.1]
chamfer_size = 0.0; //[0.0:2.0:0.1]
fillet_radius = 0.0; //[0.0:2.0:0.1]

// Base Shapes
module outer_cyl_body() {
  cylinder(r=outer_diameter/2, h=thickness, center=true);
}

module center_through_hole() {
  cylinder(r=hole_diameter/2, h=thickness + 2*eps_overlap, center=true);
}

module edge_chamfers() {
  // Chamfers are not applied as chamfer_size is 0
}

module edge_fillets() {
  // Fillets are not applied as fillet_radius is 0
}

module markings() {
  // No markings as size is [0, 0, 0]
}

// Operations
module spacer_with_hole() {
  difference() {
    outer_cyl_body();
    center_through_hole();
  }
}

module final_model() {
  union() {
    spacer_with_hole();
    markings();
  }
}

// Final Output
final_model();