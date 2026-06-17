// Parameters
stator_diameter_mm = 42.5; //[21.25:85:0.1]
outer_diameter_mm = 42.5; //[21.25:85:0.1]
motor_height_mm = 48; //[24:96:0.1]
tolerances_mm = 0; //[0:1:0.05]
stator_ref_wall_mm = 1.5; //[0.8:3:0.1]
stator_ref_height_mm = 12; //[6:24:0.5]
overlap_mm = 1; //[0.5:2:0.1]
buzzer_diameter_mm = 16; //[8:32:0.5]
buzzer_height_mm = 7; //[3:14:0.5]
buzzer_pin_diameter_mm = 2; //[1:4:0.1]
buzzer_pin_height_mm = 4; //[1:10:0.5]
buzzer_offset_x_mm = 0; //[-10:10:0.5]
buzzer_offset_y_mm = 0; //[-10:10:0.5]

// Buzzer - complete geometry
module buzzer() {
  color([0.2, 0.2, 0.22]) {
    // Buzzer body
    difference() {
      translate([buzzer_offset_x_mm, buzzer_offset_y_mm, motor_height_mm/2 + buzzer_height_mm/2 - overlap_mm])
        cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
      translate([buzzer_offset_x_mm, buzzer_offset_y_mm, motor_height_mm/2 + buzzer_height_mm/2 - overlap_mm])
        cylinder(r=max((buzzer_diameter_mm/2 - buzzer_height_mm/7), 0.1), h=buzzer_height_mm + 2*overlap_mm, center=true, $fn=32);
    }
    // Buzzer pin
    translate([buzzer_offset_x_mm, buzzer_offset_y_mm, motor_height_mm/2 + buzzer_height_mm - overlap_mm + buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Assembly - combines all parts
module assembly() {
  color("Black") {
    // Motor main cylinder
    translate([0, 0, 0])
      cylinder(r=(outer_diameter_mm + 2*tolerances_mm)/2, h=motor_height_mm, center=true, $fn=64);
  }
  color("Silver") {
    // Stator envelope reference
    difference() {
      translate([0, 0, -motor_height_mm/2 + stator_ref_height_mm/2 - overlap_mm])
        cylinder(r=(stator_diameter_mm + 2*tolerances_mm)/2, h=stator_ref_height_mm, center=true, $fn=64);
      translate([0, 0, -motor_height_mm/2 + stator_ref_height_mm/2 - overlap_mm])
        cylinder(r=max(((stator_diameter_mm + 2*tolerances_mm)/2 - stator_ref_wall_mm), 0.1), h=stator_ref_height_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
  // Buzzer
  buzzer();
}

// Final assembly call
assembly();