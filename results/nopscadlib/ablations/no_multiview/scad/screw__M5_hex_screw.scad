// Parameters
shaft_diameter_mm = 5; //[2.5:10:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 9.2; //[4.6:18.4:0.1]
head_height_mm = 3.65; //[1.8:7.3:0.05]
overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]
washer_hole_diameter_mm = 5.5; //[5.1:7:0.1]
spacer_height_mm = 6; //[3:15:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_diameter_mm = 5.6; //[5.1:7:0.1]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 7; //[3.5:14:0.5]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Hex Head
    translate([0, 0, 0])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true, $fn=6);
    // Threaded Shaft
    translate([0, 0, -head_height_mm/2 - length_mm/2 + overlap_mm])
      cylinder(h=length_mm, r=shaft_diameter_mm/2, center=true);
    // Washer
    difference() {
      translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_diameter_mm/2, center=true);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm, r=spacer_clearance_diameter_mm/2 + spacer_wall_mm, center=true);
      translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm + 2*overlap_mm, r=spacer_clearance_diameter_mm/2, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();