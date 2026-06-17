// Parameters
bead_d = 2.2; //[1.1:4.4:0.1]
bead_l = 3; //[1.5:6:0.1]
lead_d = 0.5; //[0.25:1:0.05]
lead_len = 25; //[12.5:50:0.5]
lead_pitch = 2.5; //[1.25:5:0.1]
neck_d = 1.2; //[0.6:2.4:0.1]
neck_l = 1; //[0.5:2:0.1]
overlap = 0.8; //[0.5:2:0.1]
mark_band_w = 0.5; //[0.25:1.2:0.05]
mark_band_t = 0.15; //[0.05:0.4:0.05]
tin_len = 3; //[1.5:8:0.5]
fillet_r = 0.6; //[0.3:1.2:0.05]
ref_d = 0.3; //[0.2:0.8:0.05]

// Geometry
module ntc_bead_body() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(r=bead_d/2, h=bead_l, center=true);
}

module lead_exit_neck() {
  rotate([0, 90, 0])
    translate([bead_l/2 + neck_l/2 - overlap, 0, 0])
      cylinder(r=neck_d/2, h=neck_l, center=true);
}

module lead_1() {
  rotate([0, 90, 0])
    translate([bead_l/2 + neck_l - overlap + (lead_len + overlap)/2, lead_pitch/2, 0])
      cylinder(r=lead_d/2, h=lead_len + overlap, center=true);
}

module lead_2() {
  rotate([0, 90, 0])
    translate([bead_l/2 + neck_l - overlap + (lead_len + overlap)/2, -lead_pitch/2, 0])
      cylinder(r=lead_d/2, h=lead_len + overlap, center=true);
}

module small_fillet_at_lead_to_body_transition() {
  translate([bead_l/2 + neck_l - overlap, 0, 0])
    sphere(r=fillet_r, center=true);
}

module body_marking_band_or_dot() {
  rotate([0, 90, 0])
    translate([-bead_l/2 + mark_band_w/2, 0, 0])
      cylinder(r=bead_d/2 + mark_band_t, h=mark_band_w, center=true);
}

module lead_tinning_tip_sections_1() {
  rotate([0, 90, 0])
    translate([bead_l/2 + neck_l - overlap + (lead_len + overlap) - tin_len/2, lead_pitch/2, 0])
      cylinder(r=lead_d/2, h=tin_len, center=true);
}

module lead_tinning_tip_sections_2() {
  rotate([0, 90, 0])
    translate([bead_l/2 + neck_l - overlap + (lead_len + overlap) - tin_len/2, -lead_pitch/2, 0])
      cylinder(r=lead_d/2, h=tin_len, center=true);
}

module lead_spacing_reference() {
  rotate([90, 0, 0])
    translate([bead_l/2 + neck_l - overlap + (lead_len + overlap)/2, 0, 0])
      cylinder(r=ref_d/2, h=lead_pitch + lead_d, center=true);
}

// Final assembly
module thermistor_union_all() {
  union() {
    ntc_bead_body();
    lead_exit_neck();
    lead_1();
    lead_2();
    small_fillet_at_lead_to_body_transition();
    body_marking_band_or_dot();
    lead_tinning_tip_sections_1();
    lead_tinning_tip_sections_2();
    lead_spacing_reference();
  }
}

// Render the final thermistor model
thermistor_union_all();