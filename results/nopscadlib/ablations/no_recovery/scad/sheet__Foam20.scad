// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 150; //[75:300:1]
sheet_T = 20; //[10:40:1]
edge_radius = 3; //[1.5:6:0.5]
corner_chamfer = 4; //[2:8:0.5]
overlap = 1; //[0.5:2:0.5]
pore_radius = 1.5; //[0.8:3:0.1]
pore_depth = 1.2; //[0.5:3:0.1]
pore_margin = 12; //[6:24:1]
branding_size = 30; //[15:60:1]
branding_height = 1.2; //[0.5:3:0.1]

// Foam Sheet Body
module foam_sheet_body() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

// Edge Rounding
module edge_rounding() {
  sphere(r=edge_radius, center=true);
}

// Corner Chamfers
module corner_chamfers() {
  cube([corner_chamfer, corner_chamfer, sheet_T + 2*overlap], center=true);
}

// Surface Pores Texture
module surface_pores_texture() {
  cylinder(r=pore_radius, h=pore_depth + 2*overlap, center=true);
}

// Branding Emboss
module branding_emboss() {
  cube([branding_size, branding_size, branding_height], center=true);
}

// Foam Sheet with Rounded Edges
module foam_sheet_rounded() {
  minkowski() {
    foam_sheet_body();
    edge_rounding();
  }
}

// Foam Sheet with Chamfers
module foam_sheet_with_chamfers() {
  difference() {
    foam_sheet_rounded();
    translate([sheet_L/2 - corner_chamfer/2 + overlap, sheet_W/2 - corner_chamfer/2 + overlap, 0])
      corner_chamfers();
    translate([sheet_L/2 - corner_chamfer/2 + overlap, -sheet_W/2 + corner_chamfer/2 - overlap, 0])
      corner_chamfers();
    translate([-sheet_L/2 + corner_chamfer/2 - overlap, sheet_W/2 - corner_chamfer/2 + overlap, 0])
      corner_chamfers();
    translate([-sheet_L/2 + corner_chamfer/2 - overlap, -sheet_W/2 + corner_chamfer/2 - overlap, 0])
      corner_chamfers();
  }
}

// Foam Sheet with Pores
module foam_sheet_with_pores() {
  difference() {
    foam_sheet_with_chamfers();
    translate([sheet_L/2 - pore_margin, sheet_W/2 - pore_margin, sheet_T/2 - pore_depth/2 + overlap])
      surface_pores_texture();
    translate([sheet_L/2 - pore_margin, -sheet_W/2 + pore_margin, sheet_T/2 - pore_depth/2 + overlap])
      surface_pores_texture();
    translate([-sheet_L/2 + pore_margin, sheet_W/2 - pore_margin, sheet_T/2 - pore_depth/2 + overlap])
      surface_pores_texture();
    translate([-sheet_L/2 + pore_margin, -sheet_W/2 + pore_margin, sheet_T/2 - pore_depth/2 + overlap])
      surface_pores_texture();
  }
}

// Complete Model with Branding
module complete_model() {
  union() {
    foam_sheet_with_pores();
    translate([0, 0, sheet_T/2 + branding_height/2 - overlap])
      branding_emboss();
  }
}

// Render the complete model
complete_model();