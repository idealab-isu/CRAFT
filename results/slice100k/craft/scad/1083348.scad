// Parameters
bbox_X = 22.0; //[11.0:44.0:0.01]
bbox_Y = 18.99; //[9.5:38.0:0.01]
H = 82.5; //[41.25:165.0:0.1]
OD_x = 18.99; //[9.5:38.0:0.01]
OD_y = 18.99; //[9.5:38.0:0.01]
ID_x = 12.0; //[6.0:24.0:0.01]
ID_y = 12.0; //[6.0:24.0:0.01]
lug_len_radial = 3.01; //[1.5:6.02:0.01]
lug_w_tangential = 8.0; //[4.0:16.0:0.01]
lug_h_axial = 12.0; //[6.0:24.0:0.01]
lug_z_center = 0.0; //[-41.25:41.25:0.01]
overlap = 1.0; //[0.5:2.0:0.1]
chamfer_size = 0.8; //[0.4:1.6:0.05]
fillet_r = 0.6; //[0.3:1.2:0.05]
lug_round_r = 0.8; //[0.4:1.6:0.05]

// Base Shapes
module annular_sleeve_outer() {
  cylinder(h=H, r=OD_x/2, center=true);
}

module through_bore() {
  cylinder(h=H + 2*overlap, r=ID_x/2, center=true);
}

module radial_rectangular_lug() {
  translate([OD_x/2 + (lug_len_radial + overlap)/2 - overlap, 0, lug_z_center])
    cube([lug_len_radial + overlap, lug_w_tangential, lug_h_axial], center=true);
}

module edge_chamfer_outer_top() {
  translate([0, 0, H/2 - chamfer_size/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_size, r1=OD_x/2, r2=0, center=true);
}

module edge_chamfer_outer_bottom() {
  translate([0, 0, -H/2 + chamfer_size/2])
    cylinder(h=chamfer_size, r1=OD_x/2, r2=0, center=true);
}

module edge_chamfer_inner_top() {
  translate([0, 0, H/2 - chamfer_size/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_size, r1=ID_x/2 + chamfer_size, r2=0, center=true);
}

module edge_chamfer_inner_bottom() {
  translate([0, 0, -H/2 + chamfer_size/2])
    cylinder(h=chamfer_size, r1=ID_x/2 + chamfer_size, r2=0, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module lug_round_sphere() {
  sphere(r=lug_round_r, center=true);
}

// Operations
module annular_sleeve_body() {
  difference() {
    annular_sleeve_outer();
    through_bore();
  }
}

module sleeve_plus_lug_sharp() {
  union() {
    annular_sleeve_body();
    radial_rectangular_lug();
  }
}

module edge_chamfers() {
  difference() {
    sleeve_plus_lug_sharp();
    edge_chamfer_outer_top();
    edge_chamfer_outer_bottom();
    edge_chamfer_inner_top();
    edge_chamfer_inner_bottom();
  }
}

module edge_fillets() {
  minkowski() {
    edge_chamfers();
    fillet_sphere();
  }
}

module lug_corner_rounding() {
  minkowski() {
    edge_fillets();
    lug_round_sphere();
  }
}

// Final Output
lug_corner_rounding();