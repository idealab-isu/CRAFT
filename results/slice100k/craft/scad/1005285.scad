// Parameters
bbox_x = 6.8; //[3.4:13.6:0.1]
bbox_y = 6.8; //[3.4:13.6:0.1]
bbox_z = 9.9; //[5:19.8:0.1]
sphere_d = 6.8; //[3.4:13.6:0.1]
sphere_r = 3.4; //[1.7:6.8:0.1]
stem_h = 3.1; //[1.5:6.2:0.1]
stem_d = 2.4; //[1.2:4.8:0.1]
stem_r = 1.2; //[0.6:2.4:0.1]
stem_insert = 0.6; //[0.3:1.2:0.05]
facet_fn = 10; //[6:24:1]
overlap = 0.8; //[0.5:2:0.1]
chamfer_r = 0.25; //[0.1:0.6:0.05]
sphere_center_z = 0; //[-5:5:0.1]

// Base shapes
module faceted_sphere_body() {
  translate([0, 0, sphere_center_z])
    sphere(r=sphere_r, $fn=facet_fn);
}

module cylindrical_stem() {
  translate([0, 0, sphere_center_z - sphere_r - (stem_h + stem_insert)/2 + stem_insert])
    cylinder(r=stem_r, h=stem_h + stem_insert, center=true);
}

module sphere_stem_blend_overlap() {
  translate([0, 0, sphere_center_z - sphere_r + stem_insert - overlap/2])
    sphere(r=stem_r + overlap/2, center=true);
}

module small_edge_chamfer() {
  sphere(r=chamfer_r, center=true);
}

// Operations
module op_union_raw() {
  union() {
    faceted_sphere_body();
    cylindrical_stem();
    sphere_stem_blend_overlap();
  }
}

module op_facet_control_scale() {
  scale([bbox_x/sphere_d, bbox_y/sphere_d, bbox_z/(sphere_d + stem_h)])
    op_union_raw();
}

module op_small_edge_chamfer_minkowski() {
  minkowski() {
    op_facet_control_scale();
    small_edge_chamfer();
  }
}

// Final output
op_small_edge_chamfer_minkowski();