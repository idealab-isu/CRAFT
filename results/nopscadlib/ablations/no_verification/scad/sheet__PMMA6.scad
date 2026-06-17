// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
edge_chamfer = 0.8; //[0.3:2:0.1]
edge_fillet = 0.6; //[0.2:2:0.1]
texture_depth = 0.2; //[0.05:0.6:0.05]
texture_pitch = 20; //[10:40:1]
texture_dimple_radius = 3; //[1.5:6:0.5]
texture_border_margin = 10; //[5:25:1]
op_overlap = 1; //[0.5:2:0.1]

// Base shapes
module sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness + op_overlap, center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + op_overlap, center=true);
}

module chamfer_edges() {
  translate([0, 0, sheet_thickness/2 - edge_chamfer/2])
    cube([sheet_length - 2*edge_chamfer, sheet_width - 2*edge_chamfer, edge_chamfer], center=true);
}

module surface_texture(pos) {
  translate(pos)
    cylinder(r=texture_dimple_radius, h=texture_depth + op_overlap, center=true);
}

module fillet_edges() {
  sphere(r=edge_fillet, center=true);
}

// Operations
module final_geometry() {
  difference() {
    union() {
      sheet_body();
      rounded_corner([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
      rounded_corner([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
      rounded_corner([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
      rounded_corner([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
    }
    mounting_hole([sheet_length/2 - hole_edge_margin, sheet_width/2 - hole_edge_margin, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_margin, sheet_width/2 - hole_edge_margin, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_margin, -sheet_width/2 + hole_edge_margin, 0]);
    mounting_hole([sheet_length/2 - hole_edge_margin, -sheet_width/2 + hole_edge_margin, 0]);
    chamfer_edges();
    surface_texture([0, 0, sheet_thickness/2 - texture_depth/2]);
    surface_texture([texture_pitch, 0, sheet_thickness/2 - texture_depth/2]);
    surface_texture([-texture_pitch, 0, sheet_thickness/2 - texture_depth/2]);
    surface_texture([0, texture_pitch, sheet_thickness/2 - texture_depth/2]);
    surface_texture([0, -texture_pitch, sheet_thickness/2 - texture_depth/2]);
    surface_texture([texture_pitch, texture_pitch, sheet_thickness/2 - texture_depth/2]);
    surface_texture([-texture_pitch, texture_pitch, sheet_thickness/2 - texture_depth/2]);
    surface_texture([-texture_pitch, -texture_pitch, sheet_thickness/2 - texture_depth/2]);
    surface_texture([texture_pitch, -texture_pitch, sheet_thickness/2 - texture_depth/2]);
  }
}

// Final output
minkowski() {
  final_geometry();
  fillet_edges();
}