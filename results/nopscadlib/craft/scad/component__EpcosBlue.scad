$fn = 64;

// Parameters (approx. EPCOS B57861S104F40 radial NTC bead/disc style)
body_d = 3.0;          //[1.5:6.0:0.1]  // body diameter
body_t = 2.0;          //[1.0:4.0:0.1]  // body thickness (lead axis)
lead_d = 0.5;          //[0.25:1.0:0.05]
lead_len = 25.0;       //[12.0:50.0:1]  // length from body face outward
lead_pitch = 2.5;      //[1.5:5.0:0.1]  // lead spacing
lead_embed = 1.0;      //[0.5:2.0:0.1]  // how far leads go into epoxy
transition_len = 1.5;  //[0.8:3.0:0.1]
transition_d = 1.2;    //[0.8:2.4:0.1]
overlap = 0.6;         //[0.3:2.0:0.1]  // overlap to ensure one connected solid
tip_chamfer_len = 0.8; //[0.3:2.0:0.1]
meniscus_r = 0.35;     //[0.15:0.8:0.05]

// Derived
lead_total = lead_len + lead_embed + overlap; // includes embed and overlap into body
x_lead_center = body_t/2 - lead_embed/2 - overlap/2; // lead cylinder center so it penetrates body
x_tip_center  = body_t/2 - lead_embed - overlap + lead_total/2 - tip_chamfer_len/2;

// Thermistor Body (disc)
module thermistor_body() {
  color([0.85, 0.85, 0.8])
    rotate([0, 90, 0])
      cylinder(r=body_d/2, h=body_t, center=true);
}

// Lead (radial, two leads along +X direction, spaced in Y)
module lead(position_y) {
  color([0.2, 0.2, 0.2])
    rotate([0, 90, 0])
      translate([x_lead_center, position_y, 0])
        cylinder(r=lead_d/2, h=lead_total, center=true);
}

// Body-to-lead epoxy transition (small cone from body face to lead)
module body_to_lead_transition(position_y) {
  color([0.85, 0.85, 0.8])
    rotate([0, 90, 0])
      translate([body_t/2 + transition_len/2 - overlap, position_y, 0])
        cylinder(r1=transition_d/2, r2=lead_d/2, h=transition_len, center=true);
}

// Lead tip chamfer (conical end)
module lead_tip_chamfer(position_y) {
  color([0.2, 0.2, 0.2])
    rotate([0, 90, 0])
      translate([x_tip_center, position_y, 0])
        cylinder(r1=lead_d/2, r2=0, h=tip_chamfer_len, center=true);
}

// Epoxy meniscus at lead exit (small fillet-like bump)
module epoxy_meniscus_detail(position_y) {
  color([0.85, 0.85, 0.8])
    translate([body_t/2 - overlap, position_y, 0])
      sphere(r=meniscus_r);
}

// Complete Model (ONE connected solid; no floating reference geometry)
module complete_model() {
  union() {
    thermistor_body();

    // Leads (two radial leads)
    lead( lead_pitch/2);
    lead(-lead_pitch/2);

    // Transitions and meniscus to visually blend leads into body
    body_to_lead_transition( lead_pitch/2);
    body_to_lead_transition(-lead_pitch/2);

    epoxy_meniscus_detail( lead_pitch/2);
    epoxy_meniscus_detail(-lead_pitch/2);

    // Tip chamfers
    lead_tip_chamfer( lead_pitch/2);
    lead_tip_chamfer(-lead_pitch/2);
  }
}

complete_model();