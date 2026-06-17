// Parameters
shaft_diameter_mm = 5; //[2.5:10:0.1]
length_under_head_mm = 10; //[5:20:0.1]
head_diameter_mm = 9; //[4.5:18:0.1]
head_height_mm = 2.4; //[1.2:4.8:0.1]
washer_diameter_mm = 10.5; //[6:21:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
spacer_outer_diameter_mm = 9; //[5:18:0.1]
spacer_height_mm = 6; //[3:12:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 5; //[2.5:10:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Shaft
    translate([0, 0, -head_height_mm/2 - length_under_head_mm/2 + overlap_mm/2])
      cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true, $fn=32);
    // Head
    translate([0, 0, 0])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true, $fn=32);
    // Washer
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm/2])
      cylinder(h=washer_thickness_mm, r=washer_diameter_mm/2, center=true, $fn=32);
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
      cylinder(h=spacer_height_mm, r=spacer_outer_diameter_mm/2, center=true, $fn=32);
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();