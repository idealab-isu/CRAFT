// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 15.0; //[7.5:30.0:0.5]
rail_H = 15.0; //[7.5:30.0:0.5]
hole_d = 4.2; //[2.0:8.0:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:0.5]
chamfer_L = 1.5; //[0.5:4.0:0.1]
fillet_r = 0.8; //[0.2:2.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Rail Body with Edge Fillets
module rail_body_raw() {
  cube([rail_L, rail_W, rail_H], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module edge_fillets() {
  minkowski() {
    rail_body_raw();
    fillet_sphere();
  }
}

// End Chamfers
module chamfer_cut_pos() {
  translate([rail_L/2 - chamfer_L, 0, 0])
  rotate([0, 45, 0])
  cube([chamfer_L*2, rail_W*2, rail_H*2], center=true);
}

module chamfer_cut_neg() {
  translate([-rail_L/2 + chamfer_L, 0, 0])
  rotate([0, -45, 0])
  cube([chamfer_L*2, rail_W*2, rail_H*2], center=true);
}

module end_chamfers() {
  difference() {
    edge_fillets();
    chamfer_cut_pos();
    chamfer_cut_neg();
  }
}

// Mounting Holes
module mount_hole_1() {
  translate([-rail_L/2 + end_margin, 0, 0])
  rotate([90, 0, 0])
  cylinder(r=hole_d/2, h=rail_H + overlap*2, center=true);
}

module mount_hole_2() {
  translate([-rail_L/2 + end_margin + (rail_L - 2*end_margin)/3, 0, 0])
  rotate([90, 0, 0])
  cylinder(r=hole_d/2, h=rail_H + overlap*2, center=true);
}

module mount_hole_3() {
  translate([-rail_L/2 + end_margin + 2*(rail_L - 2*end_margin)/3, 0, 0])
  rotate([90, 0, 0])
  cylinder(r=hole_d/2, h=rail_H + overlap*2, center=true);
}

module mount_hole_4() {
  translate([rail_L/2 - end_margin, 0, 0])
  rotate([90, 0, 0])
  cylinder(r=hole_d/2, h=rail_H + overlap*2, center=true);
}

module mounting_holes() {
  union() {
    mount_hole_1();
    mount_hole_2();
    mount_hole_3();
    mount_hole_4();
  }
}

// Rail Body with Holes
module rail_body() {
  difference() {
    end_chamfers();
    mounting_holes();
  }
}

// Engraved Markings Placeholder
module engraved_markings_placeholder() {
  translate([0, 0, rail_H/2 - rail_H*0.01])
  cube([rail_L*0.2, rail_W*0.2, rail_H*0.02], center=true);
}

// Complete Model
module complete_model() {
  rail_body();
}

// Final Output
complete_model();