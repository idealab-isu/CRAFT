// Parameters
shank_diameter = 4.2; //[2.1:8.4:0.1]
shank_radius = 2.1; //[1.05:4.2:0.05]
length_under_head = 10; //[5:20:0.5]
head_diameter = 8.2; //[4.1:16.4:0.1]
head_radius = 4.1; //[2.05:8.2:0.05]
head_height = 3.05; //[1.5:6.1:0.05]
overlap = 0.8; //[0.2:2:0.1]
drive_recess_radius = 2.4; //[1.2:4.8:0.1]
drive_recess_depth = 1.6; //[0.8:3.2:0.1]
drive_slot_width = 1; //[0.5:2:0.1]
washer_outer_radius = 5.2; //[2.6:10.4:0.1]
washer_thickness = 1; //[0.5:2:0.1]
washer_inner_radius = 2.3; //[1.2:4.6:0.05]
pcb_spacer_height = 3; //[1.5:6:0.5]
buzzer_radius = 0.5; //[0.25:1:0.05]
buzzer_height = 0.5; //[0.25:1:0.05]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=washer_outer_radius, h=pcb_spacer_height, center=true);
      translate([0, 0, 0])
        cylinder(r=washer_inner_radius, h=pcb_spacer_height + 2*overlap, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Shank
      translate([0, 0, -head_height/2 - length_under_head/2 + overlap])
        cylinder(r=shank_radius, h=length_under_head, center=true);
      
      // Pan Head with Drive Recess
      difference() {
        translate([0, 0, 0])
          cylinder(r=head_radius, h=head_height, center=true);
        union() {
          translate([0, 0, head_height/2 - drive_recess_depth/2 + overlap])
            cylinder(r=drive_recess_radius, h=drive_recess_depth, center=true);
          translate([0, 0, head_height/2 - drive_recess_depth/2 + overlap])
            cube([2*drive_recess_radius, drive_slot_width, drive_recess_depth], center=true);
          translate([0, 0, head_height/2 - drive_recess_depth/2 + overlap])
            cube([drive_slot_width, 2*drive_recess_radius, drive_recess_depth], center=true);
        }
      }
      
      // Washer Ring
      difference() {
        translate([0, 0, -head_height/2 - washer_thickness/2 + overlap])
          cylinder(r=washer_outer_radius, h=washer_thickness, center=true);
        translate([0, 0, -head_height/2 - washer_thickness/2 + overlap])
          cylinder(r=washer_inner_radius, h=washer_thickness + 2*overlap, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.72, 0.45, 0.2]) {
    translate([0, 0, head_height/2 + buzzer_height/2 - overlap])
      cylinder(r=buzzer_radius, h=buzzer_height, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -head_height/2 - washer_thickness - pcb_spacer_height/2 + 2*overlap])
    pcb_spacer();
  buzzer();
}

assembly();