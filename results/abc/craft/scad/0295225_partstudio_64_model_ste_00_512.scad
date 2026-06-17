// Parameters
bbox_x = 0.07; //[0.035:0.14:0.001]
bbox_y = 0.07; //[0.035:0.14:0.001]
bbox_z = 0.04; //[0.02:0.08:0.001]
outer_d_top = 0.07; //[0.035:0.14:0.001]
outer_d_bottom = 0.045; //[0.0225:0.09:0.001]
outer_h = 0.04; //[0.02:0.08:0.001]
wall_t = 0.006; //[0.003:0.012:0.0005]
rim_h = 0.006; //[0.003:0.012:0.0005]
rim_overhang = 0.002; //[0.001:0.004:0.0005]
cavity_depth = 0.032; //[0.016:0.064:0.001]
cavity_d_top = 0.056; //[0.028:0.112:0.001]
cavity_round_r = 0.028; //[0.014:0.056:0.001]
facet_count = 12; //[6:36:1]
notch_w = 0.012; //[0.006:0.024:0.001]
notch_h = 0.008; //[0.004:0.016:0.001]
notch_depth = 0.006; //[0.003:0.012:0.001]
notch_z_from_top = 0.004; //[0.002:0.008:0.001]
eps_overlap = 0.001; //[0.0005:0.002:0.0005]
chamfer_z = 0.0015; //[0.0005:0.003:0.0005]
micro_fillet_r = 0.001; //[0.0005:0.002:0.0005]

// Base Shapes
module outer_body_tapered_shell() {
  translate([0, 0, 0])
    cylinder(h=outer_h, r1=outer_d_top/2, r2=outer_d_bottom/2, center=true);
}

module rim_lip_outer() {
  translate([0, 0, outer_h/2 - rim_h/2])
    cylinder(h=rim_h, r=outer_d_top/2 + rim_overhang, center=true);
}

module rim_lip_inner_cut() {
  translate([0, 0, outer_h/2 - rim_h/2])
    cylinder(h=rim_h + eps_overlap*2, r=outer_d_top/2 - wall_t, center=true);
}

module inner_cavity_bowl_sphere() {
  translate([0, 0, outer_h/2 - cavity_depth + cavity_round_r])
    sphere(r=cavity_round_r);
}

module inner_cavity_bowl_cone() {
  translate([0, 0, outer_h/2 - cavity_depth/2])
    cylinder(h=cavity_depth, r1=cavity_d_top/2, r2=0, center=true);
}

module notch_cutout_posx() {
  translate([outer_d_top/2 + rim_overhang - (notch_depth/2) + eps_overlap, 0, outer_h/2 - notch_z_from_top])
    cube([notch_depth + eps_overlap*2, notch_w, notch_h], center=true);
}

module notch_cutout_negx() {
  translate([-(outer_d_top/2 + rim_overhang - (notch_depth/2) + eps_overlap), 0, outer_h/2 - notch_z_from_top])
    cube([notch_depth + eps_overlap*2, notch_w, notch_h], center=true);
}

module facet_box(angle) {
  rotate([0, 0, angle])
    cube([outer_d_top + rim_overhang*2, outer_d_top*0.55, outer_h + eps_overlap*2], center=true);
}

module chamfer_top_cone() {
  translate([0, 0, outer_h/2 - chamfer_z/2])
    cylinder(h=chamfer_z, r1=outer_d_top/2 + rim_overhang, r2=outer_d_top/2 + rim_overhang - wall_t, center=true);
}

module chamfer_bottom_cone() {
  translate([0, 0, -outer_h/2 + chamfer_z/2])
    cylinder(h=chamfer_z, r1=outer_d_bottom/2, r2=outer_d_bottom/2 - wall_t, center=true);
}

module micro_fillet_sphere() {
  sphere(r=micro_fillet_r);
}

// Operations
module rim_lip() {
  difference() {
    rim_lip_outer();
    rim_lip_inner_cut();
  }
}

module outer_body_with_rim() {
  union() {
    outer_body_tapered_shell();
    rim_lip();
  }
}

module inner_cavity_bowl() {
  union() {
    inner_cavity_bowl_cone();
    inner_cavity_bowl_sphere();
  }
}

module opposing_rim_notches() {
  union() {
    notch_cutout_posx();
    notch_cutout_negx();
  }
}

module body_minus_cavity() {
  difference() {
    outer_body_with_rim();
    inner_cavity_bowl();
  }
}

module body_minus_cavity_and_notches() {
  difference() {
    body_minus_cavity();
    opposing_rim_notches();
  }
}

module decorative_facet_pattern_variation() {
  intersection() {
    facet_box(0);
    facet_box(360/12);
    facet_box(2*360/12);
    facet_box(3*360/12);
    facet_box(4*360/12);
    facet_box(5*360/12);
  }
}

module faceted_outer_surface() {
  intersection() {
    body_minus_cavity_and_notches();
    decorative_facet_pattern_variation();
  }
}

module small_edge_chamfers() {
  union() {
    chamfer_top_cone();
    chamfer_bottom_cone();
  }
}

module body_with_chamfers() {
  union() {
    faceted_outer_surface();
    small_edge_chamfers();
  }
}

// Final Output
minkowski() {
  body_with_chamfers();
  micro_fillet_sphere();
}