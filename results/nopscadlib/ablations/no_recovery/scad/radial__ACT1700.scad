// Parameters
r_outer = 10.8; //[5.4:21.6:0.1]
r_inner = 10.8; //[0:21.6:0.1]
H = 5.3; //[2.65:10.6:0.1]
t = 1; //[0.5:2:0.1]
overlap = 0.8; //[0.5:2:0.1]

// Geometry
module radial_body_outer() {
  cylinder(h=H, r=r_outer, center=true);
}

module radial_body_inner_cut() {
  cylinder(h=H, r=r_inner, center=true);
}

module thickness_feature_outer() {
  translate([0, 0, H/2 - t/2 + overlap/2])
    cylinder(h=t, r=r_outer, center=true);
}

module thickness_feature_inner_cut() {
  translate([0, 0, H/2 - t/2 + overlap/2])
    cylinder(h=t + overlap, r=r_outer - t, center=true);
}

// Operations
module radial_body() {
  difference() {
    radial_body_outer();
    radial_body_inner_cut();
  }
}

module thickness_feature() {
  difference() {
    thickness_feature_outer();
    thickness_feature_inner_cut();
  }
}

// Final Model
module complete_model() {
  union() {
    radial_body();
    thickness_feature();
  }
}

// Render the complete model
complete_model();