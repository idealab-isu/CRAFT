// Parameters
body_d = 3.0; //[1.5:6.0:0.1]
body_t = 2.0; //[1.0:4.0:0.1]
lead_d = 0.5; //[0.25:1.0:0.05]
lead_len = 25.0; //[12.0:50.0:1]
lead_pitch = 2.5; //[1.25:5.0:0.1]
lead_embed = 1.0; //[0.5:2.0:0.1]
bend_len = 5.0; //[2.5:10.0:0.5]
overlap = 0.8; //[0.5:2.0:0.1]
fillet_r = 0.35; //[0.15:0.8:0.05]
tip_chamfer_len = 1.0; //[0.5:2.0:0.1]

// Thermistor Body Core
module thermistor_body_core() {
  translate([0, 0, 0])
    cylinder(r=body_d/2 - fillet_r, h=body_t - 2*fillet_r, center=true);
}

// Body Edge Fillet Sphere
module body_edge_fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

// Lead 1
module lead_1() {
  translate([lead_pitch/2, 0, -(body_t/2 + (lead_len + lead_embed)/2 - lead_embed + overlap)])
    cylinder(r=lead_d/2, h=lead_len + lead_embed, center=true);
}

// Lead 2
module lead_2() {
  translate([-lead_pitch/2, 0, -(body_t/2 + (lead_len + lead_embed)/2 - lead_embed + overlap)])
    cylinder(r=lead_d/2, h=lead_len + lead_embed, center=true);
}

// Lead Bend Region 1
module lead_bend_region_1() {
  translate([lead_pitch/2, 0, -(body_t/2 + bend_len/2 - overlap)])
    cylinder(r=lead_d/2 + lead_d*0.15, h=bend_len, center=true);
}

// Lead Bend Region 2
module lead_bend_region_2() {
  translate([-lead_pitch/2, 0, -(body_t/2 + bend_len/2 - overlap)])
    cylinder(r=lead_d/2 + lead_d*0.15, h=bend_len, center=true);
}

// Lead Tip Chamfer 1
module lead_tip_chamfer_1() {
  translate([lead_pitch/2, 0, -(body_t/2 + lead_len + tip_chamfer_len/2 - overlap)])
    rotate([180, 0, 0])
    cylinder(r1=lead_d/2, r2=0, h=tip_chamfer_len, center=true);
}

// Lead Tip Chamfer 2
module lead_tip_chamfer_2() {
  translate([-lead_pitch/2, 0, -(body_t/2 + lead_len + tip_chamfer_len/2 - overlap)])
    rotate([180, 0, 0])
    cylinder(r1=lead_d/2, r2=0, h=tip_chamfer_len, center=true);
}

// Lead Spacing Reference
module lead_spacing_reference() {
  translate([0, 0, -(body_t/2 + lead_d/2 - overlap)])
    cube([lead_pitch + lead_d, lead_d, lead_d], center=true);
}

// Marking Text
module marking_text() {
  translate([0, 0, body_t/2 - (body_t*0.15)/2 - overlap])
    cube([body_d*0.6, body_d*0.25, body_t*0.15], center=true);
}

// Thermistor Body with Fillet
module thermistor_body() {
  minkowski() {
    thermistor_body_core();
    body_edge_fillet_sphere();
  }
}

// Lead Bend Region
module lead_bend_region() {
  union() {
    lead_bend_region_1();
    lead_bend_region_2();
  }
}

// Lead Tip Chamfer
module lead_tip_chamfer() {
  union() {
    lead_tip_chamfer_1();
    lead_tip_chamfer_2();
  }
}

// Leads Union
module leads_union() {
  union() {
    lead_1();
    lead_2();
    lead_bend_region();
    lead_tip_chamfer();
  }
}

// Complete Model
module complete_model() {
  union() {
    thermistor_body();
    leads_union();
    lead_spacing_reference();
    marking_text();
  }
}

// Final Output
complete_model();