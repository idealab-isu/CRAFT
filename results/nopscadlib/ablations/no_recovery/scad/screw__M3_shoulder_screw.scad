// Parameters
shaft_diameter_mm = 4.0; //[2.0:8.0:0.1]
shaft_radius_mm = 2.0; //[1.0:4.0:0.05]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 7.0; //[3.5:14.0:0.1]
head_radius_mm = 3.5; //[1.75:7.0:0.05]
head_height_mm = 2.4; //[1.2:4.8:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
transition_height_mm = 0.8; //[0.4:1.6:0.1]
washer_outer_diameter_mm = 9.0; //[5.0:18.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.5:0.1]
spacer_height_mm = 6.0; //[3.0:12.0:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_mm = 0.3; //[0.1:0.8:0.05]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 7.0; //[3.5:14.0:0.5]
buzzer_offset_x_mm = 0.0; //[-20.0:20.0:0.5]
buzzer_offset_y_mm = 0.0; //[-20.0:20.0:0.5]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=shaft_radius_mm + spacer_clearance_mm + spacer_wall_mm, h=spacer_height_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=shaft_radius_mm + spacer_clearance_mm, h=spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Head
      translate([0, 0, head_height_mm/2])
        cylinder(r=head_radius_mm, h=head_height_mm, center=true);
      // Head to Shaft Transition
      translate([0, 0, -head_height_mm/2 - transition_height_mm/2 + overlap_mm/2])
        cylinder(r1=head_radius_mm, r2=shaft_radius_mm, h=transition_height_mm, center=true);
      // Screw Shaft
      translate([0, 0, -head_height_mm/2 - (length_mm - head_height_mm)/2 + overlap_mm/2])
        cylinder(r=shaft_radius_mm, h=length_mm - head_height_mm, center=true);
      // Washer
      translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm/2])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          cylinder(r=shaft_radius_mm + spacer_clearance_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([buzzer_offset_x_mm, buzzer_offset_y_mm, head_height_mm/2 + buzzer_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
    pcb_spacer();
  buzzer();
}

assembly();