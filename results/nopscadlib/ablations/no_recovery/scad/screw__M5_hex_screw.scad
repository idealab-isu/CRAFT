// Parameters
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 10; //[5:20:0.5]
head_diameter_across_corners = 9.2; //[4.6:18.4:0.1]
head_height = 3.65; //[1.8:7.3:0.05]
overlap = 1; //[0.5:2:0.1]
tip_length = 1.5; //[0.5:3:0.1]
tip_radius_factor = 0.15; //[0.05:0.4:0.01]
washer_outer_diameter = 10; //[6:20:0.1]
washer_thickness = 1; //[0.5:2:0.1]
washer_clearance = 0.4; //[0.2:1:0.05]
spacer_height = 6; //[3:12:0.5]
spacer_wall = 1.8; //[0.9:3.6:0.1]
buzzer_radius = 6; //[3:12:0.5]
buzzer_height = 4; //[2:8:0.5]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Hex Head
    translate([0, 0, head_height/2])
      cylinder(h=head_height, r=head_diameter_across_corners/2, $fn=6);
    
    // Threaded Shaft
    translate([0, 0, -shaft_length/2 + overlap/2])
      cylinder(h=shaft_length, r=shaft_diameter/2);
    
    // Tip End
    translate([0, 0, -shaft_length + tip_length/2 + overlap/2])
      cylinder(h=tip_length, r1=shaft_diameter/2, r2=shaft_diameter/2 * tip_radius_factor);
    
    // Washer
    difference() {
      translate([0, 0, washer_thickness/2 - overlap/2])
        cylinder(h=washer_thickness, r=washer_outer_diameter/2);
      translate([0, 0, washer_thickness/2 - overlap/2])
        cylinder(h=washer_thickness + 2*overlap, r=(shaft_diameter + washer_clearance)/2);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, -spacer_height/2 - overlap/2])
        cylinder(h=spacer_height, r=(shaft_diameter + washer_clearance)/2 + spacer_wall);
      translate([0, 0, -spacer_height/2 - overlap/2])
        cylinder(h=spacer_height + 2*overlap, r=(shaft_diameter + washer_clearance)/2);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -spacer_height - buzzer_height/2 - overlap])
      cylinder(h=buzzer_height, r=buzzer_radius);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();