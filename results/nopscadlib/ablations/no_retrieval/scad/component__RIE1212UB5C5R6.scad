// Parameters
body_length = 18; //[9:36:0.5]
body_diameter = 6; //[3:12:0.1]
lead_diameter = 0.8; //[0.4:1.6:0.05]
lead_length_each = 30; //[15:60:1]
cap_length = 1.5; //[0.75:3:0.1]
cap_diameter = 6.2; //[3.1:12.4:0.1]
lead_overlap = 1; //[0.5:2:0.1]
cap_overlap = 0.6; //[0.3:1.5:0.1]
marking_band_length = 8; //[4:16:0.5]
marking_band_thickness = 0.15; //[0.05:0.4:0.01]
gloss_shell_thickness = 0.1; //[0.05:0.3:0.01]
bend_leg_length = 10; //[5:25:0.5]
bend_offset = 5; //[2:15:0.5]

// Resistor Body
module resistor_body() {
  color([0.85, 0.85, 0.8]) // Off-white for ceramic/enamel
  rotate([0, 90, 0])
  translate([0, 0, 0])
  cylinder(r=body_diameter/2, h=body_length, center=true);
}

// End Caps
module end_cap_left() {
  color([0.75, 0.75, 0.77]) // Silver for metal caps
  rotate([0, 90, 0])
  translate([-(body_length/2 + cap_length/2 - cap_overlap), 0, 0])
  cylinder(r=cap_diameter/2, h=cap_length, center=true);
}

module end_cap_right() {
  color([0.75, 0.75, 0.77]) // Silver for metal caps
  rotate([0, 90, 0])
  translate([(body_length/2 + cap_length/2 - cap_overlap), 0, 0])
  cylinder(r=cap_diameter/2, h=cap_length, center=true);
}

// Leads
module lead_left() {
  color([0.4, 0.4, 0.43]) // DimGray for leads
  rotate([0, 90, 0])
  translate([-(body_length/2 + cap_length - cap_overlap + (lead_length_each + lead_overlap)/2 - lead_overlap), 0, 0])
  cylinder(r=lead_diameter/2, h=lead_length_each + lead_overlap, center=true);
}

module lead_right() {
  color([0.4, 0.4, 0.43]) // DimGray for leads
  rotate([0, 90, 0])
  translate([(body_length/2 + cap_length - cap_overlap + (lead_length_each + lead_overlap)/2 - lead_overlap), 0, 0])
  cylinder(r=lead_diameter/2, h=lead_length_each + lead_overlap, center=true);
}

// Marking Band
module body_marking_text() {
  color([0.7, 0.7, 0.7]) // Slightly darker for marking
  rotate([0, 90, 0])
  translate([0, 0, 0])
  cylinder(r=body_diameter/2 + marking_band_thickness, h=marking_band_length, center=true);
}

// Surface Gloss Detail
module surface_gloss_detail() {
  color([0.9, 0.9, 0.9, 0.3]) // Semi-transparent gloss
  rotate([0, 90, 0])
  translate([0, 0, 0])
  cylinder(r=body_diameter/2 + gloss_shell_thickness, h=body_length, center=true);
}

// Lead Bend Form
module lead_bend_form() {
  union() {
    // Leg 1
    rotate([0, 90, 0])
    translate([(body_length/2 + cap_length - cap_overlap + bend_leg_length/2 - lead_overlap), 0, 0])
    cylinder(r=lead_diameter/2, h=bend_leg_length, center=true);

    // Leg 2
    rotate([90, 0, 0])
    translate([(body_length/2 + cap_length - cap_overlap + bend_leg_length - lead_overlap), bend_offset/2, 0])
    cylinder(r=lead_diameter/2, h=bend_leg_length, center=true);

    // Leg 3
    rotate([0, 90, 0])
    translate([(body_length/2 + cap_length - cap_overlap + bend_leg_length + bend_leg_length/2 - lead_overlap), bend_offset, 0])
    cylinder(r=lead_diameter/2, h=bend_leg_length, center=true);
  }
}

// Complete Resistor
module resistor_complete() {
  union() {
    resistor_body();
    end_cap_left();
    end_cap_right();
    lead_left();
    lead_right();
    body_marking_text();
    surface_gloss_detail();
    lead_bend_form();
  }
}

// Final Output
resistor_complete();