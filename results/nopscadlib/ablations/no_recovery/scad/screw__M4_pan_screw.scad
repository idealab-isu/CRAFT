// Parameters
shaft_diameter_mm = 4.0; //[2.0:8.0:0.1]
shaft_length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 7.8; //[4.0:15.6:0.1]
head_height_mm = 3.3; //[1.6:6.6:0.1]
under_head_fillet_height_mm = 0.8; //[0.4:1.6:0.1]
under_head_overlap_mm = 0.8; //[0.5:2.0:0.1]
drive_recess_diameter_mm = 4.6; //[2.0:7.0:0.1]
drive_recess_depth_mm = 1.6; //[0.8:3.0:0.1]
pcb_spacer_outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
pcb_spacer_height_mm = 6.0; //[3.0:12.0:0.5]
washer_outer_diameter_mm = 9.0; //[5.0:18.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.1]
buzzer_height_mm = 6.0; //[3.0:12.0:0.5]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=pcb_spacer_outer_diameter_mm/2, h=pcb_spacer_height_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=shaft_diameter_mm/2 + 0.2, h=pcb_spacer_height_mm + 2*under_head_overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw
    difference() {
      union() {
        translate([0, 0, -head_height_mm/2 - shaft_length_mm/2 + under_head_overlap_mm])
          cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
        translate([0, 0, 0])
          cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
        translate([0, 0, -head_height_mm/2 - under_head_fillet_height_mm/2 + under_head_overlap_mm])
          cylinder(r1=head_diameter_mm/2, r2=shaft_diameter_mm/2, h=under_head_fillet_height_mm, center=true);
      }
      translate([0, 0, head_height_mm/2 - drive_recess_depth_mm/2 + under_head_overlap_mm])
        cylinder(r=drive_recess_diameter_mm/2, h=drive_recess_depth_mm, center=true);
    }
    // Washer
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + under_head_overlap_mm])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=shaft_diameter_mm/2 + 0.2, h=washer_thickness_mm + 2*under_head_overlap_mm, center=true);
      }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -head_height_mm/2 - under_head_fillet_height_mm - pcb_spacer_height_mm - buzzer_height_mm/2 + under_head_overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();