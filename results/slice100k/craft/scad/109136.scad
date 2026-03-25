// Parameters
bbox_X = 35.0; //[17.5:70.0:0.1]
bbox_Y = 30.31; //[15.155:60.62:0.01]
bbox_Z = 4.0; //[2.0:8.0:0.1]
plate_thk = 3.2; //[1.6:6.4:0.1]
hex_flat_to_flat = 30.31; //[15.155:60.62:0.01]
hole_d = 8.0; //[4.0:16.0:0.1]
boss_thk = 0.8; //[0.4:1.6:0.05]
boss_r = 6.0; //[3.0:12.0:0.1]
boss_offset_x = 0.0; //[-10.0:10.0:0.1]
boss_offset_y = 0.0; //[-10.0:10.0:0.1]
boss_on_top = 1; //[0:1:1]
eps_overlap = 0.8; //[0.5:2.0:0.1]
hex_circum_r = 17.5; //[8.75:35.0:0.01]
edge_chamfer_h = 0.6; //[0.3:1.2:0.05]
edge_fillet_r = 0.4; //[0.2:1.0:0.05]
boss_blend_r = 0.6; //[0.3:1.5:0.05]

// Hexagon profile
module hex_profile() {
  polygon(points=[
    [hex_flat_to_flat/sqrt(3), 0],
    [hex_flat_to_flat/(2*sqrt(3)), hex_flat_to_flat/2],
    [-hex_flat_to_flat/(2*sqrt(3)), hex_flat_to_flat/2],
    [-hex_flat_to_flat/sqrt(3), 0],
    [-hex_flat_to_flat/(2*sqrt(3)), -hex_flat_to_flat/2],
    [hex_flat_to_flat/(2*sqrt(3)), -hex_flat_to_flat/2]
  ]);
}

// Main hex plate
module hex_plate_main_body() {
  linear_extrude(height=plate_thk)
    hex_profile();
}

// Centered through-hole
module center_through_hole() {
  translate([0, 0, plate_thk/2])
    cylinder(r=hole_d/2, h=bbox_Z + 2*eps_overlap, center=true);
}

// Localized step/boss pad
module localized_step_boss_pad_raw() {
  translate([boss_offset_x, boss_offset_y, plate_thk - (boss_thk + eps_overlap)/2])
    cylinder(r=boss_r, h=boss_thk + eps_overlap, center=true);
}

// Edge chamfer tool
module edge_chamfer_tool_top() {
  linear_extrude(height=edge_chamfer_h + eps_overlap)
    hex_profile();
}

module edge_chamfer_tool_bottom() {
  linear_extrude(height=edge_chamfer_h + eps_overlap)
    hex_profile();
}

// Edge fillet sphere
module edge_fillet_sphere() {
  sphere(r=edge_fillet_r);
}

// Boss blend sphere
module boss_blend_sphere() {
  sphere(r=boss_blend_r);
}

// Engraving mark
module engraving_mark() {
  translate([0, 0, plate_thk/2])
    cube([eps_overlap, eps_overlap, eps_overlap], center=true);
}

// Operations
module edge_chamfer_tool_top_scaled() {
  scale([(hex_flat_to_flat - 2*edge_chamfer_h)/hex_flat_to_flat, (hex_flat_to_flat - 2*edge_chamfer_h)/hex_flat_to_flat, 1])
    edge_chamfer_tool_top();
}

module edge_chamfer_tool_top_pos() {
  translate([0, 0, plate_thk - (edge_chamfer_h + eps_overlap)/2])
    edge_chamfer_tool_top_scaled();
}

module edge_chamfer_tool_bottom_scaled() {
  scale([(hex_flat_to_flat - 2*edge_chamfer_h)/hex_flat_to_flat, (hex_flat_to_flat - 2*edge_chamfer_h)/hex_flat_to_flat, 1])
    edge_chamfer_tool_bottom();
}

module edge_chamfer_tool_bottom_pos() {
  translate([0, 0, (edge_chamfer_h + eps_overlap)/2])
    edge_chamfer_tool_bottom_scaled();
}

module hex_plate_with_chamfer() {
  difference() {
    hex_plate_main_body();
    edge_chamfer_tool_top_pos();
    edge_chamfer_tool_bottom_pos();
  }
}

module hex_plate_edge_fillet() {
  minkowski() {
    hex_plate_with_chamfer();
    edge_fillet_sphere();
  }
}

module boss_blend_fillet() {
  minkowski() {
    localized_step_boss_pad_raw();
    boss_blend_sphere();
  }
}

module plate_plus_boss() {
  union() {
    hex_plate_edge_fillet();
    boss_blend_fillet();
  }
}

module plate_with_hole() {
  difference() {
    plate_plus_boss();
    center_through_hole();
  }
}

module complete_model() {
  union() {
    plate_with_hole();
    engraving_mark();
  }
}

// Final output
complete_model();