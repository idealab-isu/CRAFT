// Parameters
body_d = 3.0; //[1.5:6.0:0.1]
body_t = 2.0; //[1.0:4.0:0.1]
lead_d = 0.5; //[0.25:1.0:0.05]
lead_len = 25.0; //[12.0:50.0:1]
lead_pitch = 2.54; //[1.27:5.08:0.01]
lead_straight_from_body = 6.0; //[3.0:12.0:0.5]
lead_bend_r = 1.0; //[0.5:3.0:0.1]
overlap = 0.8; //[0.3:2.0:0.1]
meniscus_r = 0.6; //[0.2:1.5:0.1]
marking_d = 1.2; //[0.6:2.4:0.1]
marking_depth = 0.15; //[0.05:0.4:0.05]
tip_chamfer_h = 0.6; //[0.2:1.5:0.1]
tip_chamfer_r = 0.35; //[0.15:0.8:0.05]
ref_bar_t = 0.4; //[0.2:1.0:0.1]
ref_bar_w = 0.6; //[0.3:1.5:0.1]

// Base Shapes
module thermistor_body() {
  color([0.85, 0.85, 0.8]) // Off-white for epoxy
  translate([0, 0, 0])
    cylinder(r=body_d/2, h=body_t, center=true);
}

module lead_1() {
  color([0.2, 0.2, 0.2]) // Dark for leads
  translate([lead_pitch/2, 0, -(lead_len + overlap)/2])
    cylinder(r=lead_d/2, h=lead_len + body_t/2 + overlap, center=true);
}

module lead_2() {
  color([0.2, 0.2, 0.2]) // Dark for leads
  translate([-lead_pitch/2, 0, -(lead_len + overlap)/2])
    cylinder(r=lead_d/2, h=lead_len + body_t/2 + overlap, center=true);
}

module lead_bend_relief_1() {
  translate([lead_pitch/2, 0, -body_t/2 + overlap])
    sphere(r=lead_bend_r, center=true);
}

module lead_bend_relief_2() {
  translate([-lead_pitch/2, 0, -body_t/2 + overlap])
    sphere(r=lead_bend_r, center=true);
}

module epoxy_meniscus_detail_1() {
  translate([lead_pitch/2, 0, -body_t/2 + overlap])
    sphere(r=meniscus_r, center=true);
}

module epoxy_meniscus_detail_2() {
  translate([-lead_pitch/2, 0, -body_t/2 + overlap])
    sphere(r=meniscus_r, center=true);
}

module lead_spacing_reference() {
  color([0.75, 0.75, 0.77]) // Silver for reference bar
  translate([0, 0, -(lead_len + body_t/2) + ref_bar_t/2 + overlap])
    cube([lead_pitch + ref_bar_w, ref_bar_w, ref_bar_t], center=true);
}

module body_marking_cutter() {
  translate([0, 0, body_t/2 - marking_depth/2])
    cylinder(r=marking_d/2, h=marking_depth + overlap, center=true);
}

module lead_tip_chamfer_cutter_1() {
  translate([lead_pitch/2, 0, -(lead_len + body_t/2) + tip_chamfer_h/2])
    cylinder(r1=tip_chamfer_r, r2=0, h=tip_chamfer_h, center=true);
}

module lead_tip_chamfer_cutter_2() {
  translate([-lead_pitch/2, 0, -(lead_len + body_t/2) + tip_chamfer_h/2])
    cylinder(r1=tip_chamfer_r, r2=0, h=tip_chamfer_h, center=true);
}

// Operations
module union_body_with_meniscus() {
  union() {
    thermistor_body();
    epoxy_meniscus_detail_1();
    epoxy_meniscus_detail_2();
  }
}

module union_leads_with_relief() {
  union() {
    lead_1();
    lead_2();
    lead_bend_relief_1();
    lead_bend_relief_2();
  }
}

module union_all_visible() {
  union() {
    union_body_with_meniscus();
    union_leads_with_relief();
    lead_spacing_reference();
  }
}

module difference_body_marking() {
  difference() {
    union_all_visible();
    body_marking_cutter();
  }
}

module difference_lead_tip_chamfer() {
  difference() {
    difference_body_marking();
    lead_tip_chamfer_cutter_1();
    lead_tip_chamfer_cutter_2();
  }
}

// Final Output
difference_lead_tip_chamfer();