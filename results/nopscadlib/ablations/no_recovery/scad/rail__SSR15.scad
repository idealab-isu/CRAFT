// Parameters
rail_length = 100.0; //[50.0:200.0:1.0]
rail_width = 15.0; //[7.5:30.0:0.5]
rail_height = 12.5; //[6.25:25.0:0.5]
hole_count = 4; //[2:10:1]
end_margin = 12.0; //[6.0:24.0:0.5]
mount_hole_d = 4.2; //[2.0:8.0:0.1]
counterbore_d = 7.5; //[4.0:14.0:0.1]
counterbore_depth = 3.0; //[1.0:6.0:0.1]
end_chamfer = 1.0; //[0.5:3.0:0.1]
edge_fillet_r = 0.8; //[0.2:2.0:0.1]
raceway_groove_r = 1.6; //[0.8:3.0:0.1]
raceway_groove_depth = 1.2; //[0.5:3.0:0.1]
raceway_groove_z = 0.0; //[-3.0:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module rail_body() {
  cube([rail_length, rail_width, rail_height], center=true);
}

module edge_fillets_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

module mount_hole_cyl_base() {
  rotate([90, 0, 0])
    cylinder(h=rail_height + 2*overlap, r=mount_hole_d/2, center=true);
}

module counterbore_cyl_base() {
  rotate([90, 0, 0])
    cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

module raceway_groove_left() {
  translate([0, -(rail_width/2 - raceway_groove_depth), raceway_groove_z])
    rotate([0, 90, 0])
      cylinder(h=rail_length + 2*overlap, r=raceway_groove_r, center=true);
}

module raceway_groove_right() {
  translate([0, (rail_width/2 - raceway_groove_depth), raceway_groove_z])
    rotate([0, 90, 0])
      cylinder(h=rail_length + 2*overlap, r=raceway_groove_r, center=true);
}

module end_chamfer_wedge_pos() {
  translate([rail_length/2 - end_chamfer/2 + overlap/2, 0, 0])
    rotate([0, 0, 45])
      cube([end_chamfer, rail_width + 2*overlap, rail_height + 2*overlap], center=true);
}

module end_chamfer_wedge_neg() {
  translate([-(rail_length/2 - end_chamfer/2 + overlap/2), 0, 0])
    rotate([0, 0, 45])
      cube([end_chamfer, rail_width + 2*overlap, rail_height + 2*overlap], center=true);
}

module engraved_markings() {
  translate([0, 0, rail_height/2 - (rail_height/40)])
    cube([rail_length/5, rail_width/5, rail_height/20], center=true);
}

// Operations
module edge_fillets() {
  minkowski() {
    rail_body();
    edge_fillets_sphere();
  }
}

module mounting_holes() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([-(rail_length/2 - end_margin) + i*(rail_length - 2*end_margin)/(hole_count-1), 0, 0])
        mount_hole_cyl_base();
    }
  }
}

module counterbores() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([-(rail_length/2 - end_margin) + i*(rail_length - 2*end_margin)/(hole_count-1), 0, rail_height/2 - (counterbore_depth + overlap)/2 + overlap/2])
        counterbore_cyl_base();
    }
  }
}

module end_chamfers() {
  union() {
    end_chamfer_wedge_pos();
    end_chamfer_wedge_neg();
  }
}

// Final Rail
difference() {
  edge_fillets();
  mounting_holes();
  counterbores();
  raceway_groove_left();
  raceway_groove_right();
  end_chamfers();
  engraved_markings();
}