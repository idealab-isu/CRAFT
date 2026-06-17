// Parameters
stator_outer_diameter_mm = 17.75; //[8.875:35.5:0.05]
stator_height_mm = 14.5; //[7.25:29:0.1]
stator_bore_diameter_mm = 5; //[2.5:10:0.05]
rotor_outer_diameter_mm = 19; //[9.5:38:0.05]
endcap_thickness_mm = 1; //[0.5:2:0.05]
clearance_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
include_bore = 1; //[0:1:1]
buzzer_diameter_mm = 10; //[5:20:0.1]
buzzer_height_mm = 6; //[3:12:0.1]
buzzer_pin_diameter_mm = 2; //[1:4:0.1]
buzzer_pin_height_mm = 3; //[1:8:0.1]

// Buzzer - complete geometry
module buzzer() {
  color([0.85, 0.85, 0.8]) {
    // Buzzer body
    translate([rotor_outer_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, 0])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
    // Buzzer pin
    translate([rotor_outer_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, buzzer_height_mm/2 + buzzer_pin_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  // Stator core with optional bore
  difference() {
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(r=stator_outer_diameter_mm/2, h=stator_height_mm, center=true, $fn=64);
    }
    if (include_bore) {
      translate([0, 0, 0])
        cylinder(r=(stator_bore_diameter_mm/2) * include_bore, h=stator_height_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
  
  // Rotor can envelope
  color("Black") {
    translate([0, 0, 0])
      cylinder(r=rotor_outer_diameter_mm/2, h=stator_height_mm + 2*endcap_thickness_mm, center=true, $fn=64);
  }
  
  // Endcap top
  color("Silver") {
    translate([0, 0, stator_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
      cylinder(r=rotor_outer_diameter_mm/2, h=endcap_thickness_mm, center=true, $fn=64);
  }
  
  // Endcap bottom
  color("Silver") {
    translate([0, 0, -stator_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
      cylinder(r=rotor_outer_diameter_mm/2, h=endcap_thickness_mm, center=true, $fn=64);
  }
  
  // Buzzer
  buzzer();
}

assembly();