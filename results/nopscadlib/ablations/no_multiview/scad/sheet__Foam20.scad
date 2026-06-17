// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 10; //[5:20:1]
edge_radius = 2; //[1:6:0.5]
corner_chamfer = 4; //[2:10:1]
pore_radius = 1.2; //[0.6:2.5:0.1]
pore_depth = 0.8; //[0.3:2:0.1]
pore_margin = 12; //[6:30:1]
pore_spacing_x = 30; //[15:60:1]
pore_spacing_y = 25; //[15:60:1]
overlap = 1; //[0.5:2:0.1]

// Foam Sheet Body
module foam_sheet_body() {
  color([0.85, 0.85, 0.8])
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Edge Rounding
module edge_rounding() {
  union() {
    translate([sheet_length/2 - edge_radius, 0, 0])
      rotate([90, 0, 0])
        cylinder(r=edge_radius, h=sheet_width, center=true);
    translate([-sheet_length/2 + edge_radius, 0, 0])
      rotate([90, 0, 0])
        cylinder(r=edge_radius, h=sheet_width, center=true);
    translate([0, sheet_width/2 - edge_radius, 0])
      rotate([0, 90, 0])
        cylinder(r=edge_radius, h=sheet_length, center=true);
    translate([0, -sheet_width/2 + edge_radius, 0])
      rotate([0, 90, 0])
        cylinder(r=edge_radius, h=sheet_length, center=true);
    translate([sheet_length/2 - edge_radius, sheet_width/2 - edge_radius, 0])
      cylinder(r=edge_radius, h=sheet_thickness, center=true);
    translate([sheet_length/2 - edge_radius, -sheet_width/2 + edge_radius, 0])
      cylinder(r=edge_radius, h=sheet_thickness, center=true);
    translate([-sheet_length/2 + edge_radius, sheet_width/2 - edge_radius, 0])
      cylinder(r=edge_radius, h=sheet_thickness, center=true);
    translate([-sheet_length/2 + edge_radius, -sheet_width/2 + edge_radius, 0])
      cylinder(r=edge_radius, h=sheet_thickness, center=true);
  }
}

// Corner Chamfers
module corner_chamfers() {
  union() {
    translate([sheet_length/2 - corner_chamfer/2, sheet_width/2 - corner_chamfer/2, 0])
      rotate([0, 0, 45])
        cube([corner_chamfer, corner_chamfer, sheet_thickness + 2*overlap], center=true);
    translate([sheet_length/2 - corner_chamfer/2, -sheet_width/2 + corner_chamfer/2, 0])
      rotate([0, 0, 45])
        cube([corner_chamfer, corner_chamfer, sheet_thickness + 2*overlap], center=true);
    translate([-sheet_length/2 + corner_chamfer/2, sheet_width/2 - corner_chamfer/2, 0])
      rotate([0, 0, 45])
        cube([corner_chamfer, corner_chamfer, sheet_thickness + 2*overlap], center=true);
    translate([-sheet_length/2 + corner_chamfer/2, -sheet_width/2 + corner_chamfer/2, 0])
      rotate([0, 0, 45])
        cube([corner_chamfer, corner_chamfer, sheet_thickness + 2*overlap], center=true);
  }
}

// Surface Texture Pores
module surface_texture_pores() {
  union() {
    for (x = [0:2]) {
      for (y = [0:2]) {
        translate([-sheet_length/2 + pore_margin + x*pore_spacing_x, -sheet_width/2 + pore_margin + y*pore_spacing_y, sheet_thickness/2 - pore_depth/2])
          cylinder(r=pore_radius, h=pore_depth + overlap, center=true);
      }
    }
  }
}

// Complete Model
module complete_model() {
  difference() {
    union() {
      foam_sheet_body();
      edge_rounding();
    }
    corner_chamfers();
    surface_texture_pores();
  }
}

// Render the complete model
complete_model();