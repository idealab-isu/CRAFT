// Parameters
resistance_ohms = 6.8; //[3.4:13.6:0.1]
power_w = 3; //[1.5:6:0.5]
body_length_mm = 15; //[8:30:0.5]
body_diameter_mm = 5.5; //[3:11:0.1]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_mm = 25; //[10:50:1]
end_cap_length_mm = 1; //[0.5:2:0.1]
fillet_radius_mm = 0.5; //[0.2:1.0:0.05]
tolerance_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
transition_length_mm = 1.5; //[0.8:3:0.1]
cap_diameter_mm = 5.2; //[3:11:0.1]
package_style_axial_flag = 1; //[0:1:1]

// Resistor - complete geometry
module resistor() {
  color("DimGray") {
    // Body
    translate([0, 0, 0])
      cylinder(h=body_length_mm, r=body_diameter_mm/2, center=true, $fn=32);
    
    // End Caps
    translate([0, 0, -(body_length_mm/2 + end_cap_length_mm/2 - overlap_mm/2)])
      cylinder(h=end_cap_length_mm + overlap_mm, r=cap_diameter_mm/2, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + end_cap_length_mm/2 - overlap_mm/2)])
      cylinder(h=end_cap_length_mm + overlap_mm, r=cap_diameter_mm/2, center=true, $fn=32);
    
    // Lead Transitions
    translate([0, 0, -(body_length_mm/2 + end_cap_length_mm + transition_length_mm/2 - overlap_mm)])
      cylinder(h=transition_length_mm + overlap_mm, r1=cap_diameter_mm/2, r2=lead_diameter_mm/2, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + end_cap_length_mm + transition_length_mm/2 - overlap_mm)])
      cylinder(h=transition_length_mm + overlap_mm, r1=cap_diameter_mm/2, r2=lead_diameter_mm/2, center=true, $fn=32);
    
    // Leads
    translate([0, 0, -(body_length_mm/2 + end_cap_length_mm + transition_length_mm + lead_length_each_mm/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm + overlap_mm, r=lead_diameter_mm/2, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + end_cap_length_mm + transition_length_mm + lead_length_each_mm/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm + overlap_mm, r=lead_diameter_mm/2, center=true, $fn=32);
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  color("Silver") {
    resistor();
    // Sleeves
    translate([0, 0, -(body_length_mm/2 + end_cap_length_mm + transition_length_mm + (lead_length_each_mm*0.6)/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm*0.6, r=lead_diameter_mm/2 + tolerance_mm, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + end_cap_length_mm + transition_length_mm + (lead_length_each_mm*0.6)/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm*0.6, r=lead_diameter_mm/2 + tolerance_mm, center=true, $fn=32);
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color("Black") {
    resistor();
    // Sleeves
    translate([0, 0, -(body_length_mm/2 + end_cap_length_mm + transition_length_mm + (lead_length_each_mm*0.6)/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm*0.6, r=lead_diameter_mm/2 + tolerance_mm, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + end_cap_length_mm + transition_length_mm + (lead_length_each_mm*0.6)/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm*0.6, r=lead_diameter_mm/2 + tolerance_mm, center=true, $fn=32);
  }
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color("Silver") {
    resistor();
    // Additional Cladding
    translate([0, 0, 0])
      cube([body_diameter_mm*0.9, body_diameter_mm*0.9, body_length_mm*0.2], center=true);
  }
}

// Assembly
module assembly() {
  al_clad_resistor_assembly();
}

assembly();