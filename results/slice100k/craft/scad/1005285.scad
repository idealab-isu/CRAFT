// Parameters
bbox_x = 6.8; //[3.4:13.6:0.1]
bbox_y = 6.8; //[3.4:13.6:0.1]
bbox_z = 9.9; //[4.95:19.8:0.1]
head_d = 6.8; //[3.4:13.6:0.1]
head_r = 3.4; //[1.7:6.8:0.1]
stem_h = 3.1; //[1.55:6.2:0.1]
stem_d = 2.4; //[1.2:4.8:0.1]
stem_r = 1.2; //[0.6:2.4:0.1]
facet_fn = 12; //[6:48:1]
blend_h = 0.3; //[0.15:0.6:0.05]
blend_d1 = 2.4; //[1.2:4.8:0.1]
blend_d2 = 2.0; //[1.0:4.0:0.1]
overlap = 0.6; //[0.2:1.5:0.1]
fillet_r = 0.25; //[0.1:0.6:0.05]
facet_variation_scale = 0.985; //[0.95:1.0:0.001]

// Base Shapes
module faceted_sphere_head() {
  sphere(r=head_r, $fn=facet_fn);
}

module cylindrical_stem() {
  translate([0, 0, -bbox_z/2 + stem_h/2])
    cylinder(h=stem_h, r=stem_r, center=true);
}

module head_stem_blend_transition() {
  translate([0, 0, -bbox_z/2 + stem_h - overlap + blend_h/2])
    cylinder(h=blend_h, r1=blend_d1/2, r2=blend_d2/2, center=true);
}

module decorative_faceting_pattern_variation() {
  scale([facet_variation_scale, facet_variation_scale, facet_variation_scale])
    sphere(r=head_r, $fn=facet_fn);
}

module edge_fillets_kernel() {
  sphere(r=fillet_r);
}

// Operations
module head_with_variation() {
  intersection() {
    faceted_sphere_head();
    decorative_faceting_pattern_variation();
  }
}

module head_stem_union_raw() {
  union() {
    head_with_variation();
    cylindrical_stem();
    head_stem_blend_transition();
  }
}

// Final Output
minkowski() {
  head_stem_union_raw();
  edge_fillets_kernel();
}