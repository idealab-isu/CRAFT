// Parameters
bbox_x = 0.01; //[0.005:0.02:0.0001]
bbox_y = 0.01; //[0.005:0.02:0.0001]
bbox_z = 0.01; //[0.005:0.02:0.0001]
block_x = 0.01; //[0.005:0.02:0.0001]
block_y = 0.01; //[0.005:0.02:0.0001]
block_z = 0.008; //[0.004:0.016:0.0001]
boss_d = 0.004; //[0.002:0.008:0.0001]
boss_h = 0.002; //[0.001:0.004:0.0001]
connect_overlap = 0.0005; //[0.0001:0.001:0.0001]
fillet_r = 0.0005; //[0.0001:0.001:0.0001]
chamfer_d = 0.0005; //[0.0001:0.001:0.0001]

// Base shapes
module block() {
  translate([0, 0, 0])
    cube([block_x, block_y, block_z], center=true);
}

module cylindrical_boss() {
  translate([0, 0, block_z/2 + boss_h/2 - connect_overlap])
    cylinder(h=boss_h, r=boss_d/2, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module chamfer_wedge_xp() {
  translate([block_x/2 - chamfer_d/2, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer_d, block_y + 2*chamfer_d, block_z + 2*chamfer_d], center=true);
}

module chamfer_wedge_xn() {
  translate([-block_x/2 + chamfer_d/2, 0, 0])
    rotate([0, -45, 0])
      cube([chamfer_d, block_y + 2*chamfer_d, block_z + 2*chamfer_d], center=true);
}

module chamfer_wedge_yp() {
  translate([0, block_y/2 - chamfer_d/2, 0])
    rotate([45, 0, 0])
      cube([block_x + 2*chamfer_d, chamfer_d, block_z + 2*chamfer_d], center=true);
}

module chamfer_wedge_yn() {
  translate([0, -block_y/2 + chamfer_d/2, 0])
    rotate([-45, 0, 0])
      cube([block_x + 2*chamfer_d, chamfer_d, block_z + 2*chamfer_d], center=true);
}

// Operations
module union_block_and_boss() {
  union() {
    block();
    cylindrical_boss();
  }
}

module edge_fillets() {
  minkowski() {
    union_block_and_boss();
    fillet_sphere();
  }
}

module chamfers() {
  difference() {
    edge_fillets();
    chamfer_wedge_xp();
    chamfer_wedge_xn();
    chamfer_wedge_yp();
    chamfer_wedge_yn();
  }
}

// Final output
chamfers();