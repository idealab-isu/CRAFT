// Dimension-calibrated (target: 0.08 x 0.06 x 0.04 mm)
scale([0.001019, 0.001025, 0.000984])
{
// Parameters
L = 80; //[40:160:1]
W = 60; //[30:120:1]
T = 40; //[20:80:1]
hex_flat_to_flat = 18; //[9:36:1]
hex_center_x = 18; //[9:36:1]
hex_center_y = 30; //[15:45:1]
min_edge_margin = 6; //[3:12:1]
neck_width = 28; //[14:56:1]
small_lobe_length = 28; //[14:56:1]
large_lobe_length = 52; //[26:104:1]
large_lobe_max_width = 60; //[30:120:1]
outline_corner_chamfer = 4; //[2:8:1]
eps_overlap = 1; //[0.5:2:0.5]
edge_fillet_approx = 2; //[1:4:0.5]

// Helper function to create a hexagon
module hexagon(size) {
  polygon(points=[
    [size/2, 0],
    [size/4, size*0.4330127019],
    [-size/4, size*0.4330127019],
    [-size/2, 0],
    [-size/4, -size*0.4330127019],
    [size/4, -size*0.4330127019]
  ]);
}

// Base shapes
module plate_body_two_lobe_outline() {
  linear_extrude(height=T, center=true)
    polygon(points=[
      [outline_corner_chamfer, W/2 - neck_width/2 + outline_corner_chamfer],
      [small_lobe_length - outline_corner_chamfer, W/2 - neck_width/2 + outline_corner_chamfer],
      [small_lobe_length + outline_corner_chamfer, W/2 - neck_width/2 + 2*outline_corner_chamfer],
      [L - large_lobe_length - outline_corner_chamfer, W/2 - large_lobe_max_width/2 + outline_corner_chamfer],
      [L - outline_corner_chamfer, W/2 - large_lobe_max_width/2 + 2*outline_corner_chamfer],
      [L - outline_corner_chamfer, W/2 + large_lobe_max_width/2 - 2*outline_corner_chamfer],
      [L - large_lobe_length + outline_corner_chamfer, W/2 + large_lobe_max_width/2 - outline_corner_chamfer],
      [small_lobe_length + outline_corner_chamfer, W/2 + neck_width/2 - 2*outline_corner_chamfer],
      [small_lobe_length - outline_corner_chamfer, W/2 + neck_width/2 - outline_corner_chamfer],
      [outline_corner_chamfer, W/2 + neck_width/2 - outline_corner_chamfer],
      [0, W/2 + neck_width/2 - 2*outline_corner_chamfer],
      [0, W/2 - neck_width/2 + 2*outline_corner_chamfer]
    ]);
}

module necked_transition_between_lobes() {
  translate([small_lobe_length, W/2, 0])
    cube([2*outline_corner_chamfer + eps_overlap, neck_width, T], center=true);
}

module through_hex_hole() {
  translate([hex_center_x, hex_center_y, 0])
    linear_extrude(height=T, center=true)
      hexagon(hex_flat_to_flat);
}

module engraving_or_marking() {
  translate([L/2, W/2, 0])
    cube([eps_overlap, eps_overlap, eps_overlap], center=true);
}

module edge_fillet_approximation() {
  sphere(r=edge_fillet_approx, center=true);
}

// Operations
module union_outline_with_neck() {
  union() {
    plate_body_two_lobe_outline();
    necked_transition_between_lobes();
  }
}

module plate_minus_hex_hole() {
  difference() {
    union_outline_with_neck();
    through_hex_hole();
  }
}

module edge_fillet_approximation_minkowski() {
  minkowski() {
    plate_minus_hex_hole();
    edge_fillet_approximation();
  }
}

module final_union_no_text() {
  union() {
    edge_fillet_approximation_minkowski();
    engraving_or_marking();
  }
}

// Final output
final_union_no_text();
}
