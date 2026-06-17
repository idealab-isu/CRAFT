// Parameters
body_d = 3.0; //[1.5:6.0:0.1]
body_t = 2.0; //[1.0:4.0:0.1]
lead_d = 0.5; //[0.25:1.0:0.05]
lead_len = 25.0; //[12.0:50.0:1]
lead_pitch = 2.5; //[1.25:5.0:0.1]
lead_embed = 1.0; //[0.5:2.0:0.1]
lead_bend_len = 5.0; //[2.0:10.0:0.5]
transition_len = 0.8; //[0.4:1.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
mark_dot_r = 0.35; //[0.2:0.8:0.05]
mark_dot_h = 0.2; //[0.1:0.6:0.05]
label_w = 1.6; //[0.8:3.2:0.1]
label_h = 0.9; //[0.45:1.8:0.1]
label_t = 0.15; //[0.08:0.4:0.01]
fillet_r = 0.25; //[0.1:0.6:0.05]

// Thermistor Body
module thermistor_body() {
  color([0.85, 0.85, 0.8]) // Off-white for epoxy
  rotate([0, 90, 0])
  translate([0, 0, 0])
  cylinder(r=body_d/2, h=body_t, center=true);
}

// Lead
module lead(position_y) {
  color([0.2, 0.2, 0.2]) // Dark color for leads
  rotate([0, 90, 0])
  translate([body_t/2 - lead_embed/2, position_y, 0])
  cylinder(r=lead_d/2, h=lead_len + lead_embed, center=true);
}

// Lead Spacing Reference
module lead_spacing_reference() {
  translate([body_t/2 - lead_embed + overlap/2, 0, 0])
  cube([lead_d, lead_pitch, lead_d], center=true);
}

// Lead Bend Region
module lead_bend_region() {
  translate([body_t/2 + lead_bend_len/2 - overlap, 0, 0])
  cube([lead_bend_len, lead_pitch + lead_d, lead_d], center=true);
}

// Body to Lead Transition
module body_to_lead_transition(position_y) {
  rotate([0, 90, 0])
  translate([body_t/2 - transition_len/2, position_y, 0])
  cylinder(r=lead_d/2 + transition_len/2, h=transition_len, center=true);
}

// Polarity Marking Dot
module polarity_marking_dot() {
  color("Black")
  translate([0, 0, body_d/2 + mark_dot_h/2 - overlap])
  cylinder(r=mark_dot_r, h=mark_dot_h, center=true);
}

// Printed Label
module printed_label() {
  color("Black")
  translate([0, 0, body_d/2 + label_t/2 - overlap])
  cube([label_w, label_h, label_t], center=true);
}

// Lead Tip Chamfer
module lead_tip_chamfer(position_y) {
  rotate([0, 90, 0])
  translate([body_t/2 + lead_len - lead_d/2, position_y, 0])
  cylinder(r1=lead_d/2, r2=0, h=lead_d, center=true);
}

// Small Fillets Kernel
module small_fillets_kernel() {
  sphere(r=fillet_r);
}

// Union of Raw Model
module union_raw_model() {
  union() {
    thermistor_body();
    lead(lead_pitch/2);
    lead(-lead_pitch/2);
    lead_spacing_reference();
    lead_bend_region();
    body_to_lead_transition(lead_pitch/2);
    body_to_lead_transition(-lead_pitch/2);
    polarity_marking_dot();
    printed_label();
    lead_tip_chamfer(lead_pitch/2);
    lead_tip_chamfer(-lead_pitch/2);
  }
}

// Final Output with Small Fillets
minkowski() {
  union_raw_model();
  small_fillets_kernel();
}