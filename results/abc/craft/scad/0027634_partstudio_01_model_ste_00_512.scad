// Parameters
bb_x = 0.07; //[0.035:0.14:0.001]
bb_y = 0.07; //[0.035:0.14:0.001]
bb_z = 0.04; //[0.02:0.08:0.001]
plate_thk = 0.012; //[0.006:0.024:0.001]
plate_size = 0.07; //[0.035:0.14:0.001]
side_concave_depth = 0.006; //[0.003:0.012:0.001]
corner_radius = 0.004; //[0.002:0.008:0.001]
hole_d = 0.006; //[0.003:0.012:0.001]
hole_edge_offset = 0.012; //[0.006:0.024:0.001]
boss_d = 0.03; //[0.015:0.06:0.001]
boss_h = 0.02; //[0.01:0.04:0.001]
hex_flat_to_flat = 0.012; //[0.006:0.024:0.001]
hex_h = 0.008; //[0.004:0.016:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
countersink_d = 0.01; //[0.006:0.02:0.001]
countersink_depth = 0.004; //[0.002:0.008:0.001]
boss_blend_r = 0.003; //[0.0015:0.006:0.0005]
edge_chamfer = 0.0015; //[0.0005:0.003:0.0005]

// Base Shapes
module plate_base_box() {
  translate([0, 0, plate_thk/2])
    cube([plate_size, plate_size, plate_thk], center=true);
}

module concave_cut_x_pos() {
  translate([plate_size/2 + plate_size - side_concave_depth, 0, plate_thk/2])
    cylinder(r=plate_size, h=plate_thk + 2*overlap, center=true);
}

module concave_cut_x_neg() {
  translate([-(plate_size/2 + plate_size - side_concave_depth), 0, plate_thk/2])
    cylinder(r=plate_size, h=plate_thk + 2*overlap, center=true);
}

module concave_cut_y_pos() {
  translate([0, plate_size/2 + plate_size - side_concave_depth, plate_thk/2])
    cylinder(r=plate_size, h=plate_thk + 2*overlap, center=true);
}

module concave_cut_y_neg() {
  translate([0, -(plate_size/2 + plate_size - side_concave_depth), plate_thk/2])
    cylinder(r=plate_size, h=plate_thk + 2*overlap, center=true);
}

module corner_cut_pp() {
  translate([plate_size/2 - corner_radius, plate_size/2 - corner_radius, plate_thk/2])
    cylinder(r=corner_radius, h=plate_thk + 2*overlap, center=true);
}

module corner_cut_pn() {
  translate([plate_size/2 - corner_radius, -(plate_size/2 - corner_radius), plate_thk/2])
    cylinder(r=corner_radius, h=plate_thk + 2*overlap, center=true);
}

module corner_cut_np() {
  translate([-(plate_size/2 - corner_radius), plate_size/2 - corner_radius, plate_thk/2])
    cylinder(r=corner_radius, h=plate_thk + 2*overlap, center=true);
}

module corner_cut_nn() {
  translate([-(plate_size/2 - corner_radius), -(plate_size/2 - corner_radius), plate_thk/2])
    cylinder(r=corner_radius, h=plate_thk + 2*overlap, center=true);
}

module hole_pp() {
  translate([plate_size/2 - hole_edge_offset, plate_size/2 - hole_edge_offset, plate_thk/2])
    cylinder(r=hole_d/2, h=plate_thk + 2*overlap, center=true);
}

module hole_pn() {
  translate([plate_size/2 - hole_edge_offset, -(plate_size/2 - hole_edge_offset), plate_thk/2])
    cylinder(r=hole_d/2, h=plate_thk + 2*overlap, center=true);
}

module hole_np() {
  translate([-(plate_size/2 - hole_edge_offset), plate_size/2 - hole_edge_offset, plate_thk/2])
    cylinder(r=hole_d/2, h=plate_thk + 2*overlap, center=true);
}

module hole_nn() {
  translate([-(plate_size/2 - hole_edge_offset), -(plate_size/2 - hole_edge_offset), plate_thk/2])
    cylinder(r=hole_d/2, h=plate_thk + 2*overlap, center=true);
}

module countersink_pp() {
  translate([plate_size/2 - hole_edge_offset, plate_size/2 - hole_edge_offset, plate_thk - countersink_depth/2])
    cylinder(r=countersink_d/2, h=countersink_depth + overlap, center=true);
}

module countersink_pn() {
  translate([plate_size/2 - hole_edge_offset, -(plate_size/2 - hole_edge_offset), plate_thk - countersink_depth/2])
    cylinder(r=countersink_d/2, h=countersink_depth + overlap, center=true);
}

module countersink_np() {
  translate([-(plate_size/2 - hole_edge_offset), plate_size/2 - hole_edge_offset, plate_thk - countersink_depth/2])
    cylinder(r=countersink_d/2, h=countersink_depth + overlap, center=true);
}

module countersink_nn() {
  translate([-(plate_size/2 - hole_edge_offset), -(plate_size/2 - hole_edge_offset), plate_thk - countersink_depth/2])
    cylinder(r=countersink_d/2, h=countersink_depth + overlap, center=true);
}

module center_boss_cylinder() {
  translate([0, 0, plate_thk + boss_h/2 - overlap])
    cylinder(r=boss_d/2, h=boss_h, center=true);
}

module boss_blend_frustum() {
  translate([0, 0, plate_thk + boss_blend_r - overlap])
    cylinder(r1=boss_d/2 + boss_blend_r, r2=boss_d/2, h=boss_blend_r*2, center=true);
}

module central_hex_drive_protrusion() {
  translate([0, 0, plate_thk + boss_h - hex_h/2 - overlap])
    linear_extrude(height=hex_h, center=true)
      polygon(points=[
        [hex_flat_to_flat/2, 0],
        [hex_flat_to_flat/4, hex_flat_to_flat*0.4330127019],
        [-hex_flat_to_flat/4, hex_flat_to_flat*0.4330127019],
        [-hex_flat_to_flat/2, 0],
        [-hex_flat_to_flat/4, -hex_flat_to_flat*0.4330127019],
        [hex_flat_to_flat/4, -hex_flat_to_flat*0.4330127019]
      ]);
}

module surface_marking_ring() {
  translate([0, 0, plate_thk + boss_h - overlap])
    rotate_extrude()
      translate([boss_d/2 - boss_d*0.15, 0])
        circle(r=0.001);
}

// Operations
module plate_minus_concave() {
  difference() {
    plate_base_box();
    concave_cut_x_pos();
    concave_cut_x_neg();
    concave_cut_y_pos();
    concave_cut_y_neg();
  }
}

module plate_minus_concave_and_corners() {
  difference() {
    plate_minus_concave();
    corner_cut_pp();
    corner_cut_pn();
    corner_cut_np();
    corner_cut_nn();
  }
}

module plate_minus_holes() {
  difference() {
    plate_minus_concave_and_corners();
    hole_pp();
    hole_pn();
    hole_np();
    hole_nn();
  }
}

module plate_minus_holes_and_countersinks() {
  difference() {
    plate_minus_holes();
    countersink_pp();
    countersink_pn();
    countersink_np();
    countersink_nn();
  }
}

module plate_with_boss_and_blend() {
  union() {
    plate_minus_holes_and_countersinks();
    boss_blend_frustum();
    center_boss_cylinder();
  }
}

module complete_model() {
  union() {
    plate_with_boss_and_blend();
    central_hex_drive_protrusion();
    surface_marking_ring();
  }
}

// Final Output
complete_model();