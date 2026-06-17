// Parameters
outer_radius = 13.5; //[6.75:27:0.1]
inner_radius = 10.5; //[5.25:21:0.1]
height = 3.7; //[1.85:7.4:0.1]
edge_chamfer = 0.6; //[0.3:1.2:0.05]
edge_fillet = 0.5; //[0.25:1:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module annular_outer_cyl() {
  cylinder(h=height, r=outer_radius, center=true);
}

module annular_inner_hole_cyl() {
  cylinder(h=height + 2*overlap, r=inner_radius, center=true);
}

module edge_chamfer_cut_cone() {
  translate([0, 0, height/2 - edge_chamfer + overlap/2])
    cylinder(h=edge_chamfer*2, r1=outer_radius + edge_chamfer, r2=outer_radius - edge_chamfer, center=true);
}

module edge_fillet_cut_torus() {
  translate([0, 0, -height/2 + edge_fillet - overlap/2])
    rotate_extrude() translate([outer_radius - edge_fillet, 0, 0]) circle(r=edge_fillet);
}

// Operations
module annular_body() {
  difference() {
    annular_outer_cyl();
    annular_inner_hole_cyl();
  }
}

module annular_with_chamfer() {
  difference() {
    annular_body();
    edge_chamfer_cut_cone();
  }
}

module edge_fillet() {
  difference() {
    annular_with_chamfer();
    edge_fillet_cut_torus();
  }
}

module edge_chamfer() {
  union() {
    annular_body();
    annular_with_chamfer();
  }
}

module complete_model() {
  union() {
    edge_fillet();
    edge_chamfer();
  }
}

// Final Output
complete_model();