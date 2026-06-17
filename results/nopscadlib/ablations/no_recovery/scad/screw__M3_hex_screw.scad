// Parameters
shaft_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 6.4; //[3.2:12.8:0.1]
head_height_mm = 2.125; //[1.0625:4.25:0.025]
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
thread_depth_mm = 0.15; //[0.05:0.35:0.01]
thread_length_mm = 8; //[3:18:0.5]
under_head_fillet_height_mm = 0.6; //[0.3:1.2:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
pcb_spacer_height_mm = 3; //[1.5:8:0.5]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
clearance_mm = 0.2; //[0.1:0.6:0.05]
washer_outer_diameter_mm = 7; //[3.5:14:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.05]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 5; //[2.5:10:0.5]
buzzer_bridge_thickness_mm = 1.2; //[0.6:2.4:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=shaft_diameter_mm/2 + clearance_mm + pcb_spacer_wall_mm, h=pcb_spacer_height_mm, center=true);
      translate([0, 0, -overlap_mm])
        cylinder(r=shaft_diameter_mm/2 + clearance_mm, h=pcb_spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Shaft
      translate([0, 0, -head_height_mm/2])
        cylinder(r=shaft_diameter_mm/2, h=length_mm - head_height_mm, center=true);
      
      // Hex Head
      translate([0, 0, length_mm/2 - head_height_mm/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
      
      // Under Head Transition
      translate([0, 0, length_mm/2 - head_height_mm - under_head_fillet_height_mm/2 + overlap_mm])
        cylinder(r1=head_diameter_mm/2, r2=shaft_diameter_mm/2, h=under_head_fillet_height_mm, center=true);
      
      // Thread Representation
      if (threaded) {
        translate([0, 0, -(length_mm - head_height_mm)/2 + thread_length_mm/2 - overlap_mm])
          cylinder(r=shaft_diameter_mm/2 + thread_depth_mm, h=thread_length_mm, center=true);
      }
      
      // Washer
      translate([0, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm - washer_thickness_mm/2 + overlap_mm])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          translate([0, 0, -overlap_mm])
            cylinder(r=shaft_diameter_mm/2 + clearance_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    union() {
      // Buzzer Body
      translate([washer_outer_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm - washer_thickness_mm - buzzer_height_mm/2 + overlap_mm])
        cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
      
      // Buzzer Bridge
      translate([(washer_outer_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm)/2, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm - washer_thickness_mm - buzzer_bridge_thickness_mm/2 + overlap_mm])
        cube([washer_outer_diameter_mm/2 + buzzer_diameter_mm/2, buzzer_bridge_thickness_mm, buzzer_bridge_thickness_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm/2 + overlap_mm])
    pcb_spacer();
  buzzer();
}

assembly();