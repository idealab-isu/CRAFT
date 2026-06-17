// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
overall_length = 10.0; //[5.0:20.0:0.1]
head_diameter = 5.7; //[2.85:11.4:0.05]
head_height = 1.65; //[0.825:3.3:0.05]
shaft_radius = 1.5; //[0.75:3.0:0.05]
head_radius = 2.85; //[1.425:5.7:0.05]
tolerance_clearance = 0.0; //[0.0:0.5:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
transition_height = 0.6; //[0.3:1.2:0.05]
washer_outer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 0.8; //[0.4:2.0:0.05]
spacer_height = 6.0; //[3.0:12.0:0.1]
spacer_wall = 1.8; //[0.9:3.6:0.1]
buzzer_diameter = 12.0; //[6.0:24.0:0.1]
buzzer_height = 5.0; //[2.5:10.0:0.1]

// PCB Spacer - complete detailed geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      cylinder(r=shaft_radius + tolerance_clearance + spacer_wall, h=spacer_height, center=true);
      translate([0, 0, 0])
        cylinder(r=shaft_radius + tolerance_clearance, h=spacer_height + 2*overlap, center=true);
    }
  }
}

// Screw and Washer - complete detailed geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Shaft
      translate([0, 0, -head_height/2 - overall_length/2 + overlap])
        cylinder(r=shaft_radius, h=overall_length, center=true);
      
      // Head to Shaft Transition
      translate([0, 0, -transition_height/2 + overlap])
        cylinder(r1=head_radius, r2=shaft_radius, h=transition_height, center=true);
      
      // Dome Head
      intersection() {
        translate([0, 0, head_radius - head_height/2])
          sphere(r=head_radius, center=true);
        translate([0, 0, 0])
          cube([2*head_radius + 2*overlap, 2*head_radius + 2*overlap, head_height], center=true);
      }
      
      // Washer
      translate([0, 0, -head_height/2 - washer_thickness/2 + overlap])
        difference() {
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
          cylinder(r=shaft_radius + tolerance_clearance, h=washer_thickness + 2*overlap, center=true);
        }
    }
  }
}

// Buzzer - complete detailed geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -head_height/2 - washer_thickness - spacer_height - buzzer_height/2 + 3*overlap])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -head_height/2 - washer_thickness - spacer_height/2 + 2*overlap])
    pcb_spacer();
  buzzer();
}

assembly();