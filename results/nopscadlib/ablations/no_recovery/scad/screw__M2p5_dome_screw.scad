// Parameters
thread_diameter = 2.5; //[1.25:5:0.05]
shaft_length = 10; //[5:20:0.1]
head_diameter = 5.35; //[2.675:10.7:0.05]
head_height = 1.6; //[0.8:3.2:0.05]
transition_height = 0.6; //[0.3:1.2:0.05]
overlap = 0.8; //[0.5:2:0.1]
drive_recess_diameter = 2.2; //[1.2:4:0.05]
drive_recess_depth = 0.9; //[0.4:1.4:0.05]
washer_outer_diameter = 6.5; //[3.25:13:0.1]
washer_thickness = 0.6; //[0.3:1.2:0.05]
washer_hole_diameter = 2.8; //[1.6:5.6:0.05]
spacer_height = 6; //[3:12:0.1]
spacer_wall = 1.8; //[0.9:3.6:0.1]
spacer_inner_diameter = 3; //[2.6:4.5:0.05]
buzzer_diameter = 12; //[6:24:0.5]
buzzer_height = 5; //[2.5:10:0.1]
buzzer_stem_diameter = 3; //[1.5:6:0.1]
buzzer_stem_height = 2; //[1:4:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=spacer_inner_diameter/2 + spacer_wall, h=spacer_height, center=true);
      translate([0, 0, -overlap])
        cylinder(r=spacer_inner_diameter/2, h=spacer_height + overlap*2, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Threaded Shaft
      translate([0, 0, -shaft_length/2])
        cylinder(r=thread_diameter/2, h=shaft_length, center=true);
      
      // Dome Head
      difference() {
        union() {
          // Head Intersection
          intersection() {
            translate([0, 0, head_height - head_diameter/2])
              sphere(r=head_diameter/2, center=true);
            translate([0, 0, head_height - head_diameter])
              cube([head_diameter*2, head_diameter*2, head_diameter*2], center=true);
          }
          // Head Transition Chamfer
          translate([0, 0, transition_height/2 - overlap/2])
            cylinder(r1=head_diameter/2, r2=thread_diameter/2, h=transition_height, center=true);
        }
        // Drive Recess Placeholder
        translate([0, 0, head_height - drive_recess_depth/2])
          cylinder(r=drive_recess_diameter/2, h=drive_recess_depth, center=true);
      }
      
      // Washer
      difference() {
        translate([0, 0, -washer_thickness/2 + overlap/2])
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
        translate([0, 0, -washer_thickness/2 + overlap/2])
          cylinder(r=washer_hole_diameter/2, h=washer_thickness + overlap*2, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    union() {
      // Buzzer Body
      translate([0, 0, -washer_thickness - spacer_height - buzzer_height/2 + overlap])
        cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
      
      // Buzzer Stem
      translate([0, 0, -washer_thickness - spacer_height + buzzer_stem_height/2 - overlap])
        cylinder(r=buzzer_stem_diameter/2, h=buzzer_stem_height, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -washer_thickness - spacer_height/2 + overlap])
    pcb_spacer();
  translate([0, 0, -washer_thickness - spacer_height - buzzer_height/2 + overlap])
    buzzer();
}

assembly();