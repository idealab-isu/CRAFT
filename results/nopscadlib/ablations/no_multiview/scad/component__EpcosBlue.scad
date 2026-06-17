// Parameters
body_d = 3.2; //[1.6:6.4:0.1]
body_t = 2; //[1:4:0.1]
lead_d = 0.5; //[0.25:1:0.05]
lead_len = 25; //[12.5:50:0.5]
lead_pitch = 2.5; //[1.25:5:0.1]
lead_straight_len_from_body = 6; //[3:12:0.5]
exit_fillet_r = 0.6; //[0.3:1.2:0.05]
overlap = 0.8; //[0.5:2:0.1]
marking_depth = 0.2; //[0.1:0.5:0.05]
marking_d = 1.2; //[0.6:2.4:0.1]
tinning_len = 3; //[1.5:6:0.5]
ref_bar_d = 0.3; //[0.15:0.6:0.05]

// Thermistor Body
module thermistor_body() {
  color([0.85, 0.85, 0.8]) // Off-white for epoxy
  cylinder(r=body_d/2, h=body_t, center=true);
}

// Lead
module lead(position) {
  translate(position)
  color([0.2, 0.2, 0.2]) // Dark color for leads
  cylinder(r=lead_d/2, h=lead_len + overlap, center=true);
}

// Lead Exit Fillet
module lead_exit_fillet(position) {
  translate(position)
  sphere(r=exit_fillet_r);
}

// Body Marking Cutter
module body_marking_cutter() {
  translate([0, 0, body_t/2 - (marking_depth + overlap)/2 + overlap/2])
  cylinder(r=marking_d/2, h=marking_depth + overlap, center=true);
}

// Lead Tinning Length
module lead_tinning_length(position) {
  translate(position)
  color([0.72, 0.45, 0.2]) // Copper color for tinning
  cylinder(r=lead_d/2, h=tinning_len, center=true);
}

// Lead Spacing Reference
module lead_spacing_reference() {
  translate([0, 0, body_t/2 + lead_straight_len_from_body - overlap])
  rotate([0, 90, 0])
  color([0.4, 0.4, 0.43]) // DimGray for reference bar
  cylinder(r=ref_bar_d/2, h=lead_pitch + overlap, center=true);
}

// Main Assembly
module thermistor_model() {
  // Body with exit fillet
  union() {
    thermistor_body();
    lead_exit_fillet([lead_pitch/2, 0, body_t/2 - overlap]);
    lead_exit_fillet([-lead_pitch/2, 0, body_t/2 - overlap]);
  }
  
  // Body with marking
  difference() {
    union() {
      thermistor_body();
      lead_exit_fillet([lead_pitch/2, 0, body_t/2 - overlap]);
      lead_exit_fillet([-lead_pitch/2, 0, body_t/2 - overlap]);
    }
    body_marking_cutter();
  }
  
  // Leads
  union() {
    lead([lead_pitch/2, 0, body_t/2 + (lead_len + overlap)/2 - overlap]);
    lead([-lead_pitch/2, 0, body_t/2 + (lead_len + overlap)/2 - overlap]);
  }
  
  // Lead Tinning
  union() {
    lead_tinning_length([lead_pitch/2, 0, body_t/2 + lead_len - tinning_len/2]);
    lead_tinning_length([-lead_pitch/2, 0, body_t/2 + lead_len - tinning_len/2]);
  }
  
  // Lead Spacing Reference
  lead_spacing_reference();
}

// Final Output
thermistor_model();