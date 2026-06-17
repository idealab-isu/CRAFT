// Parameters
resistance_value_ohm = 5.6; //[0.1:100:0.1]
power_rating_w = 3; //[1:10:1]
lead_count = 2; //[2:2:1]
body_length_mm = 18; //[9:36:1]
body_diameter_mm = 6; //[3:12:0.5]
lead_diameter_mm = 0.8; //[0.4:1.6:0.1]
lead_length_each_mm = 30; //[15:60:1]
lead_span_mm = 78; //[40:140:1]
lead_body_overlap_mm = 1; //[0.5:2:0.1]
sleeve_enabled = 1; //[0:1:1]
sleeve_outer_diameter_mm = 1.6; //[1:3.2:0.1]
sleeve_length_each_mm = 20; //[5:40:1]
sleeve_body_overlap_mm = 1; //[0.5:2:0.1]
al_clad_enabled = 0; //[0:1:1]
al_clad_length_mm = 25; //[12.5:50:1]
al_clad_width_mm = 15; //[7.5:30:1]
al_clad_height_mm = 10; //[5:20:1]
al_clad_shell_thickness_mm = 1.5; //[0.8:3:0.1]
al_clad_overlap_into_lead_mm = 1; //[0.5:2:0.1]
tolerance = 5; //[1:10:1]

// Resistor - complete geometry
module resistor() {
  color("DimGray") {
    // Cylindrical body
    rotate([0, 90, 0])
      cylinder(r=body_diameter_mm/2, h=body_length_mm, center=true);
    
    // Leads
    translate([-(body_length_mm/2 + (lead_length_each_mm + lead_body_overlap_mm)/2 - lead_body_overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm + lead_body_overlap_mm, center=true);
    translate([(body_length_mm/2 + (lead_length_each_mm + lead_body_overlap_mm)/2 - lead_body_overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=lead_diameter_mm/2, h=lead_length_each_mm + lead_body_overlap_mm, center=true);
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  resistor();
  if (sleeve_enabled) {
    color("White") {
      // Sleeves
      translate([-(body_length_mm/2 + (sleeve_length_each_mm + sleeve_body_overlap_mm)/2 - sleeve_body_overlap_mm), 0, 0])
        rotate([0, 90, 0])
        cylinder(r=sleeve_outer_diameter_mm/2, h=sleeve_length_each_mm + sleeve_body_overlap_mm, center=true);
      translate([(body_length_mm/2 + (sleeve_length_each_mm + sleeve_body_overlap_mm)/2 - sleeve_body_overlap_mm), 0, 0])
        rotate([0, 90, 0])
        cylinder(r=sleeve_outer_diameter_mm/2, h=sleeve_length_each_mm + sleeve_body_overlap_mm, center=true);
    }
  }
}

// Al Clad Resistor - complete geometry
module al_clad_resistor() {
  color("Silver") {
    // Al-clad shell
    difference() {
      translate([0, 0, -(body_diameter_mm/2 + al_clad_height_mm/2 - al_clad_overlap_into_lead_mm)])
        cube([al_clad_length_mm, al_clad_width_mm, al_clad_height_mm], center=true);
      translate([0, 0, -(body_diameter_mm/2 + al_clad_height_mm/2 - al_clad_overlap_into_lead_mm)])
        cube([al_clad_length_mm - 2*al_clad_shell_thickness_mm, al_clad_width_mm - 2*al_clad_shell_thickness_mm, al_clad_height_mm - 2*al_clad_shell_thickness_mm], center=true);
    }
    // Al-clad core
    translate([0, 0, -(body_diameter_mm/2 + al_clad_height_mm/2 - al_clad_overlap_into_lead_mm)])
      rotate([0, 90, 0])
      cylinder(r=min(al_clad_width_mm, al_clad_height_mm)/2 - al_clad_shell_thickness_mm, h=al_clad_length_mm - 2*al_clad_shell_thickness_mm, center=true);
  }
}

// Al Clad Resistor Assembly - complete geometry
module al_clad_resistor_assembly() {
  sleeved_resistor();
  if (al_clad_enabled) {
    al_clad_resistor();
  }
}

// Assembly
module assembly() {
  al_clad_resistor_assembly();
}

assembly();