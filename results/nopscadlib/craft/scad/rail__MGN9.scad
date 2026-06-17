// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 9.0; //[4.5:18.0:0.1]
rail_H = 6.0; //[3.0:12.0:0.1]
hole_d = 3.2; //[2.0:6.0:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:0.5]
chamfer_L = 1.0; //[0.5:3.0:0.1]
fillet_r = 0.6; //[0.2:2.0:0.1]
minkowski_eps = 0.2; //[0.05:0.6:0.05]
hole_clearance_h = 2.0; //[1.0:6.0:0.5]

// Base Shapes
module rail_body_raw() {
  cube([rail_L, rail_W, rail_H], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module chamfer_cut() {
  cube([chamfer_L*2, rail_W*2, rail_H*2], center=true);
}

module mount_hole_cyl() {
  rotate([90, 0, 0])
    cylinder(h=rail_H + hole_clearance_h, r=hole_d/2, center=true);
}

// Operations
module rail_body_fillet_minkowski() {
  minkowski() {
    rail_body_raw();
    fillet_sphere();
  }
}

module chamfer_cut_pos_tx() {
  translate([rail_L/2 - chamfer_L + minkowski_eps, 0, 0])
    rotate([0, 45, 0]) chamfer_cut();
}

module chamfer_cut_neg_tx() {
  translate([-(rail_L/2 - chamfer_L + minkowski_eps), 0, 0])
    rotate([0, -45, 0]) chamfer_cut();
}

module rail_with_end_chamfers() {
  difference() {
    rail_body_fillet_minkowski();
    chamfer_cut_pos_tx();
    chamfer_cut_neg_tx();
  }
}

module mounting_holes_union() {
  union() {
    translate([-(rail_L/2 - end_margin), 0, 0]) mount_hole_cyl();
    translate([-(rail_L/2 - end_margin) + (rail_L - 2*end_margin)/3, 0, 0]) mount_hole_cyl();
    translate([-(rail_L/2 - end_margin) + 2*(rail_L - 2*end_margin)/3, 0, 0]) mount_hole_cyl();
    translate([rail_L/2 - end_margin, 0, 0]) mount_hole_cyl();
  }
}

// Final Output
difference() {
  rail_with_end_chamfers();
  mounting_holes_union();
}