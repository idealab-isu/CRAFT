// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 7.0; //[3.5:14.0:0.1]
rail_H = 5.0; //[2.5:10.0:0.1]
edge_fillet_r = 0.4; //[0.2:1.0:0.05]
chamfer_L = 1.0; //[0.5:3.0:0.1]
hole_d = 3.0; //[1.5:4.5:0.1]
hole_count = 4; //[2:8:1]
hole_edge_margin = 10.0; //[5.0:20.0:0.5]
hole_z_from_bottom = 2.5; //[1.0:4.0:0.1]
groove_W = 2.0; //[1.0:4.0:0.1]
groove_D = 1.0; //[0.5:2.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Base Shapes
module rail_body_raw() {
  translate([0, 0, 0])
    cube([rail_L, rail_W, rail_H], center=true);
}

module fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=edge_fillet_r, center=true);
}

module chamfer_wedge_base() {
  translate([0, 0, 0])
    cube([chamfer_L, rail_W + 2*eps, rail_H + 2*eps], center=true);
}

module chamfer_wedge_cut() {
  translate([chamfer_L/2, 0, 0])
    rotate([0, 45, 0])
      cube([2*chamfer_L, rail_W + 4*eps, 2*(rail_H + 4*eps)], center=true);
}

module mount_hole_cyl() {
  translate([0, 0, -rail_H/2 + hole_z_from_bottom])
    rotate([90, 0, 0])
      cylinder(r=hole_d/2, h=rail_W + 4*eps, center=true);
}

module center_groove_box() {
  translate([0, 0, rail_H/2 - groove_D/2])
    cube([rail_L + 2*eps, groove_W, groove_D + eps], center=true);
}

// Operations
module edge_fillets() {
  minkowski() {
    rail_body_raw();
    fillet_sphere();
  }
}

module chamfer_wedge() {
  difference() {
    chamfer_wedge_base();
    chamfer_wedge_cut();
  }
}

module end_chamfers() {
  union() {
    translate([rail_L/2 - chamfer_L/2 + overlap, 0, 0])
      chamfer_wedge();
    translate([-rail_L/2 + chamfer_L/2 - overlap, 0, 0])
      chamfer_wedge();
  }
}

module rail_with_end_chamfers() {
  difference() {
    edge_fillets();
    end_chamfers();
  }
}

module mounting_holes() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([-rail_L/2 + hole_edge_margin + (rail_L - 2*hole_edge_margin) * (i/(hole_count-1)), 0, 0])
        mount_hole_cyl();
    }
  }
}

module rail_with_holes() {
  difference() {
    rail_with_end_chamfers();
    mounting_holes();
  }
}

module center_groove_or_profile_details() {
  difference() {
    rail_with_holes();
    center_groove_box();
  }
}

// Final Output
color("DimGray")
center_groove_or_profile_details();