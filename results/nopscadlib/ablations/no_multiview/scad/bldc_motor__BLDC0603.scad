// Parameters
stator_diameter_mm = 9.0; //[4.5:18.0:0.1]
stator_height_mm = 8.0; //[4.0:16.0:0.1]
housing_wall_thickness_mm = 0.5; //[0.25:1.0:0.05]
housing_clearance_mm = 0.2; //[0.05:0.6:0.05]
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
shaft_length_mm = 12.0; //[6.0:24.0:0.5]
endcap_thickness_mm = 1.0; //[0.5:2.0:0.1]
wire_port_diameter_mm = 1.5; //[0.8:3.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
housing_height_mm = 10.0; //[6.0:20.0:0.1]
flange_thickness_mm = 1.5; //[0.8:3.0:0.1]
flange_radial_extra_mm = 2.0; //[1.0:5.0:0.1]
wire_port_length_mm = 3.0; //[1.5:8.0:0.1]
buzzer_diameter_mm = 6.0; //[3.0:12.0:0.1]
buzzer_height_mm = 3.0; //[1.5:8.0:0.1]
buzzer_pin_diameter_mm = 1.0; //[0.5:2.0:0.1]
buzzer_pin_height_mm = 1.5; //[0.5:4.0:0.1]

// Buzzer - complete geometry
module buzzer() {
  color([0.8, 0.6, 0.2]) { // Brass-like color
    // Buzzer body
    cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
    // Buzzer pin
    translate([0, 0, -buzzer_height_mm/2 - buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);
  }
}

// Motor assembly
module assembly() {
  // Stator
  color("DimGray") {
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);
  }
  
  // Housing
  color("Black") {
    difference() {
      translate([0, 0, 0])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=housing_height_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm, h=housing_height_mm + overlap_mm*2, center=true);
    }
  }
  
  // Endcaps
  color("Silver") {
    translate([0, 0, housing_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
      cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=endcap_thickness_mm, center=true);
    translate([0, 0, -housing_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
      cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=endcap_thickness_mm, center=true);
  }
  
  // Mounting flange
  color("Silver") {
    translate([0, 0, -housing_height_mm/2 - endcap_thickness_mm - flange_thickness_mm/2 + overlap_mm])
      cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm + flange_radial_extra_mm, h=flange_thickness_mm, center=true);
  }
  
  // Wire port
  color("Black") {
    translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm + wire_port_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=wire_port_diameter_mm/2 + housing_wall_thickness_mm, h=wire_port_length_mm, center=true);
  }
  
  // Central shaft
  color("Silver") {
    translate([0, 0, 0])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
  }
  
  // Buzzer feature
  translate([0, 0, -housing_height_mm/2 - endcap_thickness_mm - flange_thickness_mm - buzzer_height_mm/2 + overlap_mm])
    buzzer();
  
  // Shaft bore
  difference() {
    translate([0, 0, 0])
      cylinder(r=shaft_diameter_mm/2, h=housing_height_mm + endcap_thickness_mm*2 + flange_thickness_mm + buzzer_height_mm + buzzer_pin_height_mm + overlap_mm*4, center=true);
  }
  
  // Wire port hole
  difference() {
    translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm + wire_port_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=wire_port_diameter_mm/2, h=wire_port_length_mm + housing_wall_thickness_mm*2 + overlap_mm*2, center=true);
  }
}

assembly();