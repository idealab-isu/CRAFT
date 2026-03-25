// Parameters
H = 82.5; //[41.25:165:0.1]
OD_x = 22; //[11:44:0.01]
OD_y = 18.99; //[9.495:37.98:0.01]
ID_x = 14; //[7:28:0.01]
ID_y = 12.5; //[6.25:25:0.01]
lug_len_radial = 3; //[1.5:6:0.01]
lug_w_tangential = 6; //[3:12:0.01]
lug_h_axial = 12; //[6:24:0.01]
lug_z_center = 0; //[-41.25:41.25:0.01]
overlap = 1; //[0.5:2:0.1]
chamfer = 0.8; //[0.4:1.6:0.1]
fillet_r = 0.6; //[0.3:1.2:0.1]
lug_taper_len = 1.2; //[0.6:2.4:0.1]
mark_r = 0.7; //[0.35:1.4:0.05]
mark_depth = 0.5; //[0.25:1:0.05]

// Base Shapes
module outer_cyl() {
  cylinder(h=H, r=OD_y/2, center=true);
}

module inner_cyl() {
  cylinder(h=H + 2*overlap, r=ID_y/2, center=true);
}

module lug_block_raw() {
  cube([lug_len_radial, lug_w_tangential, lug_h_axial], center=true);
}

module lug_taper_wedge() {
  linear_extrude(height=lug_w_tangential + 2*overlap, center=true) {
    polygon(points=[
      [-(lug_len_radial/2 + overlap), -(lug_h_axial/2 + overlap)],
      [(lug_len_radial/2 + overlap), -(lug_h_axial/2 + overlap)],
      [(lug_len_radial/2 + overlap), (lug_h_axial/2 + overlap)],
      [(lug_len_radial/2 + overlap - lug_taper_len), (lug_h_axial/2 + overlap)]
    ]);
  }
}

module chamfer_cone_top() {
  cylinder(h=2*chamfer, r1=OD_y/2, r2=0, center=true);
}

module chamfer_cone_bottom() {
  rotate([180, 0, 0]) cylinder(h=2*chamfer, r1=OD_y/2, r2=0, center=true);
}

module indexing_mark_sphere() {
  sphere(r=mark_r, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module outer_scale_x() {
  scale([(OD_x - lug_len_radial)/OD_y, 1, 1]) outer_cyl();
}

module inner_scale_x() {
  scale([ID_x/ID_y, 1, 1]) inner_cyl();
}

module annular_sleeve_body() {
  difference() {
    outer_scale_x();
    inner_scale_x();
  }
}

module lug_positioned() {
  translate([((OD_x - lug_len_radial)/2) + (lug_len_radial/2) - overlap, 0, lug_z_center])
    lug_block_raw();
}

module lug_taper_wedge_positioned() {
  translate([((OD_x - lug_len_radial)/2) + (lug_len_radial/2) - overlap, 0, lug_z_center])
    lug_taper_wedge();
}

module radial_rectangular_lug() {
  difference() {
    lug_positioned();
    lug_taper_wedge_positioned();
  }
}

module body_with_lug() {
  union() {
    annular_sleeve_body();
    radial_rectangular_lug();
  }
}

module chamfer_top_pos() {
  translate([0, 0, H/2 - chamfer]) chamfer_cone_top();
}

module chamfer_bottom_pos() {
  translate([0, 0, -H/2 + chamfer]) chamfer_cone_bottom();
}

module edge_chamfers() {
  difference() {
    body_with_lug();
    chamfer_top_pos();
    chamfer_bottom_pos();
  }
}

module indexing_mark_pos() {
  translate([((OD_x - lug_len_radial)/2) - mark_depth, 0, H/2 - (mark_r + overlap)])
    indexing_mark_sphere();
}

module indexing_mark() {
  difference() {
    edge_chamfers();
    indexing_mark_pos();
  }
}

module edge_fillets() {
  minkowski() {
    indexing_mark();
    fillet_sphere();
  }
}

// Final Output
edge_fillets();