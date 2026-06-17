// Parameters
stator_diameter_mm = 35.0; //[17.5:70.0:0.5]
motor_height_mm = 45.0; //[22.5:90.0:0.5]
can_wall_thickness_mm = 1.5; //[0.75:3.0:0.1]
can_outer_diameter_mm = 37.0; //[18.5:74.0:0.5]
stator_height_mm = 20.0; //[10.0:40.0:0.5]
air_gap_mm = 0.5; //[0.2:1.5:0.1]
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
shaft_protrusion_front_mm = 15.0; //[0.0:30.0:0.5]
shaft_protrusion_rear_mm = 0.0; //[0.0:30.0:0.5]
endcap_thickness_mm = 2.0; //[1.0:5.0:0.5]
flange_thickness_mm = 2.0; //[1.0:6.0:0.5]
flange_outer_diameter_mm = 40.0; //[20.0:80.0:0.5]
mount_hole_count = 4; //[2:12:1]
mount_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
mount_hole_circle_diameter_mm = 30.0; //[15.0:60.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 6.0; //[3.0:15.0:0.5]
buzzer_pin_diameter_mm = 2.0; //[1.0:4.0:0.1]
buzzer_pin_height_mm = 3.0; //[1.0:8.0:0.5]

// Buzzer module
module buzzer() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      // Buzzer body
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
      // Inner hollow
      cylinder(r=buzzer_diameter_mm/2 - (buzzer_height_mm > 5 ? 1 : 0.75), h=buzzer_height_mm, center=true);
    }
    // Buzzer pin
    translate([0, 0, buzzer_height_mm/2 - buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);
  }
}

// Motor assembly
module assembly() {
  color("Black") {
    // Motor can
    difference() {
      cylinder(r=can_outer_diameter_mm/2, h=motor_height_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=can_outer_diameter_mm/2 - can_wall_thickness_mm, h=motor_height_mm - 2*endcap_thickness_mm + 2*overlap_mm, center=true);
    }
    // Stator core
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);
    // Front endcap
    translate([0, 0, motor_height_mm/2 - endcap_thickness_mm/2])
      cylinder(r=can_outer_diameter_mm/2 - can_wall_thickness_mm + overlap_mm, h=endcap_thickness_mm, center=true);
    // Rear endcap
    translate([0, 0, -motor_height_mm/2 + endcap_thickness_mm/2])
      cylinder(r=can_outer_diameter_mm/2 - can_wall_thickness_mm + overlap_mm, h=endcap_thickness_mm, center=true);
    // Mounting flange
    translate([0, 0, motor_height_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
    // Central shaft
    translate([0, 0, (shaft_protrusion_front_mm - shaft_protrusion_rear_mm)/2])
      cylinder(r=shaft_diameter_mm/2, h=motor_height_mm + shaft_protrusion_front_mm + shaft_protrusion_rear_mm, center=true);
  }
  
  // Mounting holes
  color("Silver") {
    for (angle = [0, 90, 180, 270]) {
      rotate([0, 0, angle])
        translate([mount_hole_circle_diameter_mm/2, 0, motor_height_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + endcap_thickness_mm + 4*overlap_mm, center=true);
    }
  }
  
  // Buzzer
  translate([0, 0, -motor_height_mm/2 - buzzer_height_mm/2 + overlap_mm])
    buzzer();
}

assembly();