// Parameters
shaft_diameter_mm = 5; //[2.5:10:0.1]
length_mm = 10; //[5:20:0.1]
head_diameter_mm = 9; //[4.5:18:0.1]
head_height_mm = 2.4; //[1.2:4.8:0.1]
tip_length_mm = 1.2; //[0.6:2.4:0.1]
transition_height_mm = 0.6; //[0.3:1.2:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.1]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 5; //[2.5:10:0.1]
buzzer_post_diameter_mm = 3; //[1.5:6:0.1]
buzzer_post_height_mm = 2; //[1:4:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -length_mm/2])
      cylinder(h=length_mm, r=shaft_diameter_mm/2, center=true);
    // Shaft Tip
    translate([0, 0, -length_mm - tip_length_mm/2 + overlap_mm])
      cylinder(h=tip_length_mm, r1=shaft_diameter_mm/2, r2=0, center=true);
    // Head to Shaft Transition
    translate([0, 0, transition_height_mm/2 - overlap_mm])
      cylinder(h=transition_height_mm, r1=head_diameter_mm/2, r2=shaft_diameter_mm/2, center=true);
    // Screw Head
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
    // Washer
    difference() {
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=shaft_diameter_mm/2 + overlap_mm/2, center=true);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, -washer_thickness_mm - pcb_spacer_height_mm/2 + overlap_mm])
        cylinder(h=pcb_spacer_height_mm, r=shaft_diameter_mm/2 + pcb_spacer_wall_mm, center=true);
      translate([0, 0, -washer_thickness_mm - pcb_spacer_height_mm/2 + overlap_mm])
        cylinder(h=pcb_spacer_height_mm + 2*overlap_mm, r=shaft_diameter_mm/2 + overlap_mm/2, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    // Buzzer Body
    translate([0, 0, -washer_thickness_mm - pcb_spacer_height_mm - buzzer_post_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
    // Buzzer Post
    translate([0, 0, -washer_thickness_mm - pcb_spacer_height_mm - buzzer_post_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_post_height_mm, r=buzzer_post_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();