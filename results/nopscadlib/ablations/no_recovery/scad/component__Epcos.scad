// Parameters
body_dia = 3.0; //[1.5:6.0:0.1]
body_thk = 2.0; //[1.0:4.0:0.1]
lead_dia = 0.5; //[0.25:1.0:0.05]
lead_len = 25.0; //[12.0:50.0:1]
lead_pitch = 2.5; //[1.25:5.0:0.1]
neck_len = 1.0; //[0.5:2.0:0.1]
neck_dia = 1.2; //[0.6:2.4:0.1]
overlap = 0.8; //[0.3:2.0:0.1]
tinning_len = 2.0; //[1.0:5.0:0.5]
fillet_r = 0.35; //[0.15:0.8:0.05]
marking_depth = 0.2; //[0.1:0.6:0.05]
marking_dia = 1.2; //[0.6:2.4:0.1]
ref_bar_dia = 0.3; //[0.15:0.8:0.05]

// Base Shapes
module thermistor_bead_body() {
  color([0.85, 0.85, 0.8]) // Off-white for epoxy
  translate([0, 0, 0])
    cylinder(r=body_dia/2, h=body_thk, center=true);
}

module lead_exit_neck_1() {
  translate([body_dia/2 - overlap + neck_len/2, lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=neck_dia/2, h=neck_len, center=true);
}

module lead_exit_neck_2() {
  translate([body_dia/2 - overlap + neck_len/2, -lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=neck_dia/2, h=neck_len, center=true);
}

module lead_1() {
  translate([body_dia/2 - overlap + (lead_len + neck_len + overlap)/2, lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=lead_dia/2, h=lead_len + neck_len + overlap, center=true);
}

module lead_2() {
  translate([body_dia/2 - overlap + (lead_len + neck_len + overlap)/2, -lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=lead_dia/2, h=lead_len + neck_len + overlap, center=true);
}

module lead_tinning_tip_1() {
  translate([body_dia/2 - overlap + (lead_len + neck_len + overlap) - tinning_len/2, lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=lead_dia/2, h=tinning_len, center=true);
}

module lead_tinning_tip_2() {
  translate([body_dia/2 - overlap + (lead_len + neck_len + overlap) - tinning_len/2, -lead_pitch/2, 0])
    rotate([0, 90, 0])
      cylinder(r=lead_dia/2, h=tinning_len, center=true);
}

module fillet_sphere_1a() {
  translate([body_dia/2 - overlap, lead_pitch/2, 0])
    sphere(r=fillet_r, center=true);
}

module fillet_sphere_1b() {
  translate([body_dia/2 - overlap + neck_len, lead_pitch/2, 0])
    sphere(r=fillet_r, center=true);
}

module fillet_sphere_2a() {
  translate([body_dia/2 - overlap, -lead_pitch/2, 0])
    sphere(r=fillet_r, center=true);
}

module fillet_sphere_2b() {
  translate([body_dia/2 - overlap + neck_len, -lead_pitch/2, 0])
    sphere(r=fillet_r, center=true);
}

module lead_spacing_reference() {
  translate([body_dia/2 - overlap + ref_bar_dia/2, 0, 0])
    rotate([90, 0, 0])
      cylinder(r=ref_bar_dia/2, h=lead_pitch + lead_dia, center=true);
}

module body_marking() {
  translate([0, 0, body_thk/2 - (marking_depth + overlap)/2])
    cylinder(r=marking_dia/2, h=marking_depth + overlap, center=true);
}

// Operations
module small_fillet_at_lead_exit_1() {
  hull() {
    fillet_sphere_1a();
    fillet_sphere_1b();
  }
}

module small_fillet_at_lead_exit_2() {
  hull() {
    fillet_sphere_2a();
    fillet_sphere_2b();
  }
}

module epoxy_with_necks_and_fillet() {
  union() {
    thermistor_bead_body();
    lead_exit_neck_1();
    lead_exit_neck_2();
    small_fillet_at_lead_exit_1();
    small_fillet_at_lead_exit_2();
  }
}

module epoxy_with_marking() {
  difference() {
    epoxy_with_necks_and_fillet();
    body_marking();
  }
}

module leads_with_tinning() {
  union() {
    lead_1();
    lead_2();
    lead_tinning_tip_1();
    lead_tinning_tip_2();
  }
}

// Final Model
module complete_model() {
  union() {
    epoxy_with_marking();
    leads_with_tinning();
    lead_spacing_reference();
  }
}

// Render the complete model
complete_model();