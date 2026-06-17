// Parameters
shank_diameter_mm = 2.5; //[1.25:5:0.05]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 4.7; //[2.35:9.4:0.05]
head_height_mm = 1.7; //[0.85:3.4:0.05]
recess_enabled = 1; //[0:1:1]
recess_radius_factor = 0.6; //[0.3:0.9:0.05]
recess_depth_factor = 0.5; //[0.2:0.9:0.05]
recess_slot_width_mm = 0.8; //[0.4:1.6:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
washer_outer_diameter_mm = 6.5; //[3.25:13:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.05]
washer_hole_diameter_mm = 2.8; //[1.6:4.5:0.05]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_diameter_mm = 2.9; //[2.6:3.6:0.05]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 7; //[3.5:14:0.5]
buzzer_nozzle_diameter_mm = 4; //[2:8:0.5]
buzzer_nozzle_height_mm = 2; //[1:4:0.25]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=spacer_clearance_diameter_mm/2 + spacer_wall_mm, h=spacer_height_mm, center=true);
      translate([0, 0, -overlap_mm])
        cylinder(r=spacer_clearance_diameter_mm/2, h=spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Shank
      translate([0, 0, -length_mm/2])
        cylinder(r=shank_diameter_mm/2, h=length_mm, center=true);
      
      // Pan Head
      translate([0, 0, head_height_mm/2 - overlap_mm])
        difference() {
          cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
          if (recess_enabled) {
            union() {
              translate([0, 0, head_height_mm/2 - (head_height_mm*recess_depth_factor)/2])
                cube([2*(head_diameter_mm/2)*recess_radius_factor, recess_slot_width_mm, head_height_mm*recess_depth_factor], center=true);
              translate([0, 0, head_height_mm/2 - (head_height_mm*recess_depth_factor)/2])
                cube([recess_slot_width_mm, 2*(head_diameter_mm/2)*recess_radius_factor, head_height_mm*recess_depth_factor], center=true);
            }
          }
        }
      
      // Washer
      translate([0, 0, washer_thickness_mm/2 + head_height_mm - overlap_mm])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          translate([0, 0, -overlap_mm])
            cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    union() {
      // Buzzer Body
      translate([0, 0, head_height_mm + washer_thickness_mm + buzzer_height_mm/2 - overlap_mm])
        cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
      
      // Buzzer Nozzle
      translate([0, 0, head_height_mm + washer_thickness_mm + buzzer_height_mm - overlap_mm + buzzer_nozzle_height_mm/2])
        cylinder(r=buzzer_nozzle_diameter_mm/2, h=buzzer_nozzle_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -length_mm - spacer_height_mm/2 + overlap_mm]) pcb_spacer();
  buzzer();
}

assembly();