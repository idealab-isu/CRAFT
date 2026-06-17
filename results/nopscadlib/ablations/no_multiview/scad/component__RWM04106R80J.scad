// Parameters
resistance_ohms = 6.8; //[3.4:13.6:0.1]
power_w = 3; //[1.5:6:0.5]
package_style = 0; //[0:1:1]
body_length_mm = 18; //[9:36:0.5]
body_diameter_mm = 6; //[3:12:0.5]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_mm = 25; //[12.5:50:1]
end_cap_length_mm = 1.5; //[0.75:3:0.1]
lead_exit_fillet_radius_mm = 0.8; //[0.4:1.6:0.05]
banding_enabled = 0; //[0:1:1]
tolerance_percent = 5; //[1:10:1]
overlap_mm = 1; //[0.5:2:0.1]
band_width_mm = 1.2; //[0.6:2.4:0.1]
band_radial_thickness_mm = 0.2; //[0.1:0.6:0.05]

// Resistor - complete geometry
module resistor() {
  color("DimGray") {
    // Body
    translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=body_diameter_mm/2, h=body_length_mm, center=true);
    
    // End Caps
    translate([-(body_length_mm/2 - end_cap_length_mm/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=body_diameter_mm/2, h=end_cap_length_mm, center=true);
    translate([(body_length_mm/2 - end_cap_length_mm/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=body_diameter_mm/2, h=end_cap_length_mm, center=true);
    
    // Leads
    translate([-(body_length_mm/2 + lead_length_each_mm/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm + end_cap_length_mm + overlap_mm, center=true);
    translate([(body_length_mm/2 + lead_length_each_mm/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm + end_cap_length_mm + overlap_mm, center=true);
    
    // Lead Exit Fillets
    translate([-(body_length_mm/2 - (end_cap_length_mm + overlap_mm)/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_exit_fillet_radius_mm, h=end_cap_length_mm + overlap_mm, center=true);
    translate([(body_length_mm/2 - (end_cap_length_mm + overlap_mm)/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_exit_fillet_radius_mm, h=end_cap_length_mm + overlap_mm, center=true);
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  resistor();
  color("Silver") {
    // Sleeves
    translate([-(body_length_mm/2 + (lead_length_each_mm*0.6)/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2 + band_radial_thickness_mm, h=lead_length_each_mm*0.6, center=true);
    translate([(body_length_mm/2 + (lead_length_each_mm*0.6)/2 + overlap_mm/2), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2 + band_radial_thickness_mm, h=lead_length_each_mm*0.6, center=true);
  }
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color("Black") {
    // Al Clad Body
    translate([0, 0, 0])
      cube([body_length_mm*1.4, body_diameter_mm*1.2, body_diameter_mm*0.9], center=true);
    
    // Al Clad Core
    translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=body_diameter_mm*0.35, h=body_length_mm*1.2, center=true);
    
    // Al Clad Leads
    translate([-(body_length_mm*1.4/2 + lead_length_each_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm, center=true);
    translate([(body_length_mm*1.4/2 + lead_length_each_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm, center=true);
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  al_clad_resistor();
  sleeved_resistor();
}

// Assembly
module assembly() {
  al_clad_resistor_assembly();
}

assembly();