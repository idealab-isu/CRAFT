// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500; //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]
film_thickness = 0.05; //[0.02:0.2:0.01]
film_inset = 0.5; //[0.1:2:0.1]
overlap = 1; //[0.5:2:0.1]
corner_radius = 0; //[0:25:0.5]
edge_chamfer = 0; //[0:5:0.25]

// Base Shapes
module sheet_panel() {
  color("Silver")
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module protective_film_layer() {
  color([0.85, 0.85, 0.8]) // Off-white for protective film
  translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
  cube([sheet_length - 2*film_inset, sheet_width - 2*film_inset, film_thickness], center=true);
}

module edge_chamfer() {
  // Placeholder for edge chamfer, kept at 0 for sharp edges
}

module corner_radius() {
  // Placeholder for corner radius, kept at 0 for sharp corners
}

module label_text() {
  // Placeholder for label text, represented as a small box
  translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
  cube([sheet_length/10, sheet_width/10, film_thickness], center=true);
}

// Operations
module panel_with_film() {
  union() {
    sheet_panel();
    protective_film_layer();
  }
}

module complete_model() {
  union() {
    panel_with_film();
    edge_chamfer();
    corner_radius();
    label_text();
  }
}

// Final Output
complete_model();