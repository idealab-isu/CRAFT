// Parameters
stator_diameter_mm = 35.0; //[17.5:70.0:0.5]
motor_height_mm = 45.0; //[22.5:90.0:0.5]
housing_outer_diameter_mm = 35.0; //[17.5:70.0:0.5]
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
shaft_extension_mm = 10.0; //[5.0:20.0:0.5]
endcap_thickness_mm = 2.0; //[1.0:4.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 6.0; //[3.0:12.0:0.5]
buzzer_pin_diameter_mm = 2.0; //[1.0:4.0:0.1]
buzzer_pin_height_mm = 3.0; //[1.5:6.0:0.5]

// Buzzer module with detailed geometry
module buzzer() {
  color([0.2, 0.2, 0.2]) {
    // Buzzer body
    rotate([0, 90, 0])
      translate([housing_outer_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, 0])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
    
    // Buzzer pin
    rotate([0, 90, 0])
      translate([housing_outer_diameter_mm/2 + buzzer_diameter_mm + buzzer_pin_height_mm/2 - overlap_mm, 0, 0])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Motor assembly
module assembly() {
  // Motor housing
  color("Black") {
    translate([0, 0, 0])
      cylinder(r=housing_outer_diameter_mm/2, h=motor_height_mm, center=true, $fn=64);
  }
  
  // Endcaps
  color("DimGray") {
    translate([0, 0, motor_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
      cylinder(r=housing_outer_diameter_mm/2, h=endcap_thickness_mm, center=true, $fn=64);
    translate([0, 0, -motor_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
      cylinder(r=housing_outer_diameter_mm/2, h=endcap_thickness_mm, center=true, $fn=64);
  }
  
  // Shaft
  color("Silver") {
    translate([0, 0, motor_height_mm/2 + endcap_thickness_mm - overlap_mm + shaft_extension_mm/2])
      cylinder(r=shaft_diameter_mm/2, h=shaft_extension_mm, center=true, $fn=32);
  }
  
  // Buzzer
  buzzer();
}

// Final assembly call
assembly();