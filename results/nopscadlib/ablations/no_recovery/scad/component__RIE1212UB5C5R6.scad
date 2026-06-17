// Parameters
body_length_mm = 25; //[12.5:50:0.5]
body_diameter_mm = 8; //[4:16:0.5]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_mm = 35; //[15:70:1]
endcap_length_mm = 2.5; //[1:6:0.25]
endcap_diameter_mm = 8.4; //[4.2:16.8:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Resistor - complete geometry
module resistor() {
  color([0.85, 0.85, 0.8]) { // Enamel-coated body
    // Body
    translate([0, 0, 0])
      cylinder(h=body_length_mm, r=body_diameter_mm/2, center=true, $fn=32);
    // Endcaps
    translate([0, 0, -(body_length_mm/2 + endcap_length_mm/2 - overlap_mm)])
      cylinder(h=endcap_length_mm, r=endcap_diameter_mm/2, center=true, $fn=32);
    translate([0, 0, (body_length_mm/2 + endcap_length_mm/2 - overlap_mm)])
      cylinder(h=endcap_length_mm, r=endcap_diameter_mm/2, center=true, $fn=32);
    // Leads
    translate([0, 0, -(body_length_mm/2 + endcap_length_mm + lead_length_each_mm/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm, r=lead_diameter_mm/2, center=true, $fn=16);
    translate([0, 0, (body_length_mm/2 + endcap_length_mm + lead_length_each_mm/2 - overlap_mm)])
      cylinder(h=lead_length_each_mm, r=lead_diameter_mm/2, center=true, $fn=16);
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  color([0.75, 0.75, 0.77]) { // Aluminum cladding
    // Cladding
    translate([0, 0, 0])
      cylinder(h=body_length_mm + 2 * endcap_length_mm, r=endcap_diameter_mm/2 + 0.5, center=true, $fn=32);
  }
  resistor();
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.1, 0.1, 0.6]) { // Blue sleeving
    // Sleeving
    translate([0, 0, 0])
      cylinder(h=body_length_mm + 2 * endcap_length_mm, r=endcap_diameter_mm/2 + 1, center=true, $fn=32);
  }
  resistor();
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color([0.4, 0.4, 0.43]) { // Steel look
    // Cladding
    translate([0, 0, 0])
      cylinder(h=body_length_mm + 2 * endcap_length_mm, r=endcap_diameter_mm/2 + 0.5, center=true, $fn=32);
  }
  resistor();
}

// Assembly
module assembly() {
  translate([0, 0, 0]) resistor();
  translate([0, 0, 0]) al_clad_resistor_assembly();
  translate([0, 0, 0]) sleeved_resistor();
  translate([0, 0, 0]) al_clad_resistor();
}

assembly();