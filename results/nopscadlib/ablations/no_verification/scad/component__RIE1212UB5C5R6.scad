// Parameters
resistance_ohms = 5.6; //[2.8:11.2:0.1]
power_w = 3; //[1.5:6:0.5]
body_length_mm = 18; //[9:36:0.5]
body_diameter_mm = 6; //[3:12:0.25]
end_cap_length_mm = 1.5; //[0.75:3:0.1]
end_cap_diameter_mm = 6.2; //[3.1:12.4:0.25]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_mm = 30; //[15:60:1]
lead_exit_fillet_radius_mm = 1.2; //[0.6:2.4:0.1]
lead_exit_fillet_length_mm = 2.0; //[1.0:4.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
lead_spacing_mm = 78; //[39:156:1]
tolerance = 0.2; //[0.1:0.5:0.05]

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
    
    // Lead Exit Fillets
    translate([-(body_length_mm/2 + end_cap_length_mm + lead_exit_fillet_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r1=lead_exit_fillet_radius_mm, r2=0, h=lead_exit_fillet_length_mm, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm + lead_exit_fillet_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, -90, 0])
      cylinder(r1=lead_exit_fillet_radius_mm, r2=0, h=lead_exit_fillet_length_mm, center=true);
    
    // Axial Leads
    translate([-(body_length_mm/2 + end_cap_length_mm + lead_exit_fillet_length_mm + lead_length_each_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm, center=true);
    translate([(body_length_mm/2 + end_cap_length_mm + lead_exit_fillet_length_mm + lead_length_each_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm, center=true);
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color("DimGray") {
    resistor();
    // Additional sleeving logic can be added here if needed
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  color("DimGray") {
    sleeved_resistor();
    // Additional assembly logic can be added here if needed
  }
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color("DimGray") {
    al_clad_resistor_assembly();
    // Additional logic for leads or other features can be added here if needed
  }
}

// Assembly
module assembly() {
  resistor();
  translate([0, 0, 0]) sleeved_resistor();
  translate([0, 0, 0]) al_clad_resistor_assembly();
  translate([0, 0, 0]) al_clad_resistor();
}

assembly();