// Parameters
rail_L = 100.0; //[50.0:200.0:1.0]
rail_W = 15.0; //[7.5:30.0:0.5]
rail_H = 12.5; //[6.25:25.0:0.5]
hole_d = 3.2; //[1.6:6.4:0.1]
hole_pitch = 25.0; //[12.5:50.0:0.5]
hole_edge_offset = 7.5; //[3.75:15.0:0.5]
hole_end_offset = 12.5; //[6.25:25.0:0.5]
hole_count = 4; //[2:10:1]
counterbore_d = 6.0; //[4.0:12.0:0.1]
counterbore_depth = 2.5; //[1.0:6.0:0.1]
edge_chamfer = 0.8; //[0.2:2.0:0.1]
end_chamfer = 1.0; //[0.2:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module rail_body() {
  color("Silver")
  translate([0, 0, 0])
    cube([rail_L, rail_W, rail_H], center=true);
}

module mount_hole(x_offset) {
  translate([x_offset, hole_edge_offset - rail_W/2, 0])
    cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);
}

module counterbore(x_offset) {
  translate([x_offset, hole_edge_offset - rail_W/2, rail_H/2 - counterbore_depth/2])
    cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

module edge_chamfer_cut_ypos() {
  translate([0, rail_W/2 - edge_chamfer/2, rail_H/2 - edge_chamfer/2])
    rotate([45, 0, 0])
      cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
}

module edge_chamfer_cut_yneg() {
  translate([0, -rail_W/2 + edge_chamfer/2, rail_H/2 - edge_chamfer/2])
    rotate([-45, 0, 0])
      cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
}

module edge_chamfer_cut_zneg_ypos() {
  translate([0, rail_W/2 - edge_chamfer/2, -rail_H/2 + edge_chamfer/2])
    rotate([-45, 0, 0])
      cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
}

module edge_chamfer_cut_zneg_yneg() {
  translate([0, -rail_W/2 + edge_chamfer/2, -rail_H/2 + edge_chamfer/2])
    rotate([45, 0, 0])
      cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
}

module end_chamfer_cut_xpos_ypos() {
  translate([rail_L/2 - end_chamfer/2, 0, rail_H/2 - end_chamfer/2])
    rotate([0, 45, 0])
      cube([end_chamfer, rail_W + 2*overlap, end_chamfer], center=true);
}

module end_chamfer_cut_xpos_yneg() {
  translate([rail_L/2 - end_chamfer/2, 0, -rail_H/2 + end_chamfer/2])
    rotate([0, -45, 0])
      cube([end_chamfer, rail_W + 2*overlap, end_chamfer], center=true);
}

module end_chamfer_cut_xneg_ypos() {
  translate([-rail_L/2 + end_chamfer/2, 0, rail_H/2 - end_chamfer/2])
    rotate([0, -45, 0])
      cube([end_chamfer, rail_W + 2*overlap, end_chamfer], center=true);
}

module end_chamfer_cut_xneg_yneg() {
  translate([-rail_L/2 + end_chamfer/2, 0, -rail_H/2 + end_chamfer/2])
    rotate([0, 45, 0])
      cube([end_chamfer, rail_W + 2*overlap, end_chamfer], center=true);
}

// Operations
module mounting_holes_pattern() {
  union() {
    for (i = [0:hole_count-1]) {
      mount_hole(-rail_L/2 + hole_end_offset + i*hole_pitch);
    }
  }
}

module counterbores_or_countersinks() {
  union() {
    for (i = [0:hole_count-1]) {
      counterbore(-rail_L/2 + hole_end_offset + i*hole_pitch);
    }
  }
}

module edge_chamfers() {
  union() {
    edge_chamfer_cut_ypos();
    edge_chamfer_cut_yneg();
    edge_chamfer_cut_zneg_ypos();
    edge_chamfer_cut_zneg_yneg();
  }
}

module end_chamfers() {
  union() {
    end_chamfer_cut_xpos_ypos();
    end_chamfer_cut_xpos_yneg();
    end_chamfer_cut_xneg_ypos();
    end_chamfer_cut_xneg_yneg();
  }
}

// Final Model
difference() {
  rail_body();
  mounting_holes_pattern();
  counterbores_or_countersinks();
  edge_chamfers();
  end_chamfers();
}