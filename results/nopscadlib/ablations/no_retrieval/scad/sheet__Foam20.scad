// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 150; //[75:300:1]
sheet_T = 10; //[5:20:1]
edge_radius = 2; //[1:6:0.5]
corner_chamfer = 2; //[1:6:0.5]
pore_radius = 0.8; //[0.3:2:0.1]
pore_depth = 0.6; //[0.2:2:0.1]
pore_margin = 8; //[4:20:1]
pore_overlap = 0.5; //[0.2:2:0.1]
rounding_shrink = 0.2; //[0.05:1:0.05]

// Foam Sheet Body
module foam_sheet_body() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

// Edge Rounding Sphere
module edge_rounding() {
  sphere(r=edge_radius, center=true);
}

// Surface Texture Pores
module surface_texture_pores() {
  union() {
    translate([-sheet_L/2 + pore_margin, -sheet_W/2 + pore_margin, sheet_T/2 - pore_depth/2 - pore_overlap])
      sphere(r=pore_radius, center=true);
    translate([sheet_L/2 - pore_margin, -sheet_W/2 + pore_margin, sheet_T/2 - pore_depth/2 - pore_overlap])
      sphere(r=pore_radius, center=true);
    translate([-sheet_L/2 + pore_margin, sheet_W/2 - pore_margin, sheet_T/2 - pore_depth/2 - pore_overlap])
      sphere(r=pore_radius, center=true);
    translate([sheet_L/2 - pore_margin, sheet_W/2 - pore_margin, sheet_T/2 - pore_depth/2 - pore_overlap])
      sphere(r=pore_radius, center=true);
    translate([0, 0, sheet_T/2 - pore_depth/2 - pore_overlap])
      sphere(r=pore_radius, center=true);
  }
}

// Corner Chamfers
module corner_chamfers() {
  union() {
    translate([sheet_L/2 - corner_chamfer/2, sheet_W/2 - corner_chamfer/2, 0])
      rotate([0, 0, 45])
      cube([corner_chamfer, corner_chamfer, sheet_T + 2*edge_radius], center=true);
    translate([-sheet_L/2 + corner_chamfer/2, sheet_W/2 - corner_chamfer/2, 0])
      rotate([0, 0, 45])
      cube([corner_chamfer, corner_chamfer, sheet_T + 2*edge_radius], center=true);
    translate([sheet_L/2 - corner_chamfer/2, -sheet_W/2 + corner_chamfer/2, 0])
      rotate([0, 0, 45])
      cube([corner_chamfer, corner_chamfer, sheet_T + 2*edge_radius], center=true);
    translate([-sheet_L/2 + corner_chamfer/2, -sheet_W/2 + corner_chamfer/2, 0])
      rotate([0, 0, 45])
      cube([corner_chamfer, corner_chamfer, sheet_T + 2*edge_radius], center=true);
  }
}

// Branding Emboss
module branding_emboss() {
  translate([0, 0, sheet_T/2 - (sheet_T/20)/2])
    cube([sheet_L/4, sheet_W/6, sheet_T/20], center=true);
}

// Foam Sheet with Rounding and Chamfers
module foam_sheet_with_chamfers() {
  difference() {
    minkowski() {
      scale([(sheet_L - 2*edge_radius - rounding_shrink)/sheet_L,
             (sheet_W - 2*edge_radius - rounding_shrink)/sheet_W,
             (sheet_T - 2*edge_radius - rounding_shrink)/sheet_T])
        foam_sheet_body();
      edge_rounding();
    }
    corner_chamfers();
  }
}

// Foam Sheet with Pores
module foam_sheet_with_pores() {
  difference() {
    foam_sheet_with_chamfers();
    surface_texture_pores();
  }
}

// Complete Model
module complete_model() {
  union() {
    foam_sheet_with_pores();
    branding_emboss();
  }
}

// Render the final model
complete_model();