// Parameters
body_d = 3.0; //[1.5:6.0:0.1]
body_h = 2.5; //[1.25:5.0:0.1]
lead_d = 0.5; //[0.25:1.0:0.05]
lead_len = 25.0; //[12.5:50.0:0.5]
lead_pitch = 2.5; //[1.25:5.0:0.1]
lead_straight_from_body = 6.0; //[3.0:12.0:0.5]
bend_r = 1.0; //[0.5:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
lead_exit_depth = 0.8; //[0.4:1.6:0.1]
sleeve_len = 4.0; //[2.0:10.0:0.5]
sleeve_od = 1.2; //[0.8:2.4:0.1]
mold_line_depth = 0.2; //[0.1:0.5:0.05]
mold_line_width = 0.8; //[0.4:1.6:0.1]
lead_spacing_ref_d = 0.8; //[0.4:2.0:0.1]
lead_spacing_ref_h = 1.5; //[0.8:4.0:0.1]

// Thermistor Body
module thermistor_body() {
  color([0.85, 0.85, 0.8]) // Off-white for epoxy/bead
  cylinder(r=body_d/2, h=body_h, center=true);
}

// Lead
module lead(position) {
  translate(position)
  cylinder(r=lead_d/2, h=lead_len + lead_exit_depth, center=true);
}

// Lead Bend Region
module lead_bend_region() {
  color([0.2, 0.2, 0.2]) // Dark color for bend region
  translate([0, 0, -(body_h/2) - lead_straight_from_body + overlap])
  cube([lead_pitch + lead_d + 2*overlap, lead_d + 2*overlap, 2*bend_r + 2*overlap], center=true);
}

// Strain Relief Sleeving
module strain_relief_sleeving(position) {
  translate(position)
  cylinder(r=sleeve_od/2, h=sleeve_len + overlap, center=true);
}

// Lead Spacing Reference
module lead_spacing_reference() {
  color([0.1, 0.1, 0.6]) // Blue for reference
  translate([0, 0, -(body_h/2) - lead_straight_from_body - lead_spacing_ref_h/2 + overlap])
  rotate([0, 90, 0])
  cylinder(r=lead_spacing_ref_d/2, h=lead_spacing_ref_h, center=true);
}

// Body Flat or Mold Line
module body_flat_or_mold_line() {
  translate([body_d/2 - mold_line_depth/2, 0, 0])
  cube([mold_line_width, body_d + 2*overlap, body_h + 2*overlap], center=true);
}

// Polarity or Part Marking
module polarity_or_part_marking() {
  translate([0, body_d/2 - body_d*0.12 - overlap/2, body_h/2 - body_d*0.12 - overlap/2])
  sphere(r=body_d*0.12, center=true);
}

// Assemble Thermistor
module thermistor_complete() {
  difference() {
    thermistor_body();
    body_flat_or_mold_line();
  }
  union() {
    polarity_or_part_marking();
    union() {
      lead([lead_pitch/2, 0, -(body_h/2) - (lead_len + lead_exit_depth)/2 + lead_exit_depth]);
      lead([-lead_pitch/2, 0, -(body_h/2) - (lead_len + lead_exit_depth)/2 + lead_exit_depth]);
      lead_bend_region();
      strain_relief_sleeving([lead_pitch/2, 0, -(body_h/2) - (sleeve_len + overlap)/2 + overlap/2]);
      strain_relief_sleeving([-lead_pitch/2, 0, -(body_h/2) - (sleeve_len + overlap)/2 + overlap/2]);
    }
  }
  lead_spacing_reference();
}

// Final Output
thermistor_complete();