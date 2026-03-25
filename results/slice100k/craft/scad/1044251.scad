// Parameters
bbox_xy = 23.46; //[11.73:46.92:0.01]
thickness = 7; //[3.5:14:0.1]
outer_radius_max = 11.73; //[5.865:23.46:0.01]
bore_d = 10; //[5:20:0.1]
tooth_count = 12; //[6:36:1]
tooth_radial_depth = 1.6; //[0.8:3.2:0.05]
tooth_tangential_w = 3; //[1.5:6:0.05]
outer_root_radius = 10.13; //[5.065:20.26:0.01]
overlap = 0.8; //[0.5:2:0.1]
chamfer_z = 0.6; //[0.3:1.2:0.05]
chamfer_radial = 0.6; //[0.3:1.2:0.05]
tooth_tip_round_r = 0.6; //[0.3:1.2:0.05]
fillet_r = 0.5; //[0.25:1:0.05]

// Base shapes
module outer_root_cylinder_base() {
  translate([0, 0, 0])
    cylinder(r=outer_root_radius, h=thickness, center=true);
}

module lug_tooth_profile_rectangular() {
  translate([outer_root_radius + tooth_radial_depth/2 - overlap, 0, 0])
    cube([tooth_radial_depth, tooth_tangential_w, thickness], center=true);
}

module center_through_bore() {
  translate([0, 0, 0])
    cylinder(r=bore_d/2, h=thickness + 2*overlap, center=true);
}

module edge_chamfers_outer_top_frustum() {
  translate([0, 0, thickness/2 - chamfer_z/2 + overlap/2])
    cylinder(r1=outer_radius_max + chamfer_radial, r2=outer_radius_max - chamfer_radial, h=chamfer_z, center=true);
}

module edge_chamfers_outer_bottom_frustum() {
  translate([0, 0, -thickness/2 + chamfer_z/2 - overlap/2])
    cylinder(r1=outer_radius_max - chamfer_radial, r2=outer_radius_max + chamfer_radial, h=chamfer_z, center=true);
}

module tooth_tip_rounding_sphere_a() {
  translate([outer_radius_max - tooth_tip_round_r, tooth_tangential_w/2 - tooth_tip_round_r, thickness/2 - tooth_tip_round_r])
    sphere(r=tooth_tip_round_r);
}

module tooth_tip_rounding_sphere_b() {
  translate([outer_radius_max - tooth_tip_round_r, -tooth_tangential_w/2 + tooth_tip_round_r, thickness/2 - tooth_tip_round_r])
    sphere(r=tooth_tip_round_r);
}

module tooth_tip_rounding_sphere_c() {
  translate([outer_radius_max - tooth_tip_round_r, tooth_tangential_w/2 - tooth_tip_round_r, -thickness/2 + tooth_tip_round_r])
    sphere(r=tooth_tip_round_r);
}

module tooth_tip_rounding_sphere_d() {
  translate([outer_radius_max - tooth_tip_round_r, -tooth_tangential_w/2 + tooth_tip_round_r, -thickness/2 + tooth_tip_round_r])
    sphere(r=tooth_tip_round_r);
}

// Operations
module outer_lugs_teeth_array() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      lug_tooth_profile_rectangular();
  }
}

module tooth_tip_rounding() {
  hull() {
    tooth_tip_rounding_sphere_a();
    tooth_tip_rounding_sphere_b();
    tooth_tip_rounding_sphere_c();
    tooth_tip_rounding_sphere_d();
  }
}

module tooth_tip_rounding_array() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      tooth_tip_rounding();
  }
}

module annular_body() {
  difference() {
    union() {
      outer_root_cylinder_base();
      outer_lugs_teeth_array();
    }
    center_through_bore();
  }
}

module annular_body_with_tip_rounding() {
  union() {
    annular_body();
    tooth_tip_rounding_array();
  }
}

module annular_body_with_chamfers() {
  difference() {
    annular_body_with_tip_rounding();
    edge_chamfers_outer_top_frustum();
    edge_chamfers_outer_bottom_frustum();
  }
}

module edge_fillets() {
  minkowski() {
    annular_body_with_chamfers();
    scale([fillet_r/tooth_tip_round_r, fillet_r/tooth_tip_round_r, fillet_r/tooth_tip_round_r])
      sphere(r=tooth_tip_round_r);
  }
}

// Final model
module final_model_no_markings() {
  edge_fillets();
}

// Render the final model
final_model_no_markings();