// Parameters
resistance_ohms = 5.6; //[2.8:11.2:0.1]
power_w = 3; //[1.5:6:0.5]
body_length_mm = 18; //[9:36:0.5]
body_diameter_mm = 6; //[3:12:0.2]
end_cap_length_mm = 1.5; //[0.75:3:0.1]
end_cap_diameter_mm = 6.2; //[3.1:12.4:0.2]
lead_exit_neck_length_mm = 1.5; //[0.75:3:0.1]
lead_exit_neck_diameter_mm = 2.5; //[1.25:5:0.1]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_side_mm = 25; //[12.5:50:1]
overlap_mm = 1; //[0.5:2:0.1]

// Resistor - complete geometry
module resistor() {
  color("DimGray") {
    // Body
    translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=body_diameter_mm/2, h=body_length_mm, center=true);
    
    // End Caps
    translate([-(body_length_mm/2 + end_cap_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=end_cap_diameter_mm/2, h=end_cap_length_mm, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=end_cap_diameter_mm/2, h=end_cap_length_mm, center=true);
    
    // Lead Exit Necks
    translate([-(body_length_mm/2 + end_cap_length_mm + lead_exit_neck_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_exit_neck_diameter_mm/2, h=lead_exit_neck_length_mm, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm + lead_exit_neck_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_exit_neck_diameter_mm/2, h=lead_exit_neck_length_mm, center=true);
    
    // Axial Leads
    translate([-(body_length_mm/2 + end_cap_length_mm + lead_exit_neck_length_mm + lead_length_each_side_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_side_mm, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm + lead_exit_neck_length_mm + lead_length_each_side_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_side_mm, center=true);
    
    // Fillet Spheres
    translate([-(body_length_mm/2 + end_cap_length_mm - overlap_mm), 0, 0])
      sphere(r=lead_exit_neck_diameter_mm/2, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm - overlap_mm), 0, 0])
      sphere(r=lead_exit_neck_diameter_mm/2, center=true);
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  color("Silver") {
    resistor();
    // Additional features for Al Clad Resistor Assembly can be added here
  }
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color("Silver") {
    resistor();
    // Additional features for Al Clad Resistor can be added here
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color("DimGray") {
    resistor();
    // Additional features for Sleeved Resistor can be added here
  }
}

// Assembly
module assembly() {
  resistor();
  translate([0, 0, 0]) al_clad_resistor_assembly();
  translate([0, 0, 0]) al_clad_resistor();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();