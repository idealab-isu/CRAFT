// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 10; //[5:20:1]
edge_radius = 3; //[1.5:6:0.5]
corner_chamfer = 4; //[2:8:0.5]
pore_radius = 1.2; //[0.6:2.4:0.1]
pore_depth = 0.8; //[0.3:1.6:0.1]
pore_pitch_x = 18; //[10:30:1]
pore_pitch_y = 18; //[10:30:1]
pore_margin = 12; //[6:24:1]
pore_rows = 7; //[3:12:1]
pore_cols = 9; //[3:16:1]
pore_z_overlap = 0.6; //[0.3:1.2:0.1]
rounding_sphere_radius = 1.5; //[0.8:3:0.1]

// Foam Sheet with Rounded Edges and Corner Chamfers
module foam_sheet() {
  difference() {
    // Rounded edges using minkowski with a sphere
    minkowski() {
      translate([0, 0, sheet_thickness/2])
        cube([sheet_length - 2*rounding_sphere_radius, sheet_width - 2*rounding_sphere_radius, sheet_thickness - 2*rounding_sphere_radius], center=true);
      sphere(r=rounding_sphere_radius);
    }
    
    // Corner chamfers
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (sheet_length/2 - corner_chamfer/2), y * (sheet_width/2 - corner_chamfer/2), 0])
        rotate([0, 0, 45])
          cube([corner_chamfer, corner_chamfer, sheet_thickness + 2], center=true);
    }
  }
}

// Pore Texture
module pore_texture() {
  for (row = [0:pore_rows-1], col = [0:pore_cols-1]) {
    translate([
      -sheet_length/2 + pore_margin + col * pore_pitch_x,
      -sheet_width/2 + pore_margin + row * pore_pitch_y,
      sheet_thickness/2 - pore_depth/2 + pore_z_overlap
    ])
    sphere(r=pore_radius, center=true);
  }
}

// Final Foam Sheet with Surface Pore Texture
difference() {
  foam_sheet();
  pore_texture();
}