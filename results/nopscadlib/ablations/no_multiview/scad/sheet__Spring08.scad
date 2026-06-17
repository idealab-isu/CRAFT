// Parameters
blade_L = 300; //[150:600:1]
blade_W = 25; //[12.5:50:1]
blade_T = 0.9; //[0.45:1.8:0.05]
tooth_pitch = 2.5; //[1.25:5:0.1]
tooth_H = 1.2; //[0.6:2.4:0.1]
tooth_tip_angle = 60; //[30:90:1]
tooth_set_offset = 0.2; //[0:0.6:0.05]
end_round_R = 3; //[1.5:6:0.5]
mount_hole_d = 6; //[3:12:0.5]
mount_hole_edge_margin = 10; //[5:20:1]
mount_hole_y_offset = 0; //[-5:5:0.5]
bimetal_step_depth = 0.15; //[0.05:0.4:0.05]
bimetal_band_W = 6; //[3:12:0.5]
edge_chamfer = 0.3; //[0:1:0.05]
fillet_R_visual = 1.0; //[0:3:0.25]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module blade_body_sheet() {
  cube([blade_L, blade_W, blade_T], center=true);
}

module blade_end_shape_left() {
  rotate([90, 0, 0])
    translate([-blade_L/2 + end_round_R, 0, 0])
      cylinder(r=end_round_R, h=blade_T, center=true);
}

module blade_end_shape_right() {
  rotate([90, 0, 0])
    translate([blade_L/2 - end_round_R, 0, 0])
      cylinder(r=end_round_R, h=blade_T, center=true);
}

module tooth_pattern_repeat() {
  linear_extrude(height=blade_T, center=true) {
    polygon(points=[
      [-tooth_pitch/2, 0],
      [0, tooth_H],
      [tooth_pitch/2, 0]
    ]);
  }
}

module mounting_hole_left() {
  translate([-blade_L/2 + mount_hole_edge_margin, mount_hole_y_offset, 0])
    cylinder(r=mount_hole_d/2, h=blade_T + 2*overlap, center=true);
}

module mounting_hole_right() {
  translate([blade_L/2 - mount_hole_edge_margin, mount_hole_y_offset, 0])
    cylinder(r=mount_hole_d/2, h=blade_T + 2*overlap, center=true);
}

module bi_metal_material_boundary_visual_step() {
  translate([0, blade_W/2 - bimetal_band_W/2, blade_T/2 - bimetal_step_depth/2])
    cube([blade_L, bimetal_band_W, bimetal_step_depth], center=true);
}

module edge_chamfers_top_cut() {
  translate([0, 0, blade_T/2 - (edge_chamfer + overlap)/2])
    cube([blade_L + 2*overlap, blade_W - 2*edge_chamfer, edge_chamfer + overlap], center=true);
}

module edge_chamfers_bottom_cut() {
  translate([0, 0, -blade_T/2 + (edge_chamfer + overlap)/2])
    cube([blade_L + 2*overlap, blade_W - 2*edge_chamfer, edge_chamfer + overlap], center=true);
}

module corner_fillets_visual_left() {
  rotate([90, 0, 0])
    translate([-blade_L/2 + fillet_R_visual, 0, 0])
      cylinder(r=fillet_R_visual, h=blade_T, center=true);
}

module corner_fillets_visual_right() {
  rotate([90, 0, 0])
    translate([blade_L/2 - fillet_R_visual, 0, 0])
      cylinder(r=fillet_R_visual, h=blade_T, center=true);
}

module brand_markings() {
  translate([0, 0, blade_T/2 - blade_T/20])
    cube([blade_L/4, blade_W/3, blade_T/10], center=true);
}

// Operations
module blade_end_shape() {
  union() {
    blade_end_shape_left();
    blade_end_shape_right();
  }
}

module corner_fillets() {
  union() {
    corner_fillets_visual_left();
    corner_fillets_visual_right();
  }
}

module blade_outline_union() {
  union() {
    blade_body_sheet();
    blade_end_shape();
    corner_fillets();
  }
}

module toothed_cutting_edge() {
  union() {
    for (i = [0:99]) {
      translate([-blade_L/2 + tooth_pitch/2 + i*tooth_pitch, blade_W/2 - overlap, 0])
        rotate([90, 0, 0])
          tooth_pattern_repeat();
    }
  }
}

module blade_with_teeth_and_step() {
  union() {
    blade_outline_union();
    toothed_cutting_edge();
    bi_metal_material_boundary_visual_step();
  }
}

module mounting_holes() {
  union() {
    mounting_hole_left();
    mounting_hole_right();
  }
}

module blade_minus_holes() {
  difference() {
    blade_with_teeth_and_step();
    mounting_holes();
  }
}

module edge_chamfers() {
  difference() {
    blade_minus_holes();
    edge_chamfers_top_cut();
    edge_chamfers_bottom_cut();
  }
}

module complete_model() {
  union() {
    edge_chamfers();
    brand_markings();
  }
}

// Final Output
complete_model();