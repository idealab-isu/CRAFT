// Parameters
body_d = 3.0; //[1.5:6.0:0.1]
body_t = 2.0; //[1.0:4.0:0.1]
lead_d = 0.5; //[0.25:1.0:0.05]
lead_pitch = 2.5; //[1.25:5.0:0.1]
lead_len = 25.0; //[12.5:50.0:0.5]
lead_straight_from_body = 3.0; //[1.5:6.0:0.1]
lead_bend_r = 0.8; //[0.4:1.6:0.05]
overlap = 0.8; //[0.3:2.0:0.1]
lead_embed = 0.6; //[0.2:1.5:0.1]
tinning_len = 3.0; //[1.5:6.0:0.1]
marking_depth = 0.2; //[0.1:0.5:0.05]
marking_d = 1.2; //[0.6:2.4:0.1]
edge_fillet_r = 0.25; //[0.1:0.6:0.05]

// Base Shapes
module thermistor_body_raw() {
  cylinder(r=body_d/2, h=body_t, center=true);
}

module fillets_chamfers_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

module body_marking_cutter() {
  translate([0, 0, body_t/2 - marking_depth/2])
    cylinder(r=marking_d/2, h=marking_depth + overlap, center=true);
}

module lead_1_straight() {
  translate([lead_pitch/2, 0, -(body_t/2) - (lead_len + lead_embed)/2 + lead_embed])
    cylinder(r=lead_d/2, h=lead_len + lead_embed, center=true);
}

module lead_2_straight() {
  translate([-lead_pitch/2, 0, -(body_t/2) - (lead_len + lead_embed)/2 + lead_embed])
    cylinder(r=lead_d/2, h=lead_len + lead_embed, center=true);
}

module lead_bend_knee_1() {
  translate([lead_pitch/2, 0, -(body_t/2) - lead_straight_from_body])
    sphere(r=lead_bend_r, center=true);
}

module lead_bend_knee_2() {
  translate([-lead_pitch/2, 0, -(body_t/2) - lead_straight_from_body])
    sphere(r=lead_bend_r, center=true);
}

module lead_tinning_tip_1() {
  translate([lead_pitch/2, 0, -(body_t/2) - lead_len + tinning_len/2])
    cylinder(r=lead_d/2, h=tinning_len, center=true);
}

module lead_tinning_tip_2() {
  translate([-lead_pitch/2, 0, -(body_t/2) - lead_len + tinning_len/2])
    cylinder(r=lead_d/2, h=tinning_len, center=true);
}

module lead_spacing_reference() {
  translate([0, 0, -(body_t/2) - lead_straight_from_body])
    cube([lead_pitch + lead_d, lead_d, lead_d], center=true);
}

// Operations
module fillets_chamfers() {
  minkowski() {
    thermistor_body_raw();
    fillets_chamfers_sphere();
  }
}

module thermistor_body() {
  difference() {
    fillets_chamfers();
    body_marking_cutter();
  }
}

module lead_1() {
  union() {
    lead_1_straight();
    lead_bend_knee_1();
    lead_tinning_tip_1();
  }
}

module lead_2() {
  union() {
    lead_2_straight();
    lead_bend_knee_2();
    lead_tinning_tip_2();
  }
}

module complete_model() {
  union() {
    thermistor_body();
    lead_1();
    lead_2();
    lead_spacing_reference();
  }
}

// Final Output
complete_model();