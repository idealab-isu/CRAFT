// Parameters
stator_diameter_mm = 9.0; //[4.5:18.0:0.1]
stator_height_mm = 8.0; //[4.0:16.0:0.1]
stator_bore_diameter_mm = 2.0; //[1.0:4.0:0.1]
rotor_outer_diameter_mm = 10.0; //[5.0:20.0:0.1]
rotor_height_mm = 8.5; //[4.25:17.0:0.1]
shaft_diameter_mm = 1.5; //[0.75:3.0:0.05]
shaft_length_mm = 14.0; //[7.0:28.0:0.1]
clearance_mm = 0.2; //[0.0:1.0:0.05]
overlap_mm = 0.8; //[0.2:2.0:0.1]
rotor_wall_mm = 0.6; //[0.3:1.5:0.05]
buzzer_diameter_mm = 6.0; //[3.0:12.0:0.1]
buzzer_height_mm = 4.0; //[2.0:8.0:0.1]
buzzer_pin_diameter_mm = 2.0; //[1.0:3.0:0.1]
buzzer_pin_height_mm = 1.5; //[0.5:4.0:0.1]
buzzer_offset_x_mm = 7.0; //[3.5:14.0:0.1]

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    // Buzzer shell
    difference() {
      translate([buzzer_offset_x_mm, 0, 0])
        cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
      translate([buzzer_offset_x_mm, 0, 0])
        cylinder(r=buzzer_diameter_mm/2 - rotor_wall_mm, h=buzzer_height_mm + 2*overlap_mm, center=true);
    }
    // Buzzer pin
    translate([buzzer_offset_x_mm, 0, buzzer_height_mm/2 + buzzer_pin_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);
  }
}

// Motor assembly
module assembly() {
  // Stator
  color("DimGray") {
    difference() {
      cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);
      cylinder(r=stator_bore_diameter_mm/2, h=stator_height_mm + 2*overlap_mm, center=true);
    }
  }
  
  // Rotor
  color("Black") {
    difference() {
      cylinder(r=rotor_outer_diameter_mm/2, h=rotor_height_mm, center=true);
      cylinder(r=rotor_outer_diameter_mm/2 - rotor_wall_mm, h=rotor_height_mm + 2*overlap_mm, center=true);
    }
  }
  
  // Central Shaft
  color("Silver") {
    cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
  }
  
  // Buzzer
  buzzer();
}

// Final assembly
assembly();