// Parameters
sheet_L = 1000; //[500:2000:1]
sheet_W = 500; //[250:1000:1]
sheet_T = 3; //[1.5:6:0.1]
film_T = 0.05; //[0.02:0.2:0.01]
overlap = 1; //[0.5:2:0.1]
corner_radius = 0; //[0:10:0.5]
edge_chamfer = 0; //[0:2:0.1]

// Base Shapes
module sheet_panel() {
  color("Silver")
  translate([0, 0, 0])
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

module protective_film_layer() {
  color([0.85, 0.85, 0.8]) // Off-white for protective film
  translate([0, 0, sheet_T/2 + film_T/2 - overlap])
    cube([sheet_L, sheet_W, film_T], center=true);
}

module label_text() {
  color("Black")
  translate([0, 0, sheet_T/2 + film_T/2 - overlap])
    cube([sheet_L/10, sheet_W/10, film_T], center=true);
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
    label_text();
    // Note: corner_radius and edge_chamfer are not applied as they are set to 0
  }
}

// Final Output
complete_model();